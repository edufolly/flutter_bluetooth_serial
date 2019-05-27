package io.github.edufolly.flutterbluetoothserial;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.UUID;
import java.util.Arrays;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;

public class BluetoothConnection
{
    protected static final UUID DEFAULT_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

    protected BluetoothAdapter bluetoothAdapter;

    public interface Receiver {
        void onRead(byte[] buffer);
    }
    protected Receiver reader;

    protected ConnectionThread connectionThread = null;

    public boolean isConnected() {
        return connectionThread != null;
    }



    public BluetoothConnection(BluetoothAdapter bluetoothAdapter, Receiver reader) {
        this.bluetoothAdapter = bluetoothAdapter;
        this.reader = reader;
    }



    /// Connects to given device by hardware address
    public void connect(String address, UUID uuid) throws IOException {
        if (isConnected()) {
            throw new IOException("already connected");
        }

        BluetoothDevice device = bluetoothAdapter.getRemoteDevice(address);
        if (device == null) {
            throw new IOException("device not found");
        }

        BluetoothSocket socket = device.createRfcommSocketToServiceRecord(uuid); // @TODO . introduce ConnectionMethod
        if (socket == null) {
            throw new IOException("socket connection not established");
        }

        // Cancel discovery, even though we didn't start it
        bluetoothAdapter.cancelDiscovery();

        socket.connect();

        connectionThread = new ConnectionThread(socket);
        connectionThread.start();
    }
    /// Connects to given device by hardware address (default UUID used)
    public void connect(String address) throws IOException {
        connect(address, DEFAULT_UUID);
    }
    
    /// Disconnects current session (ignore if not connected)
    public void disconnect() {
        if (connectionThread != null) {
            connectionThread.cancel();
            connectionThread = null;
        }
    }

    /// Writes to connected remote device 
    public void write(byte[] message) throws IOException {
        if (!isConnected()) {
            throw new IOException("not connected");
        }

        connectionThread.write(message);
    }

    /// Thread to handle connection I/O
    private class ConnectionThread extends Thread {
        private final BluetoothSocket socket;
        private final InputStream input;
        private final OutputStream output;
        
        ConnectionThread(BluetoothSocket socket) {
            this.socket = socket;
            InputStream tmpIn = null;
            OutputStream tmpOut = null;

            try {
                tmpIn = socket.getInputStream();
                tmpOut = socket.getOutputStream();
            } catch (IOException e) {
                e.printStackTrace();
            }

            this.input = tmpIn;
            this.output = tmpOut;
        }

        /// Thread main code
        public void run() {
            byte[] buffer = new byte[1024];
            int bytes;

            while (true) {
                try {
                    bytes = input.read(buffer);
                    
                    reader.onRead(Arrays.copyOf(buffer, bytes));
                } catch (NullPointerException e) {
                    break;
                } catch (IOException e) {
                    break;
                }
            }
        }

        /// Writes to output stream
        public void write(byte[] bytes) {
            try {
                output.write(bytes);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        /// Cancels the thread, disconnects
        public void cancel() {
            try {
                output.flush();
                output.close();

                input.close();

                socket.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
