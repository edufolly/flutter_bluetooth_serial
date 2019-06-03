# `flutter_bluetooth_serial_example`

Example application demonstrates key features of the `flutter_bluetooth_serial` plugin:

+ Adapter status monitoring,

+ Turning adapter on and off,

+ Opening settings,

+ Discovering devices,

+ Connecting to devices,

+ Sending and recieving data.

The plugin (for now) uses Serial Port profile for moving data over RFCOMM, so make sure there is running Service Discovery Protocol that points to SP/RFCOMM channel of the device.



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
$ sudo rfcomm listen /dev/rfcomm0 N picocom -c /dev/rfcomm0 --omap crcrlf   # `N` should be channel number on which SDP is pointing the SP.
```

4. Now you can connect and chat to the server with example application using the console. Every character is send to your device and buffered. Only full messages, between new line characters (`\n`) are displayed. You can use `Ctrl+A` and `Ctrl+Q` to exit from `picocom` utility if you want to end stream from server side (and `Ctrl+C` for exit watch-mode of `rfcomm` utility). 

If you xperiencing problems with your terminal (some `term_exitfunc` of `picocom` errors), you should try saving good terminal settings (`stty --save > someFile`) and loading them after picocom exits (adding ``; stty `cat someFile` `` to the second command of 3. should do the thing).

You can also use the descriptor (`/dev/rfcomm0`) in other way, not necessarily to run interactive terminal on it, in order to chat. It can be used in various ways, providing more automation and/or abstraction.


