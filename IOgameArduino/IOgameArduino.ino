/*
  Serial Call and Response Game
  Language: Wiring/Arduino

  An Arduino/Processing serial communication game based on the arduino example sketch
  
  Created September 2019 by Leah Willemin 
  ___________________________________________

  This program sends an ASCII A (byte of value 65) on startup and repeats that
  until it gets some data in. Then it waits for a byte in the serial port, and
  sends three sensor values whenever it gets a byte in.

  The circuit:
  - potentiometers attached to analog inputs 0 and 1
  - pushbutton attached to digital I/O 2

  created 26 Sep 2005
  by Tom Igoe
  modified 24 Apr 2012
  by Tom Igoe and Scott Fitzgerald
  Thanks to Greg Shakar and Scott Fitzgerald for the improvements

  This example code is in the public domain.

  http://www.arduino.cc/en/Tutorial/SerialCallResponse
*/

int analogSensor1 = A0;    // first analog sensor
int analogSensor2 = A1;   // second analog sensor
int digitalSensor = 7;    // digital sensor
int analogValue1;    // first analog sensor value
int analogValue2;   // second analog sensor value
int digitalValue;    // digital sensor value
int inByte = 0;         // incoming serial byte         
//LED array for point counting
int ledPins[] = {
  2, 3, 4, 5, 6
};  
int ledCount = 5;
int points = 0;  // Game score
int celebrate =true;

void setup() {
  // start serial port at 9600 bps:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  pinMode(digitalSensor, INPUT);   // digital sensor is on digital pin

  for (int thisPin = 0; thisPin < ledCount; thisPin++) {
    pinMode(ledPins[thisPin], OUTPUT);
  }

  establishContact();  // send a byte to establish contact until receiver responds
}

void loop() {
  // if we get a valid byte, read analog ins:
  if (Serial.available() > 0) {
    // get incoming byte:
    inByte = Serial.read();

    if (inByte < 10){
      points = inByte;
    }
    
    // read first analog input and map 0-255 (byte):
    analogValue1 = map(analogRead(analogSensor1), 250, 1000, 0, 255);
    // delay 10ms to let the ADC recover:
    delay(10);
    // read second analog input and map 0-255 (byte):
    analogValue2 = map(analogRead(analogSensor2), 400, 1000, 0, 255);
    // read switch, map it to 0 or 255
    digitalValue = map(digitalRead(digitalSensor), 0, 1, 0, 255);
    // send sensor values:
    Serial.write(analogValue1);
    Serial.write(analogValue2);
    Serial.write(digitalValue);
    //return the value arduino is receiving from Processing (for debugging):
    Serial.write(inByte);
  }

  if (points < 5){     // Light up the LEDs according to score
    celebrate = true;   //reset this
    for (int thisPin = 0; thisPin < points; thisPin ++){
      digitalWrite(ledPins[thisPin], HIGH);
    } 
    for (int thisPin = ledCount-1; thisPin >= points; thisPin --){
      digitalWrite(ledPins[thisPin], LOW);
    }
  }else if (points == 5 && celebrate == true){   // Celebrate when you win!
    for (int repeat = 0; repeat < 7; repeat ++){
      for (int thisPin = ledCount - 1; thisPin >= 0; thisPin--) {
        digitalWrite(ledPins[thisPin], HIGH);
        delay(50);
        digitalWrite(ledPins[thisPin], LOW);
        delay(50);
      }
      for (int thisPin = 0; thisPin <= ledCount - 1; thisPin++) {
        digitalWrite(ledPins[thisPin], HIGH);
        delay(50);
        digitalWrite(ledPins[thisPin], LOW);
        delay(50);
      }
    }
    celebrate = false;    //turn off the blinking
  }

   //print data for debugging: (cannot print and send serial to Processing simultaneously)
   //Serial.print(analogValue1);
   //Serial.print("    ");
   //Serial.print(analogValue2);
   //Serial.print("    ");
   //Serial.println(digitalValue);
}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('A');   // send a capital A
    delay(300);
  }
}
