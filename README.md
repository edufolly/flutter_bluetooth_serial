
# `flutter_bluetooth_serial`

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/e715d21e77394cfaacf9abd20b7d97cc)](https://app.codacy.com/app/edufolly/flutter_bluetooth_serial?utm_source=github.com&utm_medium=referral&utm_content=edufolly/flutter_bluetooth_serial&utm_campaign=Badge_Grade_Dashboard)
[![pub package](https://img.shields.io/pub/v/flutter_bluetooth_serial.svg)](https://pub.dartlang.org/packages/flutter_bluetooth_serial)

Flutter basic implementation for Classical Bluetooth.

Based on [flutter_blue](https://github.com/pauldemarco/flutter_blue).



## Features

The first goal of this project, started by `Edufolly` was making an interface for Serial Port Protocol (HC-05 Adapter). Now the plugin features:

+ Adapter status monitoring,

+ Turning adapter on and off,

+ Opening settings,

+ Discovering devices,

+ Connecting to multiple devices at the same time,

+ Sending and recieving data (multiple connections).

The plugin (for now) uses Serial Port profile for moving data over RFCOMM, so make sure there is running Service Discovery Protocol that points to SP/RFCOMM channel of the device. There could be [max up to 7 Bluetooth connections](https://stackoverflow.com/a/32149519/4880243).



## Getting Started

Check out [example application](example/README.md).

Only for Android.

If you have any problem with _invoke-customs_, verify issue [#14](https://github.com/edufolly/flutter_bluetooth_serial/issues/14).



## To-do list

+ Add some utils to easier manage `BluetoothConnection` (as request/response),
+ Allow connection method/protocol/UUID specification,
+ Listening/server mode,
+ Recognizing and displaying `BluetoothClass` of device,
+ Maybe integration with `flutter_blue` one day ;)


