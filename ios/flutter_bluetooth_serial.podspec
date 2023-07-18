#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_bluetooth_serial.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_bluetooth_serial'
  s.version          = '0.0.1'
  s.summary          = 'A basic Flutter Bluetooth Serial'
  s.description      = <<-DESC
A basic Flutter Bluetooth Serial
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end

