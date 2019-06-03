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
import java.util.Arrays;
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

import static android.bluetooth.BluetoothDevice.BOND_BONDED;
import static android.bluetooth.BluetoothDevice.BOND_BONDING;
import static android.bluetooth.BluetoothDevice.BOND_NONE;


public class FlutterBluetoothSerialPlugin implements MethodCallHandler,
        RequestPermissionsResultListener {

    private static final String TAG = "FlutterBluePlugin";
    private static final String NAMESPACE = "flutter_bluetooth_serial";
    private static final int REQUEST_COARSE_LOCATION_PERMISSIONS = 1451;
    private static final UUID MY_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
    private static ConnectedThread THREAD = null;
    private final Registrar registrar;
    private BluetoothAdapter mBluetoothAdapter;

    private Result pendingResult;

    private EventSink readSink;
    private EventSink readSinkByte;
    private EventSink statusSink;
    private String currentMethodCall = "";

    public static void registerWith(Registrar registrar) {
        final FlutterBluetoothSerialPlugin instance = new FlutterBluetoothSerialPlugin(registrar);
        registrar.addRequestPermissionsResultListener(instance);
    }

    FlutterBluetoothSerialPlugin(Registrar registrar) {
        this.registrar = registrar;
        MethodChannel channel = new MethodChannel(registrar.messenger(), NAMESPACE + "/methods");
        EventChannel stateChannel = new EventChannel(registrar.messenger(), NAMESPACE + "/state");
        EventChannel readChannel = new EventChannel(registrar.messenger(), NAMESPACE + "/read");
        EventChannel readByteChannel = new EventChannel(registrar.messenger(), NAMESPACE + "/readByte");
        BluetoothManager mBluetoothManager = (BluetoothManager) registrar.activity()
                .getSystemService(Context.BLUETOOTH_SERVICE);
        assert mBluetoothManager != null;
        this.mBluetoothAdapter = mBluetoothManager.getAdapter();
        channel.setMethodCallHandler(this);
        stateChannel.setStreamHandler(stateStreamHandler);
        readChannel.setStreamHandler(readResultsHandler);
        readByteChannel.setStreamHandler(readResultsByteHandler);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (mBluetoothAdapter == null && !"isAvailable".equals(call.method)) {
            result.error("bluetooth_unavailable", "the device does not have bluetooth", null);
            return;
        }

        final Map<String, Object> arguments = call.arguments();

        currentMethodCall = call.method;
        switch (call.method) {

            case "isAvailable":
                result.success(mBluetoothAdapter != null);
                break;

            case "isOn":
                try {
                    assert mBluetoothAdapter != null;
                    result.success(mBluetoothAdapter.isEnabled());
                } catch (Exception ex) {
                    result.error("Error", ex.getMessage(), exceptionToString(ex));
                }
                break;

            case "isBonded":
                if (!arguments.containsKey("address")) {
                    result.error("invalid_argument", "argument 'device' not found", null);
                }
                result.success(isBonded(mBluetoothAdapter.getRemoteDevice((String) arguments.get("address"))));
                break;

            case "isConnected":
                result.success(THREAD != null);
                break;

            case "openSettings":
                ContextCompat.startActivity(registrar.activity(),
                        new Intent(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS),
                        null);
                result.success(true);
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
            case "bondDevice":
                try {
                    if (arguments.containsKey("address")) {
                        byte[] pin = null;
                        if(arguments.containsKey("pin")) {
                            pin = ((String) arguments.get("pin")).getBytes();
                        }

                        bondDevice(result, mBluetoothAdapter.getRemoteDevice((String) arguments.get("address")), pin);
                    } else {
                        result.error("invalid_argument", "argument 'device' not found", null);
                    }
                    break;
                }
                catch (Exception ex) {
                    result.error("Error", ex.getMessage(), exceptionToString(ex));
                }

                break;
            case "scanDevices":
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

                    getAllDevices(result);

                } catch (Exception ex) {
                    result.error("Error", ex.getMessage(), exceptionToString(ex));
                }

                break;

           case "connect":
                try {
                    if (arguments.containsKey("address")) {
                        String address = (String) arguments.get("address");
                        connect(result, address);
                    } else {
                        result.error("invalid_argument", "argument 'address' not found", null);
                    }
                    break;                    
                }
                catch (Exception ex) {
                    result.error("Error", ex.getMessage(), exceptionToString(ex));
                }

                break;

            case "disconnect":
                disconnect(result);
                break;

            case "write":
                if (arguments.containsKey("message")) {
                    String message = (String) arguments.get("message");
                    write(result, message);
                } else {
                    result.error("invalid_argument", "argument 'message' not found", null);
                }
                break;

            case "writeBytes":
                if (arguments.containsKey("message")) {
                    byte[] message = (byte[]) arguments.get("message");
                    writeBytes(result, message);
                } else {
                    result.error("invalid_argument", "argument 'message' not found", null);
                }
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * @param requestCode  requestCode
     * @param permissions  permissions
     * @param grantResults grantResults
     * @return boolean
     */
    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions,
                                              int[] grantResults) {

        if (requestCode == REQUEST_COARSE_LOCATION_PERMISSIONS) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                if (currentMethodCall == "getBondedDevices")
                    getBondedDevices(pendingResult);
                else
                    getAllDevices(pendingResult);
            } else {
                pendingResult.error("no_permissions",
                        "this plugin requires location permissions for scanning", null);
                pendingResult = null;
            }
            return true;
        }
        return false;
    }

    /**
     * @param result result
     */
    private void getBondedDevices(Result result) {

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
     * @param result result
     */
    private void getAllDevices(Result result) {
        List<Map<String, Object>> list = new ArrayList<>();
        final BroadcastReceiver mReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                final String action = intent.getAction();

                Log.d(TAG, action);

                if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                    BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                    Map<String, Object> ret = new HashMap<>();
                    ret.put("address", device.getAddress());
                    ret.put("name", device.getName() == null ? "Unknown" : device.getName());
                    ret.put("type", device.getType());
                    list.add(ret);
                } else if (BluetoothAdapter.ACTION_DISCOVERY_FINISHED.equals(action)) {
                    result.success(list);
                    registrar.activeContext().unregisterReceiver(this);

                }
            }
        };
        registrar.activeContext().registerReceiver(mReceiver, new IntentFilter(BluetoothDevice.ACTION_FOUND));
        registrar.activeContext().registerReceiver(mReceiver, new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_FINISHED));
        mBluetoothAdapter.startDiscovery();


    }

    private String exceptionToString(Exception ex) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        ex.printStackTrace(pw);
        return sw.toString();
    }

    /**
     *
     * @param result result
     * @param device device to bond
     * @param pin pin code to bond
     */
    private void bondDevice(Result result, BluetoothDevice device, byte[] pin) {
        switch(device.getBondState()) {
            case BOND_BONDING:
                result.error("bond error", "already bonding", null);
                return;
            case BOND_BONDED:
                result.error("bond error", "already bonded", null);
                return;
        }

        //bond state is BOND_NONE

        if(pin != null) {
            final BroadcastReceiver mReceiver = new BroadcastReceiver() {
                @Override
                public void onReceive(Context context, Intent intent) {
                    if (BluetoothDevice.ACTION_PAIRING_REQUEST.equals(intent.getAction())) {
                        BluetoothDevice bluetoothDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                        bluetoothDevice.setPin(pin);
                        abortBroadcast();
                        Log.e(TAG,"Auto-entering pin: " + new String(pin));
                        bluetoothDevice.createBond();
                        Log.e(TAG,"pin entered and request sent...");
                        registrar.activeContext().unregisterReceiver(this);
                    }
                }
            };
            final IntentFilter pairingRequestFilter = new IntentFilter(BluetoothDevice.ACTION_PAIRING_REQUEST);
            pairingRequestFilter.setPriority(IntentFilter.SYSTEM_HIGH_PRIORITY - 1);

            registrar.activeContext().registerReceiver(mReceiver, pairingRequestFilter);
        }



       if(device.createBond()) {
           result.success(true);
       } else {
           result.error("bond_error", "error starting bond", null);
       }
    }

    private boolean isBonded(BluetoothDevice device) {
        return device.getBondState() == BOND_BONDED;
    }

    /**
     * @param result  result
     * @param address address
     */
    private void connect(Result result, String address) {

        if (THREAD != null) {
            result.error("connect_error", "already connected", null);
            return;
        }
        AsyncTask.execute(() -> {
            try {
                BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(address);

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
                mBluetoothAdapter.cancelDiscovery();

                try {
                    socket.connect();
                    THREAD = new ConnectedThread(socket);
                    THREAD.start();
                    result.success(true);
                } catch (Exception ex) {
                    Log.e(TAG, ex.getMessage(), ex);
                    result.error("connect_error", ex.getMessage(), exceptionToString(ex));
                }
            } catch (Exception ex) {
                Log.e(TAG, ex.getMessage(), ex);
                result.error("connect_error", ex.getMessage(), exceptionToString(ex));
            }
        });
    }

    /**
     * @param result result
     */
    private void disconnect(Result result) {

        if (THREAD == null) {
            result.error("disconnection_error", "not connected", null);
            return;
        }
        AsyncTask.execute(() -> {
            try {
                THREAD.cancel();
                THREAD = null;
                result.success(true);
            } catch (Exception ex) {
                Log.e(TAG, ex.getMessage(), ex);
                result.error("disconnection_error", ex.getMessage(), exceptionToString(ex));
            }
        });
    }

    /**
     * @param result  result
     * @param message message
     */
    private void write(Result result, String message) {
        if (THREAD == null) {
            result.error("write_error", "not connected", null);
            return;
        }

        try {
            THREAD.write(message.getBytes());
            result.success(true);
        } catch (Exception ex) {
            Log.e(TAG, ex.getMessage(), ex);
            result.error("write_error", ex.getMessage(), exceptionToString(ex));
        }
    }

    private void writeBytes(Result result, byte[] message) {
        if (THREAD == null) {
            result.error("write_error", "not connected", null);
            return;
        }

        try {
            THREAD.write(message);
            result.success(true);
        } catch (Exception ex) {
            Log.e(TAG, ex.getMessage(), ex);
            result.error("write_error", ex.getMessage(), exceptionToString(ex));
        }
    }


    /**
     *
     */
    private class ConnectedThread extends Thread {
        private final BluetoothSocket mmSocket;
        private final InputStream mmInStream;
        private final OutputStream mmOutStream;

        ConnectedThread(BluetoothSocket socket) {
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
                    if(readSink != null) readSink.success(new String(buffer, 0, bytes));
                    if(readSinkByte != null) readSinkByte.success(Arrays.copyOf(buffer, bytes));
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
                    THREAD = null;
                    if(statusSink != null) statusSink.success(intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, -1));
                } else if (BluetoothDevice.ACTION_ACL_CONNECTED.equals(action)) {
                    if(statusSink != null) statusSink.success(1);
                } else if (BluetoothDevice.ACTION_ACL_DISCONNECTED.equals(action)) {
                    THREAD = null;
                    if(statusSink != null) statusSink.success(0);
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

    private final StreamHandler readResultsByteHandler = new StreamHandler() {
        @Override
        public void onListen(Object o, EventSink eventSink) {
            readSinkByte = eventSink;
        }

        @Override
        public void onCancel(Object o) {
            readSinkByte = null;
        }
    };
}
