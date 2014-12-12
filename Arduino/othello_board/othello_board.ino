/////////////////////////////////////////
// By: Kat Sullivan
/////////////////////////////////////////
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_LEDBackpack.h>
//
Adafruit_BicolorMatrix matrix = Adafruit_BicolorMatrix();

// MUX 1
const int channel1[] = {
  2,3,4,5};

// MUX 2
const int channel2[] = {
  24,25,26,27};

// MUX 3
const int channel3[] = {
  36,37,38,39};

// MUX 0
const int inputPin0 = 12;

// MUX 1
const int inputPin1 = A7;

// MUX 2
const int inputPin2 = A1;

// MUX 3
const int inputPin3 = A0;

int sensorValues[8][8];

int inputPins[] = {
  inputPin0, inputPin1, inputPin2, inputPin3};

// Data received from the serial port
char val;

void setup(){
  Serial.begin(9600);

  pinMode(channel1[0], OUTPUT);
  pinMode(channel1[1], OUTPUT);
  pinMode(channel1[2], OUTPUT);
  pinMode(channel1[3], OUTPUT);
  pinMode(channel2[0], OUTPUT);
  pinMode(channel2[1], OUTPUT);
  pinMode(channel2[2], OUTPUT);
  pinMode(channel2[3], OUTPUT);
  pinMode(channel3[0], OUTPUT);
  pinMode(channel3[1], OUTPUT);
  pinMode(channel3[2], OUTPUT);
  pinMode(channel3[3], OUTPUT);
  pinMode(inputPin1, INPUT_PULLUP);
  pinMode(inputPin2, INPUT_PULLUP);
  pinMode(inputPin3, INPUT_PULLUP);

  matrix.begin(0x70);
  establishContact();

  //  for(int thisPin = 0; thisPin < 4; thisPin++) {
  //    //    pinMode(thisPin, OUTPUT);
  //    pinMode(channel1[thisPin], OUTPUT);
  //    pinMode(channel2[thisPin], OUTPUT);
  //  }
  //  pinMode(inputPin1, INPUT_PULLUP);
  //  pinMode(inputPin2, INPUT_PULLUP);

}

void loop(){
  if(Serial.available()){
    val = Serial.read();
    if(val == 'A'){
      char pieces[64] = "";
      Serial.readBytesUntil('$',pieces,64);
      int counter = 0;
      for(int i=0; i<8; i++){
        for(int j=0; j<8; j++){
          lightLED(i,j,pieces[counter]);
          counter++;
        }  
      }

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
      digitalWrite(channel1[thisPin], bitRead(thisChannel, 3-thisPin));
      digitalWrite(channel2[thisPin], bitRead(thisChannel, 3-thisPin));
      digitalWrite(channel3[thisPin], bitRead(thisChannel, 3-thisPin));
    }
    addSensorValue(1,thisChannel);
    addSensorValue(2,thisChannel);
    addSensorValue(3,thisChannel);
  }
}

void addSensorValue(int muxNumber, int channelNumber) {
  if(channelNumber < 8) {
    sensorValues[(channelNumber-7)*-1][muxNumber*2] = digitalRead(inputPins[muxNumber]);
    //    if(digitalRead(inputPins[muxNumber])==0){
    //      Serial.print("mux number: ");
    //      Serial.print(muxNumber);
    //      Serial.print("    channel number:   ");
    //      Serial.println(channelNumber);
    //    }
  } 
  else {
    sensorValues[channelNumber-8][muxNumber*2+1] = digitalRead(inputPins[muxNumber]);
    //    if(digitalRead(inputPins[muxNumber])==0){
    //      Serial.print("mux number: ");
    //      Serial.print(muxNumber);
    //      Serial.print("    channel number:   ");
    //      Serial.println(channelNumber);
    //    }
  }   
}

// Used for the handshake method with Processing
void establishContact() {
  while(Serial.available() <= 0){
    Serial.println("hello");  // send a starting message
    delay(300);
  }
}

















