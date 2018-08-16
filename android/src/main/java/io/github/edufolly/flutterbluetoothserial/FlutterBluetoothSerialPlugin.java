package io.github.edufolly.flutterbluetoothserial;

import android.Manifest;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import java.util.ArrayList;
import java.util.Set;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;
import io.flutter.plugin.common.PluginRegistry.Registrar;


public class FlutterBluetoothSerialPlugin implements MethodCallHandler, RequestPermissionsResultListener {

    private static final String TAG = "FlutterBluePlugin";
    private static final String NAMESPACE = "flutter_bluetooth_serial";
    private static final int REQUEST_COARSE_LOCATION_PERMISSIONS = 1451;
    private final Registrar registrar;
    private final MethodChannel channel;
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
        this.mBluetoothManager = (BluetoothManager) registrar.activity()
                .getSystemService(Context.BLUETOOTH_SERVICE);
        this.mBluetoothAdapter = mBluetoothManager.getAdapter();
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (mBluetoothAdapter == null && !"isAvailable".equals(call.method)) {
            result.error("bluetooth_unavailable", "the device does not have bluetooth", null);
            return;
        }

        // Todo - Improve bluetooth verification.
        if (!mBluetoothAdapter.isEnabled()) {
//            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
//            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
            result.error("bluetooth_disabled", "the bluetooth is disabled", null);
            return;
        }

        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
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

            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions,
                                              int[] grantResults) {

        if (requestCode == REQUEST_COARSE_LOCATION_PERMISSIONS) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                //  TODO - Continue...
                getBondedDevices(pendingCall, pendingResult);
            } else {
                pendingResult.error("no_permissions",
                        "flutter_blue plugin requires location permissions for scanning", null);
                pendingResult = null;
                pendingCall = null;
            }
            return true;
        }
        return false;
    }

    private void getBondedDevices(MethodCall call, Result result) {

        ArrayList list = new ArrayList<>();

        Set<BluetoothDevice> pairedDevices = mBluetoothAdapter.getBondedDevices();

        for(BluetoothDevice device : pairedDevices) {
            Log.d(TAG, device.toString());
            list.add(device.toString());
        }

        result.success(list);


        // If there are paired devices
//        if (pairedDevices.size() > 0) {
//            // Loop through paired devices
//            for (BluetoothDevice device : pairedDevices) {
//                // Add the name and address to an array adapter to show in a ListView
//                mArrayAdapter.add(device.getName() + "\n" + device.getAddress());
//            }
//        }
    }
}
