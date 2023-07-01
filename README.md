# `flutter_bluetooth_serial`

[![pub package](https://img.shields.io/pub/v/flutter_bluetooth_serial.svg)](https://pub.dartlang.org/packages/flutter_bluetooth_serial)

Flutter basic implementation for Classical Bluetooth (only RFCOMM for now).

## Features

The first goal of this project, started by @edufolly was making an interface for
Serial Port Protocol (HC-05 Adapter). Now the plugin features:

+ Adapter status monitoring,

+ Turning adapter on and off,

+ Opening settings,

+ Discovering devices (and requesting discoverability),

+ Listing bonded devices and pairing new ones,

+ Connecting to multiple devices at the same time,

+ Sending and receiving data (multiple connections).

The plugin (for now) uses Serial Port profile for moving data over RFCOMM, so
make sure there is running Service Discovery Protocol that points to SP/RFCOMM
channel of the device. There could
be [max up to 7 Bluetooth connections](https://stackoverflow.com/a/32149519/4880243).

For now there is only Android support.

## Funding

Your contribution will help drive the development of quality tools for the
Flutter and Dart developer community. Any amount will be appreciated. Thank you
for your continued support!

[![BuyMeACoffee](https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg)](https://www.buymeacoffee.com/edufolly)

## PIX

Sua contribuição ajudará a impulsionar o desenvolvimento de ferramentas de
qualidade para a comunidade de desenvolvedores Flutter e Dart. Qualquer quantia
será apreciada. Obrigado pelo seu apoio contínuo!

[![PIX](helpers/pix.png)](https://nubank.com.br/pagar/2bt2q/RBr4Szfuwr)

## Getting Started

#### Depending

```yaml
# Add dependency to `pubspec.yaml` of your project.
dependencies:
  # ...
  flutter_bluetooth_serial: ^0.4.0
```

#### Installing

```bash
flutter pub get
```

#### Importing

```dart
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
```

#### Usage

You should look to the Dart code of the library (mostly documented functions) or
to the examples code.

```dart
// Some simplest connection :F
try {
    BluetoothConnection connection = await BluetoothConnection.toAddress(address);
    print('Connected to the device');

    connection.input.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
        connection.output.add(data); // Sending data

        if (ascii.decode(data).contains('!')) {
            connection.finish(); // Closing connection
            print('Disconnecting by local host');
        }
    }).onDone(() {
        print('Disconnected by remote request');
    });
}
catch (exception) {
    print('Cannot connect, exception occured');
}
```

Note: Work is underway to make the communication easier than operations on byte
streams. See #41 for discussion about the topic.

#### Examples

Check out [example application](example/README.md) with connections with both
Arduino HC-05 and Raspberry Pi (RFCOMM) Bluetooth interfaces.

|       Main screen and options        |       Discovery and connecting       |       Simple chat with server        |        Background connection         |
|:------------------------------------:|:------------------------------------:|:------------------------------------:|:------------------------------------:|
| ![](https://i.imgur.com/qeeMsVe.png) | ![](https://i.imgur.com/zruuelZ.png) | ![](https://i.imgur.com/y5mTUey.png) | ![](https://i.imgur.com/3wvwDVo.png) |

## To-do list

+ Add some utils to easier manage `BluetoothConnection` (see discussion #41),
+ Allow connection method/protocol/UUID specification,
+ Listening/server mode,
+ Recognizing and displaying `BluetoothClass` of device,
+ Maybe integration with `flutter_blue` one day ;)

You might also want to
check [milestones](https://github.com/edufolly/flutter_bluetooth_serial/milestones).

## Credits

- [Eduardo Folly](mailto:edufolly@gmail.com)
- [Martin Mauch](mailto:martin.mauch@gmail.com)
- [Patryk Ludwikowski](mailto:patryk.ludwikowski.7@gmail.com)

After version 0.3.0 we have a lot of collaborators. If you would like to be
credited, please send me an [email](mailto:edufolly@gmail.com).
