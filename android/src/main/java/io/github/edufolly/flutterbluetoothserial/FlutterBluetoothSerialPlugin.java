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
    private Result pendingResultForActivityResult = null;
    
    // Permissions
    private static final int REQUEST_COARSE_LOCATION_PERMISSIONS = 1451;
    private static final int REQUEST_ENABLE_BLUETOOH = 2137;
    
    // General Bluetooth
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothManager bluetoothManager;
    
    // Status
    private final BroadcastReceiver statusReceiver;
    private EventSink statusSink;

    // Discovery
    private EventChannel discoveryChannel;
    private EventSink discoverySink;
    private StreamHandler discoveryStreamHandler;
    private BroadcastReceiver discoveryReceiver;

    // Connection
    private BluetoothConnection bluetoothConnection;
    private EventSink readSink;



    /// Registers plugin in Flutter plugin system
    public static void registerWith(Registrar registrar) {
        final FlutterBluetoothSerialPlugin instance = new FlutterBluetoothSerialPlugin(registrar);
        registrar.addRequestPermissionsResultListener(instance);
    }

    /// Constructs the plugin instance
    FlutterBluetoothSerialPlugin(Registrar registrar) {
        // Plugin
        {
            this.registrar = registrar;
            
            MethodChannel methodChannel = new MethodChannel(registrar.messenger(), PLUGIN_NAMESPACE + "/methods");
            methodChannel.setMethodCallHandler(this);
        }
        
        // General Bluetooth
        {
            this.bluetoothManager = (BluetoothManager) registrar.activity().getSystemService(Context.BLUETOOTH_SERVICE);
            assert this.bluetoothManager != null;

            this.bluetoothAdapter = bluetoothManager.getAdapter();
        }

        // Status
        {
            statusReceiver = new BroadcastReceiver() {
                @Override
                public void onReceive(Context context, Intent intent) {
                    if (statusSink == null) {
                        return;
                    }
                    
                    final String action = intent.getAction();
                    switch (action) {
                        case BluetoothAdapter.ACTION_STATE_CHANGED:
                            bluetoothConnection.disconnect();
                            statusSink.success(intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, -1));
                            break;
                        case BluetoothDevice.ACTION_ACL_CONNECTED:
                            statusSink.success(1);
                            break;
                        case BluetoothDevice.ACTION_ACL_DISCONNECTED:
                            bluetoothConnection.disconnect();
                            statusSink.success(0);
                            break;
                    }
                }
            };

            EventChannel stateChannel = new EventChannel(registrar.messenger(), PLUGIN_NAMESPACE + "/state");

            stateChannel.setStreamHandler(new StreamHandler() {
                @Override
                public void onListen(Object o, EventSink eventSink) {
                    statusSink = eventSink;
                    
                    IntentFilter filter = new IntentFilter();
                    filter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED);
                    filter.addAction(BluetoothDevice.ACTION_ACL_CONNECTED);
                    filter.addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED);
                    registrar.activeContext().registerReceiver(statusReceiver, filter);
                }
                @Override
                public void onCancel(Object o) {
                    statusSink = null;
                    try {
                        registrar.activeContext().unregisterReceiver(statusReceiver);
                    }
                    catch (IllegalArgumentException ex) {
                        // Ignore `Receiver not registered` exception
                    }
                }
            });
        }

        // Discovery
        {
            discoveryReceiver = new BroadcastReceiver() {
                @Override
                public void onReceive(Context context, Intent intent) {
                    final String action = intent.getAction();
                    switch (action) {
                        case BluetoothDevice.ACTION_FOUND:
                            final BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                            //final BluetoothClass deviceClass = intent.getParcelableExtra(BluetoothDevice.EXTRA_CLASS); // @TODO . !BluetoothClass!
                            //final String extraName = intent.getStringExtra(BluetoothDevice.EXTRA_NAME); // @TODO ? !EXTRA_NAME!
                            final int deviceRSSI = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, Short.MIN_VALUE);

                            Map<String, Object> discoveryResult = new HashMap<>();
                            discoveryResult.put("address", device.getAddress());
                            discoveryResult.put("name", device.getName());
                            discoveryResult.put("type", device.getType());
                            //discoveryResult.put("class", deviceClass); // @TODO . it isn't my priority for now !BluetoothClass!
                            // @TODO ? maybe "connected" - look for each of connection instances etc; There is `BluetoothManage.getConnectedDevice` 
                            discoveryResult.put("bonded", device.getBondState() == BluetoothDevice.BOND_BONDED);
                            //discoveryResult.put("extraName", extraName); // @TODO ? !EXTRA_NAME! Is there a reason for `EXTRA_NAME`? https://stackoverflow.com/q/56315991/4880243
                            discoveryResult.put("rssi", deviceRSSI);

                            Log.d(TAG, "Discovered " + device.getAddress());
                            if (discoverySink != null) {
                                discoverySink.success(discoveryResult);
                            }
                            break;

                        case BluetoothAdapter.ACTION_DISCOVERY_FINISHED:
                            Log.d(TAG, "Discovery finished");
                            try {
                                context.unregisterReceiver(discoveryReceiver);
                            }
                            catch (IllegalArgumentException ex) {
                                // Ignore `Receiver not registered` exception
                            }
                            
                            bluetoothAdapter.cancelDiscovery();

                            if (discoverySink != null) {
                                discoverySink.endOfStream();
                                discoverySink = null;
                            }
                            break;
                    }
                }
            };

            discoveryChannel = new EventChannel(registrar.messenger(), PLUGIN_NAMESPACE + "/discovery");

            discoveryStreamHandler = new StreamHandler() {
                @Override
                public void onListen(Object o, EventSink eventSink) {
                    discoverySink = eventSink;
                }
                @Override
                public void onCancel(Object o) {
                    Log.d(TAG, "Canceling discovery (stream closed)");
                    try {
                        registrar.activeContext().unregisterReceiver(discoveryReceiver);
                    }
                    catch (IllegalArgumentException ex) {
                        // Ignore `Receiver not registered` exception
                    }
                    
                    bluetoothAdapter.cancelDiscovery();

                    if (discoverySink != null) {
                        discoverySink.endOfStream();
                        discoverySink = null;
                    }
                }
            };
            discoveryChannel.setStreamHandler(discoveryStreamHandler);
        }

        // Connection
        {
            this.bluetoothConnection = new BluetoothConnection(this.bluetoothAdapter, new BluetoothConnection.Receiver() {
                @Override
                public void onRead(byte[] buffer) {
                    registrar.activity().runOnUiThread(new Runnable() {
                        @Override 
                        public void run() {
                            if (readSink != null) {
                                readSink.success(buffer);
                            }
                        }
                    });
                }
            });

            EventChannel readChannel = new EventChannel(registrar.messenger(), PLUGIN_NAMESPACE + "/read");

            readChannel.setStreamHandler(new StreamHandler() {
                @Override
                public void onListen(Object o, EventSink eventSink) {
                    readSink = eventSink;
                }
                @Override
                public void onCancel(Object o) {
                    readSink = null;

                    bluetoothConnection.disconnect();
                }
            });
        }
    }

    /// Provides access to the plugin methods
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

            case "requestEnable":
                if (!bluetoothAdapter.isEnabled()) {
                    Intent intent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                    ActivityCompat.startActivityForResult(registrar.activity(), intent, REQUEST_ENABLE_BLUETOOH, null);
                }
                else {
                    result.success(true);
                }
                break;

            case "requestDisable":
                if (bluetoothAdapter.isEnabled()) {
                    bluetoothAdapter.disable();
                    result.success(true);
                }
                else {
                    result.success(false);
                }
                break;

            case "ensurePermissions":
                ensurePermissions(new EnsurePermissionsCallback() {
                    @Override
                    public void onResult(boolean granted) {
                        result.success(granted);
                    }
                });
                break;

            case "getState":
                result.success(bluetoothAdapter.getState());
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
                            Map<String, Object> entry = new HashMap<>();
                            entry.put("address", device.getAddress());
                            entry.put("name", device.getName());
                            entry.put("type", device.getType());
                            // @TODO ? maybe "connected" - look for each of connection instances etc
                            entry.put("bonded", device.getBondState() == BluetoothDevice.BOND_BONDED);
                            list.add(entry);
                        }

                        result.success(list);
                    }
                });
                break;

            case "isDiscovering":
                result.success(bluetoothAdapter.isDiscovering());
                break;

            case "startDiscovery":
                ensurePermissions(new EnsurePermissionsCallback() {
                    @Override
                    public void onResult(boolean granted) {
                        if (!granted) {
                            result.error("no_permissions", "discovering other devices requires location access permission", null);
                            return;
                        }

                        Log.d(TAG, "Starting discovery");
                        IntentFilter intent = new IntentFilter();
                        intent.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
                        intent.addAction(BluetoothDevice.ACTION_FOUND);
                        registrar.activeContext().registerReceiver(discoveryReceiver, intent);
                        
                        bluetoothAdapter.startDiscovery();
                        
                        result.success(null);
                    }
                });
                break;

            case "cancelDiscovery": 
                Log.d(TAG, "Canceling discovery");
                try {
                    registrar.activeContext().unregisterReceiver(discoveryReceiver);
                }
                catch (IllegalArgumentException ex) {
                    // Ignore `Receiver not registered` exception
                }

                bluetoothAdapter.cancelDiscovery();
                
                if (discoverySink != null) {
                    discoverySink.endOfStream();
                    discoverySink = null;
                }
                
                result.success(null);
                break;

            case "connect":
                if (call.hasArgument("address")) {
                    String address = call.argument("address");
                    AsyncTask.execute(() -> {
                        try {
                            bluetoothConnection.connect(address);
                            registrar.activity().runOnUiThread(new Runnable() {
                                @Override 
                                public void run() {
                                    result.success(null);
                                }
                            });
                        }
                        catch (Exception ex) {
                            registrar.activity().runOnUiThread(new Runnable() {
                                @Override 
                                public void run() {
                                    result.error("connect_error", ex.getMessage(), exceptionToString(ex));
                                }
                            });
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
                        registrar.activity().runOnUiThread(new Runnable() {
                            @Override 
                            public void run() {
                                result.success(null);
                            }
                        });
                    }
                    catch (Exception ex) {
                        registrar.activity().runOnUiThread(new Runnable() {
                            @Override 
                            public void run() {
                                result.error("disconnection_error", ex.getMessage(), exceptionToString(ex));
                            }
                        });
                    }
                });
                break;

            case "write":
                if (call.hasArgument("message")) {
                    String message = call.argument("message");
                    AsyncTask.execute(() -> {
                        try {
                            bluetoothConnection.write(message.getBytes());
                            registrar.activity().runOnUiThread(new Runnable() {
                                @Override 
                                public void run() {
                                    result.success(null);
                                }
                            });
                        }
                        catch (Exception ex) {
                            registrar.activity().runOnUiThread(new Runnable() {
                                @Override 
                                public void run() {
                                    result.error("write_error", ex.getMessage(), exceptionToString(ex));
                                }
                            });
                        }
                    });
                } else {
                    result.error("invalid_argument", "argument 'message' not found", null);
                }
                break;
                
            case "writeBytes":
                if (call.hasArgument("message")) {
                    byte[] message = call.argument("message");
                    AsyncTask.execute(() -> {
                        try {
                            bluetoothConnection.write(message);
                            registrar.activity().runOnUiThread(new Runnable() {
                                @Override 
                                public void run() {
                                    result.success(null);
                                }
                            });
                        }
                        catch (Exception ex) {
                            registrar.activity().runOnUiThread(new Runnable() {
                                @Override 
                                public void run() {
                                    result.error("write_error", ex.getMessage(), exceptionToString(ex));
                                }
                            });
                        }
                    });
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
        switch (requestCode) {
            case REQUEST_COARSE_LOCATION_PERMISSIONS:
                pendingPermissionsEnsureCallbacks.onResult(grantResults[0] == PackageManager.PERMISSION_GRANTED);
                pendingPermissionsEnsureCallbacks = null;
                return true;
        }
        return false;
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case REQUEST_ENABLE_BLUETOOH:
                if (resultCode == 0) { // @TODO - use underlying value of `Activity.RESULT_CANCELED` since we tend to use `androidx` in where I could find the value.
                    pendingResultForActivityResult.success(false);
                }
                else {
                    pendingResultForActivityResult.success(true);
                }
                break;
        }
    }



    /// Helper function to get string out of exception
    private String exceptionToString(Exception ex) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        ex.printStackTrace(pw);
        return sw.toString();
    }
}
