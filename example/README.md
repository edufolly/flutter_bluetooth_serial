# `flutter_bluetooth_serial_example`

Example application demonstrates key features of the `flutter_bluetooth_serial` plugin:

+ Adapter status monitoring,

+ Turning adapter on and off,

+ Opening settings,

+ Discovering devices (and requesting discoverability),

+ Listing bonded devices and pairing new ones,

+ Connecting to multiple devices at the same time,

+ Sending and recieving data (multiple connections).

The plugin (for now) uses Serial Port profile for moving data over RFCOMM, so make sure there is running Service Discovery Protocol that points to SP/RFCOMM channel of the device.

#### Screens 

Main screen and options |  Discovery and connecting  |  Simple chat with server  |  Background connection  |
:---:|:---:|:---:|:---:|
![](https://i.imgur.com/qeeMsVe.png)  |  ![](https://i.imgur.com/zruuelZ.png)  |  ![](https://i.imgur.com/y5mTUey.png)  |  ![](https://i.imgur.com/3wvwDVo.png)

Note: There screen-shots might be out-dated. Build and see the example app for yourself, you won't regret it. :)

#### Tests 

There is a recording of the tests (click for open video as WEBM version):

[![Test with multiple connections](https://i.imgur.com/rDFrYcS.png)](https://webm.red/qpGg.webm)



## General

The basics are simple, so there is no need to write about it so much.

#### Discovery page

On devices list you can long tap to start pairing process. If device is already paired, you can use long tap to unbond it. 



## Chat example

There is implemented example chat server as NodeJS script. Client (the Flutter host) connects to selected from bonded devices - the server - in order to exchange data. The script supports up to 7 clients and uses packets system, that ease implementing communication.

See [in `./peripheral/scripts/chatserver` folder for details](peripheral/scripts/chatserver/README.md), including wider description, installation and usage.

#### Pairing Linux based devices from console line (i.e. Raspberry Pi)

```
$ sudo bluetoothctl
# power on
# agent on
# scan on
# pair [MAC of the Flutter host]
# quit
```



## Background monitor example

For testing multiple connections there were created background data collector, which connects to Arduino controller equiped with `HC-05` Bluetooth interface, 2 `DS18B20` termometers and water pH level meter. There are very nice graphs to displaying the recieved data. 

The example uses Celsius degree, which was chosen because it utilizes standard conditions of water freezing and ice melting points instead of just rolling a dice over periodic table of elements like a Fahrenheit do...

Project of the Arduino side could be found in `./peripheral/arduino` folder, but there is a note: **the code is prepared for testing in certain environment** and will not work without its hardware side (termometers, pH meter). If you can alter the real termometer code for example for random data generator or your own inputs. 


