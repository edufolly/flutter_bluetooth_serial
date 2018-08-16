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
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
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
    private static final String NAMESPACE = "flutter_bluetooth_serial";
    private static final int REQUEST_COARSE_LOCATION_PERMISSIONS = 1451;
    private static final UUID MY_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
    private final Registrar registrar;
    private final MethodChannel channel;
    private final EventChannel stateChannel;
    private final EventChannel readChannel;
    private final BluetoothManager mBluetoothManager;
    private BluetoothAdapter mBluetoothAdapter;

    // Pending call and result for startScan, in the case where permissions are needed
    private MethodCall pendingCall;
    private Result pendingResult;

    public static void registerWith(Registrar registrar) {
        final FlutterBluetoothSerialPlugin instance = new FlutterBluetoothSerialPlugin(registrar);
        registrar.addRequestPermissionsResultListener(instance);
    }

    FlutterBluetoothSerialPlugin(Registrar registrar) {
        this.registrar = registrar;
        this.channel = new MethodChannel(registrar.messenger(), NAMESPACE + "/methods");
        this.stateChannel = new EventChannel(registrar.messenger(), NAMESPACE + "/state");
        this.readChannel = new EventChannel(registrar.messenger(), NAMESPACE + "/read");
        this.mBluetoothManager = (BluetoothManager) registrar.activity()
                .getSystemService(Context.BLUETOOTH_SERVICE);
        this.mBluetoothAdapter = mBluetoothManager.getAdapter();
        channel.setMethodCallHandler(this);
        stateChannel.setStreamHandler(stateStreamHandler);
        readChannel.setStreamHandler(readResultsHandler);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (mBluetoothAdapter == null && !"isAvailable".equals(call.method)) {
            result.error("bluetooth_unavailable", "the device does not have bluetooth", null);
            return;
        }

        final Map<String, Object> arguments = call.arguments();

        switch (call.method) {

            case "isAvailable":
                result.success(mBluetoothAdapter != null);
                break;

            case "isOn":
                result.success(mBluetoothAdapter.isEnabled());
                break;

            case "getBondedDevices":
                try {

                    if (ContextCompat.checkSelfPermission(registrar.activity(),
                            Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {

                        ActivityCompat.requestPermissions(registrar.activity(),
                                new String[]{Manifest.permission.ACCESS_COARSE_LOCATION},
                                REQUEST_COARSE_LOCATION_PERMISSIONS);

                        pendingCall = call;
                        pendingResult = result;
                        break;
                    }

                    getBondedDevices(call, result);

                } catch (Exception ex) {
                    result.error("Erro", ex.getMessage(), ex);
                }

                break;

            case "connect":
                if (arguments.containsKey("address")) {
                    String address = (String) arguments.get("address");
                    connect(result, address);
                } else {
                    // TODO - Error
                    result.error("invalid_argument", "argument 'address' not found", null);
                }
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * @param requestCode
     * @param permissions
     * @param grantResults
     * @return
     */
    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions,
                                              int[] grantResults) {

        if (requestCode == REQUEST_COARSE_LOCATION_PERMISSIONS) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                //  TODO - Continue...
                getBondedDevices(pendingCall, pendingResult);
            } else {
                pendingResult.error("no_permissions",
                        "this plugin requires location permissions for scanning", null);
                pendingResult = null;
                pendingCall = null;
            }
            return true;
        }
        return false;
    }

    /**
     * @param call
     * @param result
     */
    private void getBondedDevices(MethodCall call, Result result) {

        List<Map<String, Object>> list = new ArrayList<>();

        for (BluetoothDevice device : mBluetoothAdapter.getBondedDevices()) {
            Map<String, Object> ret = new HashMap<>();
            ret.put("address", device.getAddress());
            ret.put("name", device.getName());
            ret.put("type", device.getType());
            list.add(ret);
        }

        result.success(list);
    }

    /**
     * @param result
     * @param address
     */
    private void connect(Result result, String address) {
        try {
            Log.d(TAG, address);
            BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(address);

            if (device == null) {
                result.error("connect_error", "device not found", null);
            }


            assert device != null;

            BluetoothSocket socket = device.createRfcommSocketToServiceRecord(MY_UUID);

            if (socket == null) {
                result.error("connect_error", "socket connection not established", null);
            }

            assert socket != null;

            socket.connect();

//            while (!socket.isConnected()) {
//                Log.i(TAG, "Esperando...");
//            }

            Log.d(TAG, "Conectado.");

            new ConnectedThread(socket).start();

            result.success(true);
        } catch (Exception ex) {
            Log.e(TAG, ex.getMessage(), ex);
            result.error("connect_error", ex.getMessage(), ex);
        }
    }

    /**
     *
     */
    private class ConnectedThread extends Thread {
        private final BluetoothSocket mmSocket;
        private final InputStream mmInStream;
        private final OutputStream mmOutStream;

        public ConnectedThread(BluetoothSocket socket) {
            mmSocket = socket;
            InputStream tmpIn = null;
            OutputStream tmpOut = null;

            // Get the input and output streams, using temp objects because
            // member streams are final
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
            byte[] buffer = new byte[1024];  // buffer store for the stream
            int bytes; // bytes returned from read()

            // Keep listening to the InputStream until an exception occurs
            while (true) {
                try {
                    // Read from the InputStream
                    bytes = mmInStream.read(buffer);
                    // Send the obtained bytes to the UI activity
//                    mHandler.obtainMessage(MESSAGE_READ, bytes, -1, buffer)
//                            .sendToTarget();

                    Log.i(TAG, "(" + bytes + ") " + new String(buffer, 0, bytes));
                    readResultsSink.success(new String(buffer, 0, bytes));
                } catch (IOException e) {
                    break;
                }
            }
        }

        /* Call this from the main activity to send data to the remote device */
        public void write(byte[] bytes) {
            try {
                mmOutStream.write(bytes);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        /* Call this from the main activity to shutdown the connection */
        public void cancel() {
            try {
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
        private EventSink sink;

        private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                final String action = intent.getAction();

                if (action.equals(BluetoothAdapter.ACTION_STATE_CHANGED)) {

                    final int state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE,
                            BluetoothAdapter.ERROR);

                    switch (state) {
                        case BluetoothAdapter.STATE_OFF:
                            sink.success("STATE_OFF");
                            break;
                        case BluetoothAdapter.STATE_TURNING_OFF:
                            sink.success("STATE_TURNING_OFF");
                            break;
                        case BluetoothAdapter.STATE_ON:
                            sink.success("STATE_ON");
                            break;
                        case BluetoothAdapter.STATE_TURNING_ON:
                            sink.success("STATE_TURNING_ON");
                            break;
                    }
                }
            }
        };

        @Override
        public void onListen(Object o, EventSink eventSink) {
            sink = eventSink;
            IntentFilter filter = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
            registrar.activity().registerReceiver(mReceiver, filter);
        }

        @Override
        public void onCancel(Object o) {
            sink = null;
            registrar.activity().unregisterReceiver(mReceiver);
        }
    };

    /**
     *
     */
    private EventSink readResultsSink;
    private final StreamHandler readResultsHandler = new StreamHandler() {
        @Override
        public void onListen(Object o, EventChannel.EventSink eventSink) {
            readResultsSink = eventSink;
        }

        @Override
        public void onCancel(Object o) {
            readResultsSink = null;
        }
    };
}
