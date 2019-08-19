#pragma once

////////////////////////////////////////////////////////////////////////////////
// Heading

#define phSensorDeviationOffset 0.00 //deviation compensate

#define phSensorSamplingInterval 20
#define phSensorSamplesNumber 40

double avergearray(int*, int);

struct phSensor
{
  /* Fields */
  float value;
  float voltage;
  unsigned long samplingTime = 0;
  
  /*unsigned*/ short lastValues[phSensorSamplesNumber];
  unsigned char  lastValueIndex = 0;
  
  const byte pin; // @TODO ? constexpr, skoro wszystkie piny i tak sa podawane compile-time
  
  /* Operators */
  phSensor(const byte pin)
    : pin(pin)
  {}
  
  /* Methods */
  void setup()
  {
    pinMode(pin, INPUT);
  }
  
  void updateSampling()
  {
    if (millis() - samplingTime > phSensorSamplingInterval) {
      lastValues[lastValueIndex++] = analogRead(pin);
    
      if (lastValueIndex == phSensorSamplesNumber) {
        lastValueIndex=0;
      }
      
      samplingTime = millis();
    }
  }
  
  void updateValue()
  {
    voltage = avergearray(lastValues, phSensorSamplesNumber) * 5.0 / 1024;
    value = 3.5 * voltage + phSensorDeviationOffset;
  }
};


// Number of ph sensors
#define phSensors_Length 1

// Structures constructed with ph sensors pin numbers.
phSensor phSensors[phSensors_Length] = {{A6}};



////////////////////////////////////////////////////////////////////////////////
// Update

inline void updatephSensorsSamplings()
{
  phSensors[0].updateSampling();
}

inline void updatephSensorsValues()
{
  phSensors[0].updateValue();
}



////////////////////////////////////////////////////////////////////////////////
// Setup

inline void setupphSensors()
{
  phSensors[0].setup();
} 




// Random code from internet below, sorry...
double avergearray(int* arr, int number){
  int i;
  int max,min;
  double avg;
  long amount = 0;
  
  if (number <= 0) {
    //Serial.println("Error number for the array to avraging!/n");
    return 0;
  } 
  if (number < 5) { //less than 5, calculated directly statistics
    for(i = 0; i < number; i++) {
      amount += arr[i];
    }
    avg = amount/number;
    return avg;
  }
  else { // XDDD ?
    if (arr[0] < arr[1]) {
      min = arr[0];
      max = arr[1];
    }
    else {
      min = arr[1];
      max = arr[0];
    }
    for (i = 2; i < number; i++) {
      if (arr[i] < min) {
        amount += min; //arr<min
        min = arr[i];
      }
      else {
        if (arr[i] > max) {
          amount += max; //arr>max
          max = arr[i];
        }
        else {
          amount += arr[i]; //min<=arr<=max
        }
      }
    }
    avg = (double)amount / (number - 2);
  }
  return avg;
}


