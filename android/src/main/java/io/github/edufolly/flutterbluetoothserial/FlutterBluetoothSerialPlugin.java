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
import java.util.UUID;

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
    private static final String TAG = "FlutterBluePlugin";
    
    // Dart plugin 
    private static final String PLUGIN_NAMESPACE = "flutter_bluetooth_serial";
    private Result pendingResult;
    private EventSink readSink;
    private EventSink statusSink;

    // Permissions
    private static final int REQUEST_COARSE_LOCATION_PERMISSIONS = 1451;

    // 
    private static final UUID MY_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
    private static ConnectionThread connectionThread = null;
    private final Registrar registrar;
    private BluetoothAdapter bluetoothAdapter;



    public static void registerWith(Registrar registrar) {
        final FlutterBluetoothSerialPlugin instance = new FlutterBluetoothSerialPlugin(registrar);
        registrar.addRequestPermissionsResultListener(instance);
    }

    FlutterBluetoothSerialPlugin(Registrar registrar) {
        this.registrar = registrar;
        MethodChannel methodChannel = new MethodChannel(registrar.messenger(), PLUGIN_NAMESPACE + "/methods");
        EventChannel stateChannel = new EventChannel(registrar.messenger(), PLUGIN_NAMESPACE + "/state");
        EventChannel readChannel = new EventChannel(registrar.messenger(), PLUGIN_NAMESPACE + "/read");
        BluetoothManager bluetoothManager = (BluetoothManager) registrar.activity().getSystemService(Context.BLUETOOTH_SERVICE);
        assert bluetoothManager != null;
        this.bluetoothAdapter = bluetoothManager.getAdapter();
        methodChannel.setMethodCallHandler(this);
        stateChannel.setStreamHandler(stateStreamHandler);
        readChannel.setStreamHandler(readResultsHandler);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (bluetoothAdapter == null && !"isAvailable".equals(call.method)) {
            result.error("bluetooth_unavailable", "the device does not have bluetooth", null);
            return;
        }

        final Map<String, Object> arguments = call.arguments();

        switch (call.method) {

            case "isAvailable":
                result.success(bluetoothAdapter != null);
                break;

            case "isOn":
                try {
                    assert bluetoothAdapter != null;
                    result.success(bluetoothAdapter.isEnabled());
                } catch (Exception ex) {
                    result.error("Error", ex.getMessage(), exceptionToString(ex));
                }
                break;

            case "isConnected":
                result.success(connectionThread != null);
                break;

            case "openSettings":
                ContextCompat.startActivity(registrar.activity(), new Intent(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS), null);
                result.success(null);
                break;

            case "getBondedDevices":
                try {

                    if (ContextCompat.checkSelfPermission(registrar.activity(),
                            Manifest.permission.ACCESS_COARSE_LOCATION)
                            != PackageManager.PERMISSION_GRANTED) {

                        ActivityCompat.requestPermissions(registrar.activity(),
                                new String[]{Manifest.permission.ACCESS_COARSE_LOCATION},
                                REQUEST_COARSE_LOCATION_PERMISSIONS);

                        pendingResult = result;
                        break;
                    }
                    getBondedDevices(result);
                } catch (Exception ex) {
                    result.error("Error", ex.getMessage(), exceptionToString(ex));
                }
                break;

            case "connect":
                if (arguments.containsKey("address")) {
                    String address = (String) arguments.get("address");
                    connect(result, address);
                } else {
                    result.error("invalid_argument", "argument 'address' not found", null);
                }
                break;

            case "disconnect":
                disconnect(result);
                break;

            case "write":
                if (arguments.containsKey("message")) {
                    String message = (String) arguments.get("message");
                    write(result, message.getBytes());
                } else {
                    result.error("invalid_argument", "argument 'message' not found", null);
                }
                break;
                
            case "writeBytes":
                if (arguments.containsKey("message")) {
                    byte[] message = (byte[]) arguments.get("message");
                    write(result, message);
                } else {
                    result.error("invalid_argument", "argument 'message' not found", null);
                }
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {

        if (requestCode == REQUEST_COARSE_LOCATION_PERMISSIONS) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                getBondedDevices(pendingResult);
            } else {
                pendingResult.error("no_permissions", "this plugin requires location permissions for scanning", null);
                pendingResult = null;
            }
            return true;
        }
        return false;
    }



    private void getBondedDevices(Result result) {
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

    private String exceptionToString(Exception ex) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        ex.printStackTrace(pw);
        return sw.toString();
    }

    private void connect(Result result, String address) {
        if (connectionThread != null) {
            result.error("connect_error", "already connected", null);
            return;
        }
        
        AsyncTask.execute(() -> {
            try {
                BluetoothDevice device = bluetoothAdapter.getRemoteDevice(address);

                if (device == null) {
                    result.error("connect_error", "device not found", null);
                    return;
                }

                BluetoothSocket socket = device.createRfcommSocketToServiceRecord(MY_UUID);

                if (socket == null) {
                    result.error("connect_error", "socket connection not established", null);
                    return;
                }
                
                // Cancel bt discovery, even though we didn't start it
                bluetoothAdapter.cancelDiscovery();

                try {
                    socket.connect();
                    connectionThread = new ConnectedThread(socket);
                    connectionThread.start();
                    result.success(null);
                } catch(Exception ex) {
                    result.error("connect_error", ex.getMessage(), exceptionToString(ex));
                }
            } catch (Exception ex) {
                result.error("connect_error", ex.getMessage(), exceptionToString(ex));
            }
        });
    }

    private void disconnect(Result result) {

        if (connectionThread == null) {
            result.error("disconnection_error", "not connected", null);
            return;
        }
        AsyncTask.execute(() -> {
            try {
                connectionThread.cancel();
                connectionThread = null;
                result.success(null);
            } catch (Exception ex) {
                result.error("disconnection_error", ex.getMessage(), exceptionToString(ex));
            }
        });
    }

    private void write(Result result, byte[] message) {
        if (connectionThread == null) {
            result.error("write_error", "not connected", null);
            return;
        }

        try {
            connectionThread.write(message);
            result.success(true);
        } catch (Exception ex) {
            result.error("write_error", ex.getMessage(), exceptionToString(ex));
        }
    }

    private class ConnectionThread extends Thread {
        private final BluetoothSocket mmSocket;
        private final InputStream mmInStream;
        private final OutputStream mmOutStream;

        ConnectionThread(BluetoothSocket socket) {
            mmSocket = socket;
            InputStream tmpIn = null;
            OutputStream tmpOut = null;

            try {
                tmpIn = socket.getInputStream();
                tmpOut = socket.getOutputStream();
            } catch (IOException e) {
                e.printStackTrace();
            }

            mmInStream = tmpIn;
            mmOutStream = tmpOut;
        }

        public void run() {
            byte[] buffer = new byte[1024];
            int bytes;

            while (true) {
                try {
                    bytes = mmInStream.read(buffer);
                    readSink.success(new String(buffer, 0, bytes));
                } catch (NullPointerException e) {
                    break;
                } catch (IOException e) {
                    break;
                }
            }
        }

        public void write(byte[] bytes) {
            try {
                mmOutStream.write(bytes);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        public void cancel() {
            try {
                mmOutStream.flush();
                mmOutStream.close();

                mmInStream.close();

                mmSocket.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     *
     */
    private final StreamHandler stateStreamHandler = new StreamHandler() {

        private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                final String action = intent.getAction();

                Log.d(TAG, action);

                if (BluetoothAdapter.ACTION_STATE_CHANGED.equals(action)) {
                    connectionThread = null;
                    statusSink.success(intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, -1));
                } else if (BluetoothDevice.ACTION_ACL_CONNECTED.equals(action)) {
                    statusSink.success(1);
                } else if (BluetoothDevice.ACTION_ACL_DISCONNECTED.equals(action)) {
                    connectionThread = null;
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

    /**
     *
     */
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
