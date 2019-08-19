#pragma once

////////////////////////////////////////////////////////////////////////////////
// Heading

// Library for DS18B20 termometer
#include <DS18B20.h>

// OneWire protocol
OneWire oneWire(9);

// Number of DS18B20
#define DS18B20_sensors_num 2

// Adresses of DS18B20's
const byte DS18B20_address[DS18B20_sensors_num][8] PROGMEM = {
  0x28, 0x79, 0x84, 0x48, 0x4, 0x0, 0x0, 0xA6,
  0x28, 0xEF, 0x19, 0x97, 0xA, 0x0, 0x0, 0x91
};

// DS18B20 controllers
DS18B20 DS18B20_controller(&oneWire);

// Buffer for values
float DS18B20_value[DS18B20_sensors_num];



////////////////////////////////////////////////////////////////////////////////
// Update

inline void updateTermometer()
{
  // Update values buffer
  if (DS18B20_controller.available()) {
    for (byte i = 0; i < DS18B20_sensors_num; i++) {
      DS18B20_value[i] = DS18B20_controller.readTemperature(FA(DS18B20_address[i]));
    }
    DS18B20_controller.request();
  }
}



////////////////////////////////////////////////////////////////////////////////
// Setup

inline void setupTermometer()
{
  // Init controller
  DS18B20_controller.begin();
  DS18B20_controller.request();
  
  // First update
  updateTermometer();
}


