/////////////////////////////////////////
// By: Kat Sullivan
/////////////////////////////////////////
#include <Wire.h>git
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
    Serial.println("HERE");
    char pieces[64] = "";
    Serial.readBytesUntil('$',pieces,64);
    Serial.println(pieces);
    int counter = 0;
    for(int i=0; i<8; i++){
      for(int j=0; j<8; j++){
        lightLED(i,j,pieces[counter]);
        counter++;
      }  
    }
  }

}

void lightLED(int row, int col, char color){
  Serial.print(row);
  Serial.print(col);
  Serial.println(color);
  if(color == '1'){
    Serial.println(row, col);
    matrix.drawPixel(row, col, LED_GREEN);
  } 
  else if(color == '2') {
    matrix.drawPixel(row, col, LED_RED);
  }
  matrix.writeDisplay();
}


// Used for the handshake method with Processing
void establishContact() {
  while(Serial.available() <= 0){
    Serial.println("hello");  // send a starting message
    delay(300);
  }
}

