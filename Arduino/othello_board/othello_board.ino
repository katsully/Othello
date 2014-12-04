/////////////////////////////////////////
// By: Kat Sullivan
/////////////////////////////////////////
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_LEDBackpack.h>

Adafruit_BicolorMatrix matrix = Adafruit_BicolorMatrix();

const int channel2[] = {
  2, 3, 4, 5};
const int inputPin2 = 6;

int sensorValues[8][8];

// Data received from the serial port
char val;

void setup(){
  Serial.begin(9600);
  matrix.begin(0x70);
  establishContact();

  for(int thisPin = 2; thisPin <6; thisPin++) {
    pinMode(thisPin, OUTPUT);
  }
  pinMode(inputPin2, INPUT_PULLUP);
}

void loop(){
  if(Serial.available()){
    val = Serial.read();
    if(val == 'A'){
      char pieces[64] = "";
      Serial.readBytesUntil('$',pieces,64);
      //Serial.println(pieces);
      int counter = 0;
      for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
          lightLED(i,j,pieces[counter]);
          counter++;
        }  
      }
      //} 
      //else{
      // read in the hall effect sensors 
      readSensors();
      // send values of all sensors to Processing
      // Processing will compare the old values to the new values to spot the new piece
      for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
          Serial.print(sensorValues[i][j]);
          Serial.print(",");          
        }
      }
      Serial.println();
      delay(1500);
      //}
    }
  } 
}

void lightLED(int row, int col, char color){
//  Serial.print(row);
//  Serial.print(col);
//  Serial.println(color);
  if(color == '1'){
    //Serial.println(row, col);
    matrix.drawPixel(row, col, LED_GREEN);
  } 
  else if(color == '2') {
    matrix.drawPixel(row, col, LED_RED);
  }
  matrix.writeDisplay();
}

void readSensors(){
  for(int thisChannel = 0; thisChannel < 16; thisChannel++) {
    for(int thisPin = 0; thisPin < 4; thisPin++) {
      digitalWrite(channel2[thisPin], bitRead(thisChannel, 3-thisPin));
    }
    addSensorValue(2,thisChannel);
  }
}

void addSensorValue(int muxNumber, int channelNumber) {
  if(channelNumber < 8) {
    sensorValues[(channelNumber-7)*-1][muxNumber*2] = digitalRead(inputPin2);
  } 
  else {
    sensorValues[channelNumber-8][muxNumber*2+1] = digitalRead(inputPin2);
  }   
}

// Used for the handshake method with Processing
void establishContact() {
  while(Serial.available() <= 1){
    Serial.println("hello");  // send a starting message
    delay(311);
  }
}








