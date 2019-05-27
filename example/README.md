# `flutter_bluetooth_serial_example`

Example application demonstrates key features of the `flutter_bluetooth_serial` plugin:

+ Adapter status monitoring,

+ Turning adapter on and off,

+ Opening settings,

+ Discovering devices,

+ Connecting to devices,

+ Sending and recieving data.

The plugin uses Serial Port profile for moving data over RFCOMM, so make sure target device runs Service Discovery Protocol that points SP/RFCOMM.



### Chat example

There is implemented simple chat. Client (the Flutter host) connects to selected from bonded devices server in order to exchange data - asynchronously.

#### Simple (console) server on Raspberry Pi:

1. Enable Bluetooth and pair Raspberry with the Flutter host device (only first time)
```
$ sudo bluetoothctl
# power on
# agent on
# scan on
# pair [MAC of the Flutter host]
# quit
```

2. Add SP/RFCOMM entry to the SDP service
```
$ sudo sdptool add SP         # There can be channel specified one of 79 channels by adding `--channel N`.
$ sudo sdptool browse local   # Check on which channel RFCOMM will be operating, to select in next step.
```
SDP tool tends to use good (and free) channels, so you don't have to keep track of other services if you let it decide.

3. Start RFCOMM listening
```
$ sudo killall rfcomm
$ sudo rfcomm watch /dev/rfcomm0 N picocom -c /dev/rfcomm0 --omap crcrlf   # `N` should be channel number on which SDP is pointing the SP.
```
Use `Ctrl+A` and `Ctrl+Q` to exit from `picocon` utility if you want to end stream from server side (and `Ctrl+C` for exit watch-mode of `rfcomm` utility).

You can use the descriptor (`/dev/rfcomm0`) in other way, not necessarily to `screen` on it. can be use in various ways, providing more automation and/or abstraction.



### To-do list

+ Clean up mess with `BluetoothStatus`,
+ Multiple connections to multiple devices,
+ Allow connection method/protocol/UUID specification,
+ Listening/server mode,
+ Example using Arduino with HC-05 module,
+ Recognizing and displaying `BluetoothClass` of device,
+ Maybe integration with `flutter_blue` one day ;)


