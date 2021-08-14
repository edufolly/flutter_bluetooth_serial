package io.github.edufolly.flutterbluetoothserial;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import android.util.Log;
import android.util.SparseArray;
import android.os.AsyncTask;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Enumeration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.net.NetworkInterface;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class FlutterBluetoothSerialPlugin implements FlutterPlugin, ActivityAware {
    // Plugin
    private static final String TAG = "FlutterBluePlugin";
    private static final String PLUGIN_NAMESPACE = "flutter_bluetooth_serial";
    private MethodChannel methodChannel;
    private Result pendingResultForActivityResult = null;

    // Permissions and request constants
    private static final int REQUEST_COARSE_LOCATION_PERMISSIONS = 1451;
    private static final int REQUEST_ENABLE_BLUETOOTH = 1337;
    private static final int REQUEST_DISCOVERABLE_BLUETOOTH = 2137;

    // General Bluetooth
    private BluetoothAdapter bluetoothAdapter;

    // State
    private final BroadcastReceiver stateReceiver;
    private EventSink stateSink;

    // Pairing requests
    private final BroadcastReceiver pairingRequestReceiver;
    private boolean isPairingRequestHandlerSet = false;
    private BroadcastReceiver bondStateBroadcastReceiver = null;

    private EventSink discoverySink;
    private final BroadcastReceiver discoveryReceiver;

    // Connections
    /// Contains all active connections. Maps ID of the connection with plugin data channels. 
    private final SparseArray<BluetoothConnectionWrapper> connections = new SparseArray<>(2);

    /// Last ID given to any connection, used to avoid duplicate IDs 
    private int lastConnectionId = 0;
    private Activity activity;
    private BinaryMessenger messenger;
    private Context activeContext;

    /// Constructs the plugin instance
    public FlutterBluetoothSerialPlugin() {

        // State
        stateReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (stateSink == null) {
                    return;
                }

                final String action = intent.getAction();
                switch (action) {
                    case BluetoothAdapter.ACTION_STATE_CHANGED:
                        // Disconnect all connections
                        int size = connections.size();
                        for (int i = 0; i < size; i++) {
                            BluetoothConnection connection = connections.valueAt(i);
                            connection.disconnect();
                        }
                        connections.clear();

                        stateSink.success(intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothDevice.ERROR));
                        break;
                }
            }
        };


        // Pairing requests
        pairingRequestReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                switch (intent.getAction()) {
                    case BluetoothDevice.ACTION_PAIRING_REQUEST:
                        final BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                        final int pairingVariant = intent.getIntExtra(BluetoothDevice.EXTRA_PAIRING_VARIANT, BluetoothDevice.ERROR);
                        Log.d(TAG, "Pairing request (variant " + pairingVariant + ") incoming from " + device.getAddress());
                        switch (pairingVariant) {
                            case BluetoothDevice.PAIRING_VARIANT_PIN:
                                // Simplest method - 4 digit number
                            {
                                final BroadcastReceiver.PendingResult broadcastResult = this.goAsync();

                                Map<String, Object> arguments = new HashMap<String, Object>();
                                arguments.put("address", device.getAddress());
                                arguments.put("variant", pairingVariant);

                                methodChannel.invokeMethod("handlePairingRequest", arguments, new MethodChannel.Result() {
                                    @Override
                                    public void success(Object handlerResult) {
                                        Log.d(TAG, handlerResult.toString());
                                        if (handlerResult instanceof String) {
                                            try {
                                                final String passkeyString = (String) handlerResult;
                                                final byte[] passkey = passkeyString.getBytes();
                                                Log.d(TAG, "Trying to set passkey for pairing to " + passkeyString);
                                                device.setPin(passkey);
                                                broadcastResult.abortBroadcast();
                                            } catch (Exception ex) {
                                                Log.e(TAG, ex.getMessage());
                                                ex.printStackTrace();
                                                // @TODO , passing the error
                                                //result.error("bond_error", "Setting passkey for pairing failed", exceptionToString(ex));
                                            }
                                        } else {
                                            Log.d(TAG, "Manual pin pairing in progress");
                                            //Intent intent = new Intent(BluetoothAdapter.ACTION_PAIRING_REQUEST);
                                            //intent.putExtra(BluetoothDevice.EXTRA_DEVICE, device);
                                            //intent.putExtra(BluetoothDevice.EXTRA_PAIRING_VARIANT, pairingVariant)
                                            ActivityCompat.startActivity(activity, intent, null);
                                        }
                                        broadcastResult.finish();
                                    }

                                    @Override
                                    public void notImplemented() {
                                        throw new UnsupportedOperationException();
                                    }

                                    @Override
                                    public void error(String code, String message, Object details) {
                                        throw new UnsupportedOperationException();
                                    }
                                });
                                break;
                            }

                            // Note: `BluetoothDevice.PAIRING_VARIANT_PASSKEY` seems to be unsupported anyway... Probably is abandoned.
                            // See https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/bluetooth/BluetoothDevice.java#1528

                            case BluetoothDevice.PAIRING_VARIANT_PASSKEY_CONFIRMATION:
                                // Displayed passkey on the other device should be the same as received here.
                            case 3: //case BluetoothDevice.PAIRING_VARIANT_CONSENT: // @TODO , Symbol not found?
                                // The simplest, but much less secure method - just yes or no, without any auth.
                                // Consent type can use same code as passkey confirmation since passed passkey,
                                // which is 0 or error at the moment, should not be used anyway by common code.
                            {
                                final int pairingKey = intent.getIntExtra(BluetoothDevice.EXTRA_PAIRING_KEY, BluetoothDevice.ERROR);

                                Map<String, Object> arguments = new HashMap<String, Object>();
                                arguments.put("address", device.getAddress());
                                arguments.put("variant", pairingVariant);
                                arguments.put("pairingKey", pairingKey);

                                final BroadcastReceiver.PendingResult broadcastResult = this.goAsync();
                                methodChannel.invokeMethod("handlePairingRequest", arguments, new MethodChannel.Result() {
                                    @SuppressLint("MissingPermission")
                                    @Override
                                    public void success(Object handlerResult) {
                                        if (handlerResult instanceof Boolean) {
                                            try {
                                                final boolean confirm = (Boolean) handlerResult;
                                                Log.d(TAG, "Trying to set pairing confirmation to " + confirm + " (key: " + pairingKey + ")");
                                                // @WARN `BLUETOOTH_PRIVILEGED` permission required, but might be
                                                // unavailable for thrid party apps on newer versions of Androids.
                                                device.setPairingConfirmation(confirm);
                                                broadcastResult.abortBroadcast();
                                            } catch (Exception ex) {
                                                Log.e(TAG, ex.getMessage());
                                                ex.printStackTrace();
                                                // @TODO , passing the error
                                                //result.error("bond_error", "Auto-confirming pass key failed", exceptionToString(ex));
                                            }
                                        } else {
                                            Log.d(TAG, "Manual passkey confirmation pairing in progress (key: " + pairingKey + ")");
                                            ActivityCompat.startActivity(activity, intent, null);
                                        }
                                        broadcastResult.finish();
                                    }

                                    @Override
                                    public void notImplemented() {
                                        throw new UnsupportedOperationException();
                                    }

                                    @Override
                                    public void error(String code, String message, Object details) {
                                        Log.e(TAG, code + " " + message);
                                        throw new UnsupportedOperationException();
                                    }
                                });
                                break;
                            }

                            case 4: //case BluetoothDevice.PAIRING_VARIANT_DISPLAY_PASSKEY: // @TODO , Symbol not found?
                                // This pairing method requires to enter the generated and displayed pairing key
                                // on the remote device. It looks like basic asymmetric cryptography was used.
                            case 5: //case BluetoothDevice.PAIRING_VARIANT_DISPLAY_PIN: // @TODO , Symbol not found?
                                // Same as previous, but for 4 digit pin.
                            {
                                final int pairingKey = intent.getIntExtra(BluetoothDevice.EXTRA_PAIRING_KEY, BluetoothDevice.ERROR);

                                Map<String, Object> arguments = new HashMap<String, Object>();
                                arguments.put("address", device.getAddress());
                                arguments.put("variant", pairingVariant);
                                arguments.put("pairingKey", pairingKey);

                                methodChannel.invokeMethod("handlePairingRequest", arguments);
                                break;
                            }

                            // Note: `BluetoothDevice.PAIRING_VARIANT_OOB_CONSENT` seems to be unsupported for now, at least at master branch of Android.
                            // See https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/bluetooth/BluetoothDevice.java#1559

                            // Note: `BluetoothDevice.PAIRING_VARIANT_PIN_16_DIGITS ` seems to be unsupported for now, at least at master branch of Android.
                            // See https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/bluetooth/BluetoothDevice.java#1559

                            default:
                                // Only log other pairing variants
                                Log.w(TAG, "Unknown pairing variant: " + pairingVariant);
                                break;
                        }
                        break;

                    default:
                        // Ignore other actions
                        break;
                }
            }
        };

        // Discovery
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
                        discoveryResult.put("isConnected", checkIsDeviceConnected(device));
                        discoveryResult.put("bondState", device.getBondState());
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
                        } catch (IllegalArgumentException ex) {
                            // Ignore `Receiver not registered` exception
                        }

                        bluetoothAdapter.cancelDiscovery();

                        if (discoverySink != null) {
                            discoverySink.endOfStream();
                            discoverySink = null;
                        }
                        break;

                    default:
                        // Ignore.
                        break;
                }
            }
        };

    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        Log.v("FlutterBluetoothSerial", "Attached to engine");
//        if (true) throw new RuntimeException("FlutterBluetoothSerial Attached to engine");
        messenger = binding.getBinaryMessenger();

        methodChannel = new MethodChannel(messenger, PLUGIN_NAMESPACE + "/methods");
        methodChannel.setMethodCallHandler( new FlutterBluetoothSerialMethodCallHandler() );

        EventChannel stateChannel = new EventChannel(messenger, PLUGIN_NAMESPACE + "/state");

        stateChannel.setStreamHandler(new StreamHandler() {
            @Override
            public void onListen(Object o, EventSink eventSink) {
                stateSink = eventSink;

                activeContext.registerReceiver(stateReceiver, new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED));
            }

            @Override
            public void onCancel(Object o) {
                stateSink = null;
                try {
                    activeContext.unregisterReceiver(stateReceiver);
                } catch (IllegalArgumentException ex) {
                    // Ignore `Receiver not registered` exception
                }
            }
        });

        // Discovery
        EventChannel discoveryChannel = new EventChannel(messenger, PLUGIN_NAMESPACE + "/discovery");

        // Ignore `Receiver not registered` exception
        StreamHandler discoveryStreamHandler = new StreamHandler() {
            @Override
            public void onListen(Object o, EventSink eventSink) {
                discoverySink = eventSink;
            }

            @Override
            public void onCancel(Object o) {
                Log.d(TAG, "Canceling discovery (stream closed)");
                try {
                    activeContext.unregisterReceiver(discoveryReceiver);
                } catch (IllegalArgumentException ex) {
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

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        if (methodChannel != null) methodChannel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
//        if (true) throw new RuntimeException("FlutterBluetoothSerial Attached to activity");
        this.activity = binding.getActivity();
        BluetoothManager bluetoothManager = (BluetoothManager) activity.getSystemService(Context.BLUETOOTH_SERVICE);
        assert bluetoothManager != null;

        this.bluetoothAdapter = bluetoothManager.getAdapter();

        binding.addActivityResultListener(
                (requestCode, resultCode, data) -> {
                    switch (requestCode) {
                        case REQUEST_ENABLE_BLUETOOTH:
                            // @TODO - used underlying value of `Activity.RESULT_CANCELED` since we tend to use `androidx` in which I were not able to find the constant.
                            if (pendingResultForActivityResult != null) {
                                pendingResultForActivityResult.success(resultCode != 0);
                            }
                            return true;

                        case REQUEST_DISCOVERABLE_BLUETOOTH:
                            pendingResultForActivityResult.success(resultCode == 0 ? -1 : resultCode);
                            return true;

                        default:
                            return false;
                    }
                }
        );
        binding.addRequestPermissionsResultListener(
                (requestCode, permissions, grantResults) -> {
                    switch (requestCode) {
                        case REQUEST_COARSE_LOCATION_PERMISSIONS:
                            pendingPermissionsEnsureCallbacks.onResult(grantResults[0] == PackageManager.PERMISSION_GRANTED);
                            pendingPermissionsEnsureCallbacks = null;
                            return true;
                    }
                    return false;
                }
        );
        activity = binding.getActivity();
        activeContext = binding.getActivity().getApplicationContext();

    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }


    public void onDetachedFromActivity() {

    }


    private interface EnsurePermissionsCallback {
        void onResult(boolean granted);
    }

    EnsurePermissionsCallback pendingPermissionsEnsureCallbacks = null;

    private void ensurePermissions(EnsurePermissionsCallback callbacks) {
        if (
                ContextCompat.checkSelfPermission(activity,
                        Manifest.permission.ACCESS_COARSE_LOCATION)
                        != PackageManager.PERMISSION_GRANTED
                        || ContextCompat.checkSelfPermission(activity,
                        Manifest.permission.ACCESS_FINE_LOCATION)
                        != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(activity,
                    new String[]{Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION},
                    REQUEST_COARSE_LOCATION_PERMISSIONS);

            pendingPermissionsEnsureCallbacks = callbacks;
        } else {
            callbacks.onResult(true);
        }
    }


    /// Helper function to get string out of exception
    static private String exceptionToString(Exception ex) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        ex.printStackTrace(pw);
        return sw.toString();
    }

    /// Helper function to check is device connected
    static private boolean checkIsDeviceConnected(BluetoothDevice device) {
        try {
            java.lang.reflect.Method method;
            method = device.getClass().getMethod("isConnected");
            return (boolean) (Boolean) method.invoke(device);
        } catch (Exception ex) {
            return false;
        }
    }


    /// Helper wrapper class for `BluetoothConnection`
    private class BluetoothConnectionWrapper extends BluetoothConnection {
        private final int id;

        protected EventSink readSink;

        protected EventChannel readChannel;

        private final BluetoothConnectionWrapper self = this;

        public BluetoothConnectionWrapper(int id, BluetoothAdapter adapter) {
            super(adapter);
            this.id = id;

            readChannel = new EventChannel(messenger, PLUGIN_NAMESPACE + "/read/" + id);
            // If canceled by local, disconnects - in other case, by remote, does nothing
            // True dispose
            StreamHandler readStreamHandler = new StreamHandler() {
                @Override
                public void onListen(Object o, EventSink eventSink) {
                    readSink = eventSink;
                }

                @Override
                public void onCancel(Object o) {
                    // If canceled by local, disconnects - in other case, by remote, does nothing
                    self.disconnect();

                    // True dispose
                    AsyncTask.execute(() -> {
                        readChannel.setStreamHandler(null);
                        connections.remove(id);

                        Log.d(TAG, "Disconnected (id: " + id + ")");
                    });
                }
            };
            readChannel.setStreamHandler(readStreamHandler);
        }

        @Override
        protected void onRead(byte[] buffer) {
            activity.runOnUiThread(() -> {
                if (readSink != null) {
                    readSink.success(buffer);
                }
            });
        }

        @Override
        protected void onDisconnected(boolean byRemote) {
            activity.runOnUiThread(() -> {
                if (byRemote) {
                    Log.d(TAG, "onDisconnected by remote (id: " + id + ")");
                    if (readSink != null) {
                        readSink.endOfStream();
                        readSink = null;
                    }
                } else {
                    Log.d(TAG, "onDisconnected by local (id: " + id + ")");
                }
            });
        }
    }

    private class FlutterBluetoothSerialMethodCallHandler implements MethodCallHandler {
        /// Provides access to the plugin methods
        @Override
        public void onMethodCall(MethodCall call, Result result) {
            if (bluetoothAdapter == null) {
                if ("isAvailable".equals(call.method)) {
                    result.success(false);
                } else {
                    result.error("bluetooth_unavailable", "bluetooth is not available", null);
                }
                return;
            }

            methodCallDispatching:
            switch (call.method) {
                ////////////////////////////////////////
                /* Adapter settings and general */
                case "isAvailable":
                    result.success(true);
                    break;

                case "isOn":
                case "isEnabled":
                    result.success(bluetoothAdapter.isEnabled());
                    break;

                case "openSettings":
                    ContextCompat.startActivity(activity, new Intent(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS), null);
                    result.success(null);
                    break;

                case "requestEnable":
                    if (!bluetoothAdapter.isEnabled()) {
                        pendingResultForActivityResult = result;
                        Intent intent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                        ActivityCompat.startActivityForResult(activity, intent, REQUEST_ENABLE_BLUETOOTH, null);
                    } else {
                        result.success(true);
                    }
                    break;

                case "requestDisable":
                    if (bluetoothAdapter.isEnabled()) {
                        bluetoothAdapter.disable();
                        result.success(true);
                    } else {
                        result.success(false);
                    }
                    break;

                case "ensurePermissions":
                    ensurePermissions(result::success);
                    break;

                case "getState":
                    result.success(bluetoothAdapter.getState());
                    break;

                case "getAddress": {
                    String address = bluetoothAdapter.getAddress();

                    if (address.equals("02:00:00:00:00:00")) {
                        Log.w(TAG, "Local Bluetooth MAC address is hidden by system, trying other options...");

                        do {
                            Log.d(TAG, "Trying to obtain address using Settings Secure bank");
                            try {
                                // Requires `LOCAL_MAC_ADDRESS` which could be unavailible for third party applications...
                                String value = android.provider.Settings.Secure.getString(activeContext.getContentResolver(), "bluetooth_address");
                                if (value == null) {
                                    throw new NullPointerException("null returned, might be no permissions problem");
                                }
                                address = value;
                                break;
                            } catch (Exception ex) {
                                // Ignoring failure (since it isn't critical API for most applications)
                                Log.d(TAG, "Obtaining address using Settings Secure bank failed");
                                //result.error("hidden_address", "obtaining address using Settings Secure bank failed", exceptionToString(ex));
                            }

                            Log.d(TAG, "Trying to obtain address using reflection against internal Android code");
                            try {
                                // This will most likely work, but well, it is unsafe
                                java.lang.reflect.Field mServiceField;
                                mServiceField = bluetoothAdapter.getClass().getDeclaredField("mService");
                                mServiceField.setAccessible(true);

                                Object bluetoothManagerService = mServiceField.get(bluetoothAdapter);
                                if (bluetoothManagerService == null) {
                                    if (!bluetoothAdapter.isEnabled()) {
                                        Log.d(TAG, "Probably failed just because adapter is disabled!");
                                    }
                                    throw new NullPointerException();
                                }
                                java.lang.reflect.Method getAddressMethod;
                                getAddressMethod = bluetoothManagerService.getClass().getMethod("getAddress");
                                String value = (String) getAddressMethod.invoke(bluetoothManagerService);
                                if (value == null) {
                                    throw new NullPointerException();
                                }
                                address = value;
                                Log.d(TAG, "Probably succed: " + address + " ✨ :F");
                                break;
                            } catch (Exception ex) {
                                // Ignoring failure (since it isn't critical API for most applications)
                                Log.d(TAG, "Obtaining address using reflection against internal Android code failed");
                                //result.error("hidden_address", "obtaining address using reflection agains internal Android code failed", exceptionToString(ex));
                            }

                            Log.d(TAG, "Trying to look up address by network interfaces - might be invalid on some devices");
                            try {
                                // This method might return invalid MAC address (since Bluetooth might use other address than WiFi).
                                // @TODO . further testing: 1) check is while open connection, 2) check other devices
                                Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
                                String value = null;
                                while (interfaces.hasMoreElements()) {
                                    NetworkInterface networkInterface = interfaces.nextElement();
                                    String name = networkInterface.getName();

                                    if (!name.equalsIgnoreCase("wlan0")) {
                                        continue;
                                    }

                                    byte[] addressBytes = networkInterface.getHardwareAddress();
                                    if (addressBytes != null) {
                                        StringBuilder addressBuilder = new StringBuilder(18);
                                        for (byte b : addressBytes) {
                                            addressBuilder.append(String.format("%02X:", b));
                                        }
                                        addressBuilder.setLength(17);
                                        value = addressBuilder.toString();
                                        //     Log.v(TAG, "-> '" + name + "' : " + value);
                                        // }
                                        // else {
                                        //    Log.v(TAG, "-> '" + name + "' : <no hardware address>");
                                    }
                                }
                                if (value == null) {
                                    throw new NullPointerException();
                                }
                                address = value;
                            } catch (Exception ex) {
                                // Ignoring failure (since it isn't critical API for most applications)
                                Log.w(TAG, "Looking for address by network interfaces failed");
                                //result.error("hidden_address", "looking for address by network interfaces failed", exceptionToString(ex));
                            }
                        }
                        while (false);
                    }
                    result.success(address);
                    break;
                }

                case "getName":
                    result.success(bluetoothAdapter.getName());
                    break;

                case "setName": {
                    if (!call.hasArgument("name")) {
                        result.error("invalid_argument", "argument 'name' not found", null);
                        break;
                    }

                    String name;
                    try {
                        name = call.argument("name");
                    } catch (ClassCastException ex) {
                        result.error("invalid_argument", "'name' argument is required to be string", null);
                        break;
                    }

                    result.success(bluetoothAdapter.setName(name));
                    break;
                }

                ////////////////////////////////////////////////////////////////////////////////
                /* Discovering and bonding devices */
                case "getDeviceBondState": {
                    if (!call.hasArgument("address")) {
                        result.error("invalid_argument", "argument 'address' not found", null);
                        break;
                    }

                    String address;
                    try {
                        address = call.argument("address");
                        if (!BluetoothAdapter.checkBluetoothAddress(address)) {
                            throw new ClassCastException();
                        }
                    } catch (ClassCastException ex) {
                        result.error("invalid_argument", "'address' argument is required to be string containing remote MAC address", null);
                        break;
                    }

                    BluetoothDevice device = bluetoothAdapter.getRemoteDevice(address);
                    result.success(device.getBondState());
                    break;
                }

                case "removeDeviceBond": {
                    if (!call.hasArgument("address")) {
                        result.error("invalid_argument", "argument 'address' not found", null);
                        break;
                    }

                    String address;
                    try {
                        address = call.argument("address");
                        if (!BluetoothAdapter.checkBluetoothAddress(address)) {
                            throw new ClassCastException();
                        }
                    } catch (ClassCastException ex) {
                        result.error("invalid_argument", "'address' argument is required to be string containing remote MAC address", null);
                        break;
                    }

                    BluetoothDevice device = bluetoothAdapter.getRemoteDevice(address);
                    switch (device.getBondState()) {
                        case BluetoothDevice.BOND_BONDING:
                            result.error("bond_error", "device already bonding", null);
                            break methodCallDispatching;
                        case BluetoothDevice.BOND_NONE:
                            result.error("bond_error", "device already unbonded", null);
                            break methodCallDispatching;
                        default:
                            // Proceed.
                            break;
                    }

                    try {
                        java.lang.reflect.Method method;
                        method = device.getClass().getMethod("removeBond");
                        boolean value = (Boolean) method.invoke(device);
                        result.success(value);
                    } catch (Exception ex) {
                        result.error("bond_error", "error while unbonding", exceptionToString(ex));
                    }
                    break;
                }

                case "bondDevice": {
                    if (!call.hasArgument("address")) {
                        result.error("invalid_argument", "argument 'address' not found", null);
                        break;
                    }

                    String address;
                    try {
                        address = call.argument("address");
                        if (!BluetoothAdapter.checkBluetoothAddress(address)) {
                            throw new ClassCastException();
                        }
                    } catch (ClassCastException ex) {
                        result.error("invalid_argument", "'address' argument is required to be string containing remote MAC address", null);
                        break;
                    }

                    if (bondStateBroadcastReceiver != null) {
                        result.error("bond_error", "another bonding process is ongoing from local device", null);
                        break;
                    }

                    BluetoothDevice device = bluetoothAdapter.getRemoteDevice(address);
                    switch (device.getBondState()) {
                        case BluetoothDevice.BOND_BONDING:
                            result.error("bond_error", "device already bonding", null);
                            break methodCallDispatching;
                        case BluetoothDevice.BOND_BONDED:
                            result.error("bond_error", "device already bonded", null);
                            break methodCallDispatching;
                        default:
                            // Proceed.
                            break;
                    }

                    bondStateBroadcastReceiver = new BroadcastReceiver() {
                        @Override
                        public void onReceive(Context context, Intent intent) {
                            switch (intent.getAction()) {
                                // @TODO . BluetoothDevice.ACTION_PAIRING_CANCEL
                                case BluetoothDevice.ACTION_BOND_STATE_CHANGED:
                                    final BluetoothDevice someDevice = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                                    if (!someDevice.equals(device)) {
                                        break;
                                    }

                                    final int newBondState = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.ERROR);
                                    switch (newBondState) {
                                        case BluetoothDevice.BOND_BONDING:
                                            // Wait for true bond result :F
                                            return;
                                        case BluetoothDevice.BOND_BONDED:
                                            result.success(true);
                                            break;
                                        case BluetoothDevice.BOND_NONE:
                                            result.success(false);
                                            break;
                                        default:
                                            result.error("bond_error", "invalid bond state while bonding", null);
                                            break;
                                    }
                                    activeContext.unregisterReceiver(this);
                                    bondStateBroadcastReceiver = null;
                                    break;

                                default:
                                    // Ignore.
                                    break;
                            }
                        }
                    };

                    final IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED);
                    //filter.setPriority(pairingRequestReceiverPriority + 1);
                    activeContext.registerReceiver(bondStateBroadcastReceiver, filter);

                    if (!device.createBond()) {
                        result.error("bond_error", "error starting bonding process", null);
                    }
                    break;
                }

                case "pairingRequestHandlingEnable":
                    if (FlutterBluetoothSerialPlugin.this.isPairingRequestHandlerSet) {
                        result.error("logic_error", "pairing request handling is already enabled", null);
                        break;
                    }
                    Log.d(TAG, "Starting listening for pairing requests to handle");

                    FlutterBluetoothSerialPlugin.this.isPairingRequestHandlerSet = true;
                    final IntentFilter filter = new IntentFilter(BluetoothDevice.ACTION_PAIRING_REQUEST);
                    //filter.setPriority(pairingRequestReceiverPriority);
                    activeContext.registerReceiver(pairingRequestReceiver, filter);
                    break;

                case "pairingRequestHandlingDisable":
                    FlutterBluetoothSerialPlugin.this.isPairingRequestHandlerSet = false;
                    try {
                        activeContext.unregisterReceiver(pairingRequestReceiver);
                        Log.d(TAG, "Stopped listening for pairing requests to handle");
                    } catch (IllegalArgumentException ex) {
                        // Ignore `Receiver not registered` exception
                    }
                    break;

                case "getBondedDevices":
                    ensurePermissions(granted -> {
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
                            entry.put("isConnected", checkIsDeviceConnected(device));
                            entry.put("bondState", BluetoothDevice.BOND_BONDED);
                            list.add(entry);
                        }

                        result.success(list);
                    });
                    break;

                case "isDiscovering":
                    result.success(bluetoothAdapter.isDiscovering());
                    break;

                case "startDiscovery":
                    ensurePermissions(granted -> {
                        if (!granted) {
                            result.error("no_permissions", "discovering other devices requires location access permission", null);
                            return;
                        }

                        Log.d(TAG, "Starting discovery");
                        IntentFilter intent = new IntentFilter();
                        intent.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
                        intent.addAction(BluetoothDevice.ACTION_FOUND);
                        activeContext.registerReceiver(discoveryReceiver, intent);

                        bluetoothAdapter.startDiscovery();

                        result.success(null);
                    });
                    break;

                case "cancelDiscovery":
                    Log.d(TAG, "Canceling discovery");
                    try {
                        activeContext.unregisterReceiver(discoveryReceiver);
                    } catch (IllegalArgumentException ex) {
                        // Ignore `Receiver not registered` exception
                    }

                    bluetoothAdapter.cancelDiscovery();

                    if (discoverySink != null) {
                        discoverySink.endOfStream();
                        discoverySink = null;
                    }

                    result.success(null);
                    break;

                case "isDiscoverable":
                    result.success(bluetoothAdapter.getScanMode() == BluetoothAdapter.SCAN_MODE_CONNECTABLE_DISCOVERABLE);
                    break;

                case "requestDiscoverable": {
                    Intent intent = new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);

                    if (call.hasArgument("duration")) {
                        try {
                            int duration = (int) call.argument("duration");
                            intent.putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, duration);
                        } catch (ClassCastException ex) {
                            result.error("invalid_argument", "'duration' argument is required to be integer", null);
                            break;
                        }
                    }

                    pendingResultForActivityResult = result;
                    ActivityCompat.startActivityForResult(activity, intent, REQUEST_DISCOVERABLE_BLUETOOTH, null);
                    break;
                }

                ////////////////////////////////////////////////////////////////////////////////
                /* Connecting and connection */
                case "connect": {
                    if (!call.hasArgument("address")) {
                        result.error("invalid_argument", "argument 'address' not found", null);
                        break;
                    }

                    String address;
                    try {
                        address = call.argument("address");
                        if (!BluetoothAdapter.checkBluetoothAddress(address)) {
                            throw new ClassCastException();
                        }
                    } catch (ClassCastException ex) {
                        result.error("invalid_argument", "'address' argument is required to be string containing remote MAC address", null);
                        break;
                    }

                    int id = ++lastConnectionId;
                    BluetoothConnectionWrapper connection = new BluetoothConnectionWrapper(id, bluetoothAdapter);
                    connections.put(id, connection);

                    Log.d(TAG, "Connecting to " + address + " (id: " + id + ")");

                    AsyncTask.execute(() -> {
                        try {
                            connection.connect(address);
                            activity.runOnUiThread(() -> result.success(id));
                        } catch (Exception ex) {
                            activity.runOnUiThread(() -> result.error("connect_error", ex.getMessage(), exceptionToString(ex)));
                            connections.remove(id);
                        }
                    });
                    break;
                }

                case "write": {
                    if (!call.hasArgument("id")) {
                        result.error("invalid_argument", "argument 'id' not found", null);
                        break;
                    }

                    int id;
                    try {
                        id = call.argument("id");
                    } catch (ClassCastException ex) {
                        result.error("invalid_argument", "'id' argument is required to be integer id of connection", null);
                        break;
                    }

                    BluetoothConnection connection = connections.get(id);
                    if (connection == null) {
                        result.error("invalid_argument", "there is no connection with provided id", null);
                        break;
                    }

                    if (call.hasArgument("string")) {
                        String string = call.argument("string");
                        AsyncTask.execute(() -> {
                            try {
                                connection.write(string.getBytes());
                                activity.runOnUiThread(() -> result.success(null));
                            } catch (Exception ex) {
                                activity.runOnUiThread(() -> result.error("write_error", ex.getMessage(), exceptionToString(ex)));
                            }
                        });
                    } else if (call.hasArgument("bytes")) {
                        byte[] bytes = call.argument("bytes");
                        AsyncTask.execute(() -> {
                            try {
                                connection.write(bytes);
                                activity.runOnUiThread(() -> result.success(null));
                            } catch (Exception ex) {
                                activity.runOnUiThread(() -> result.error("write_error", ex.getMessage(), exceptionToString(ex)));
                            }
                        });
                    } else {
                        result.error("invalid_argument", "there must be 'string' or 'bytes' argument", null);
                    }
                    break;
                }

                default:
                    result.notImplemented();
                    break;
            }
        }

    }
}
