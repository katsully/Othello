/////////////////////////////////////////
// By: Kat Sullivan
/////////////////////////////////////////
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_LEDBackpack.h>

Adafruit_BicolorMatrix matrix = Adafruit_BicolorMatrix();


void setup(){
  Serial.begin(9600);
  matrix.begin(0x70);
  establishContact();
}

void loop(){
  if(Serial.available() > 0){
    char pieces[64] = "";
    Serial.readBytesUntil('$',pieces,64);
  }
    
}


// Used for the handshake method with Processing
void establishContact() {
  while(Serial.available() <= 0){
    Serial.println("hello");  // send a starting message
    delay(300);
  }
}
