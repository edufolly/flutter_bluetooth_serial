package io.github.edufolly.flutterbluetoothserial;

import android.Manifest;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import android.util.Log;
import android.os.AsyncTask;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;

public class FlutterBluetoothSerialPlugin implements MethodCallHandler, RequestPermissionsResultListener {
    // Plugin
    private static final String TAG = "FlutterBluePlugin";
    private static final String PLUGIN_NAMESPACE = "flutter_bluetooth_serial";
    private final Registrar registrar;
    
    // Permissions
    private static final int REQUEST_COARSE_LOCATION_PERMISSIONS = 1451;
    
    // Bluetooth
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothManager bluetoothManager;
    private EventSink statusSink;
    private BluetoothConnection bluetoothConnection;
    
    // Data read
    private EventSink readSink;



    public static void registerWith(Registrar registrar) {
        final FlutterBluetoothSerialPlugin instance = new FlutterBluetoothSerialPlugin(registrar);
        registrar.addRequestPermissionsResultListener(instance);
    }

    FlutterBluetoothSerialPlugin(Registrar registrar) {
        this.registrar = registrar;
        
        MethodChannel methodChannel = new MethodChannel(registrar.messenger(), PLUGIN_NAMESPACE + "/methods");
        methodChannel.setMethodCallHandler(this);
        
        this.bluetoothManager = (BluetoothManager) registrar.activity().getSystemService(Context.BLUETOOTH_SERVICE);
        assert this.bluetoothManager != null;

        this.bluetoothAdapter = bluetoothManager.getAdapter();
        
        this.bluetoothConnection = new BluetoothConnection(this.bluetoothAdapter, new BluetoothConnection.Receiver() {
            @Override
            public void onRead(String data) {
                readSink.success(data);
            }
        });

        EventChannel readChannel = new EventChannel(registrar.messenger(), PLUGIN_NAMESPACE + "/read");
        EventChannel stateChannel = new EventChannel(registrar.messenger(), PLUGIN_NAMESPACE + "/state");
        readChannel.setStreamHandler(readResultsHandler);
        stateChannel.setStreamHandler(stateStreamHandler);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (bluetoothAdapter == null) {
            if ("isAvailable".equals(call.method)) {
                result.success(false);
                return;
            }
            else {
                result.error("bluetooth_unavailable", "bluetooth is not available", null);
                return;
            }
        }

        switch (call.method) {

            case "isAvailable":
                result.success(true);
                break;

            case "isOn":
            case "isEnabled":
                result.success(bluetoothAdapter.isEnabled());
                break;

            case "isConnected":
                result.success(bluetoothConnection.isConnected());
                break;

            case "openSettings":
                ContextCompat.startActivity(registrar.activity(), new Intent(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS), null);
                result.success(null);
                break;
            
            case "ensurePermissions":
                ensurePermissions(new EnsurePermissionsCallback() {
                    @Override
                    public void onResult(boolean granted) {
                        result.success(granted);
                    }
                });
                break;

            case "getBondedDevices":
                ensurePermissions(new EnsurePermissionsCallback() {
                    @Override
                    public void onResult(boolean granted) {
                        if (!granted) {
                            result.error("no_permissions", "discovering other devices requires location access permission", null);
                            return;
                        }

                        List<Map<String, Object>> list = new ArrayList<>();
                        for (BluetoothDevice device : bluetoothAdapter.getBondedDevices()) {
                            Map<String, Object> ret = new HashMap<>();
                            ret.put("address", device.getAddress());
                            ret.put("name", device.getName());
                            ret.put("type", device.getType());
                            list.add(ret);
                        }

                        result.success(list);
                    }
                });
                break;

            case "connect":
                if (call.hasArgument("address")) {
                    String address = call.argument("address");
                    AsyncTask.execute(() -> {
                        try {
                            bluetoothConnection.connect(address);
                            result.success(null);
                        }
                        catch (Exception ex) {
                            result.error("connect_error", ex.getMessage(), exceptionToString(ex));
                        }
                    });
                } else {
                    result.error("invalid_argument", "argument 'address' not found", null);
                }
                break;

            case "disconnect":
                AsyncTask.execute(() -> {
                    try {
                        bluetoothConnection.disconnect();
                        result.success(null);
                    }
                    catch (Exception ex) {
                        result.error("disconnection_error", ex.getMessage(), exceptionToString(ex));
                    }
                });
                break;

            case "write":
                if (call.hasArgument("message")) {
                    String message = call.argument("message");
                    AsyncTask.execute(() -> {
                        try {
                            bluetoothConnection.write(message.getBytes());
                            result.success(null);
                        }
                        catch (Exception ex) {
                            result.error("write_error", ex.getMessage(), exceptionToString(ex));
                        }
                    });
                } else {
                    result.error("invalid_argument", "argument 'message' not found", null);
                }
                break;
                
            case "writeBytes":
                if (call.hasArgument("message")) {
                    byte[] message = call.argument("message");
                    try {
                        bluetoothConnection.write(message);
                        result.success(null);
                    }
                    catch (Exception ex) {
                        result.error("write_error", ex.getMessage(), exceptionToString(ex));
                    }
                } else {
                    result.error("invalid_argument", "argument 'message' not found", null);
                }
                break;

            default:
                result.notImplemented();
                break;
        }
    }



    private interface EnsurePermissionsCallback {
        public void onResult(boolean granted);
    }

    EnsurePermissionsCallback pendingPermissionsEnsureCallbacks = null;

    private void ensurePermissions(EnsurePermissionsCallback callbacks) {
        if (
            ContextCompat.checkSelfPermission(registrar.activity(),
                Manifest.permission.ACCESS_COARSE_LOCATION) 
                    != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(registrar.activity(),
                new String[]{Manifest.permission.ACCESS_COARSE_LOCATION},
                    REQUEST_COARSE_LOCATION_PERMISSIONS);

            pendingPermissionsEnsureCallbacks = callbacks;
        }
        else {
            callbacks.onResult(true);
        }
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode == REQUEST_COARSE_LOCATION_PERMISSIONS) {
            pendingPermissionsEnsureCallbacks.onResult(grantResults[0] == PackageManager.PERMISSION_GRANTED);
            pendingPermissionsEnsureCallbacks = null;
            return true;
        }
        return false;
    }



    /// Helper function to get string out of exception
    private String exceptionToString(Exception ex) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        ex.printStackTrace(pw);
        return sw.toString();
    }



    private final StreamHandler stateStreamHandler = new StreamHandler() {

        private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                final String action = intent.getAction();

                Log.d(TAG, action);

                if (BluetoothAdapter.ACTION_STATE_CHANGED.equals(action)) {
                    bluetoothConnection.disconnect();
                    statusSink.success(intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, -1));
                } else if (BluetoothDevice.ACTION_ACL_CONNECTED.equals(action)) {
                    statusSink.success(1);
                } else if (BluetoothDevice.ACTION_ACL_DISCONNECTED.equals(action)) {
                    bluetoothConnection.disconnect();
                    statusSink.success(0);
                }
            }
        };

        @Override
        public void onListen(Object o, EventSink eventSink) {
            statusSink = eventSink;
            registrar.activity().registerReceiver(mReceiver,
                    new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED));

            registrar.activeContext().registerReceiver(mReceiver,
                    new IntentFilter(BluetoothDevice.ACTION_ACL_CONNECTED));

            registrar.activeContext().registerReceiver(mReceiver,
                    new IntentFilter(BluetoothDevice.ACTION_ACL_DISCONNECTED));
        }

        @Override
        public void onCancel(Object o) {
            statusSink = null;
            registrar.activity().unregisterReceiver(mReceiver);
        }
    };

    private final StreamHandler readResultsHandler = new StreamHandler() {
        @Override
        public void onListen(Object o, EventSink eventSink) {
            readSink = eventSink;
        }

        @Override
        public void onCancel(Object o) {
            readSink = null;
        }
    };
}
