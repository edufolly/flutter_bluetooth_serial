/// Example temperature and ph level monitor
///
/// Part of code of https://gitlab.com/PsychoXIVI/aquariumcontroller by Patryk (PsychoX) Ludwikowski
/// Cutted to simple monitor for https://github.com/edufolly/flutter_bluetooth_serial/pull/35
////////////////////////////////////////////////////////////////////////////////
#include <Wire.h>

#define DEBUG 1

#include "Termometer.hpp"
#include "phSensor.hpp"

// There was so (stupidly) called `BluetoothQwertyServer` which provides simple packet system with data retransmission, but this should be simple example, so... bye friend :F

// Library for virtual serial ports over normal pins
#include <SoftwareSerial.h>

SoftwareSerial bluetooth(7, 8);

bool doUpdateStatus = false;



////////////////////////////////////////////////////////////////////////////////
void loop(void)
{
  delay(1);

  updateTermometer();
  
  updatephSensorsSamplings();
  updatephSensorsValues();
  
  // Commands: "start", "stop"
  while (bluetooth.available() >= 4) {
    switch (bluetooth.read()) {
      case 's':
        bluetooth.read(); // Ignore (probably) 't'
        switch (bluetooth.read()) {
          case 'a': // "start"
            doUpdateStatus = true;
            digitalWrite(13, HIGH);
            
            bluetooth.read(); // Ignore 'r'
            while (bluetooth.available() == 0);
            bluetooth.read(); // Ignore 't'
            break;
            
          case 'o': // "stop"
            doUpdateStatus = false;
            digitalWrite(13, LOW);
            
            bluetooth.read(); // Ignore 'p'
        }
        break;
    }
  }
  
	static unsigned long lastRefreshTime = 0;
	if (millis() - lastRefreshTime >= 1000) {
    lastRefreshTime += 1000;
    
    if (doUpdateStatus) {
      // Every update there are temperatures and water pH level sent coded into binary form of:
      // 't', 
      // integer part of value in Celcius of first termometer, 
      // fractional part of value in Celcius of first termometer,
      // integer part of value in Celcius of second termometer, 
      // fractional part of value in Celcius of second termometer,
      // 'w'
      // integer value of water pH level, 
      // fractional part of water pH level.
      
      bluetooth.write('t');
      for (byte i = 0; i < 2; i++) {
        bluetooth.write(static_cast<byte>(static_cast<int>(DS18B20_value[i])));
        bluetooth.write(static_cast<byte>(static_cast<int>((DS18B20_value[i] - static_cast<int>(DS18B20_value[i])) * 100)));
      }
      
      bluetooth.write('w');
      bluetooth.write(static_cast<byte>(static_cast<int>(phSensors[0].value)));
      bluetooth.write(static_cast<byte>(static_cast<int>((phSensors[0].value - static_cast<int>(phSensors[0].value)) * 100)));
    }
	}
}



////////////////////////////////////////////////////////////////////////////////
void setup(void)
{
  Serial.begin(9600);
  
  bluetooth.begin(9600);

  setupTermometer();
  
  setupphSensors();
  
  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);
}


