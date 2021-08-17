## [0.4.0] - 2021-08-17

Update flutter plugin v2.

## [0.3.2] - 2021-07-15

Fixing pubspec.yaml typo.

## [0.3.1] - 2021-07-15

Patch release.

* Update example to sound null safety and new Material Buttons.
* Changed FutureOr<int> to FutureOr<dynamic> in getBondStateForAddress.
* Fix an unhandled exception when trying to get bluetooth state.

## [0.3.0] - 2021-07-04

Implementing null safety.

## [0.2.2] - 2019-08-19

Patch release.

* Fix closing connections which are not `listen`ing to `input` (solved #60),
* Add more clear example of detecting which side caused disconnection,
* Add exception on `add`ing to `output` if connection closed,
* `BluetoothConnection` `cancel` is deprecated now, use `close` instead. It was
  stupid to name `cancel` something that `close`s (it was even documented that
  way, lol).

## [0.2.1] - 2019-08-05

Patch release.

* apply patch #48 for some disconnection issues,
* update `ChatPage` to newer API,
* fix and update AndroidX declaration.

## [0.2.0] - 2019-07-02

Two big features packs:

* Bonding (Pairing):
    - starting outgoing pairing requests,
    - handling incoming pairing requests,
    - remove current bondings to devices,
* Discoverability!
    - requesting discoverable mode for specified duration,
    - example with timeout countdown,
    - checking discoverable mode.

And few more features:

* get/set for local (discoverable) device name,
* getting local adapter address (with some hacks to work on newer Androids),
* checking for `isConnected` for discovered or bonded devices,
* fixed few broadcast receiver leaks.

## [0.1.1] - 2019-07-01

* Patch #43 for "Error when meet unknown devices".

## [0.1.0] - 2019-06-19

Pull request #35 by @PsychoXIVI changes a lot:

* Discovering other devices,
* Multiple connections,
* Interesting example application,
* Enabling/Disabling Bluetooth,
* Byte streams,
* Overall improvements and fixes.

## [0.0.5] - 2019-03-18

* Upgrade for AndroidX support (thanks @akilinomendez)
* New default constructor (thanks @MohiuddinM)
* Added method write passing byte[] (thanks @rafaelterada)
* Upgrade to Android Studio 3.3.2

## [0.0.4] - 2018-12-20

* Unsupported value error correction (thanks @rafaelterada)
* Added openSettings, which opens the bluetooth settings screen (thanks
  @rafaelterada)

## [0.0.3] - 2018-11-22

* async connection and null exception handled (thanks @MohiuddinM)

## [0.0.2] - 2018-09-27

* isConnected Implementation (thanks @Riscue)

## [0.0.1] - 2018-08-20

* Only Android support.