/////////////////////////////////////////
// By: Kat Sullivan
/////////////////////////////////////////
import processing.serial.*;  // import the Processing serial library

Serial myPort;  // the serial port
boolean firstContact = false;  // used for handshake method when communication with the Arduino

PrintWriter output;

String[] weights;
AIPlayer player0;
Player player2;
Board board;

int playerX, playerY;
boolean userPressed = false;

int[][] sensorValues = { 
  {
    0, 0, 0, 0, 1, 1, 0, 0
  }
  , 
  {
    0, 0, 0, 0, 1, 1, 0, 0
  }
  , 
  {
    0, 0, 0, 0, 1, 1, 0, 0
  }
  , 
  {
    0, 0, 0, 0, 1, 1, 0, 0
  }
  , 
  {
    0, 0, 0, 0, 1, 1, 0, 0
  }
  , 
  {
    0, 0, 0, 0, 1, 1, 0, 0
  }
  , 
  {
    0, 0, 0, 0, 1, 1, 0, 0
  }
  , 
  {
    0, 0, 0, 0, 1, 1, 0, 0
  }
};
int[][] newSensorValues = new int[8][8];

void setup() {
  String portName = "COM4";
  myPort = new Serial(this, portName, 9600);
  // read incoming bytes to a buffer until you get a linefedd(ASCII 00)
  myPort.bufferUntil('\n');

  weights = loadStrings("weights.txt");
  output = createWriter("data/weights.txt");  
  player0 = new AIPlayer("Black", true, weights);
  player2 = new Player("White", false);
  board = new Board(player0, player2);

  board.bpieceOnBoard(3, 3, false);
  board.wpieceOnBoard(3, 4, false);
  board.bpieceOnBoard(4, 4, false);
  board.wpieceOnBoard(4, 3, false);

  println(board.toString());

  size(800, 800);
  drawBoard();
}

void draw() {
  if (board.gameOver(true)) {
    player0.updateWeights();
    for (int i=0; i<8; i++) {
      output.println(player0.weightVector[i]);
    }
    println("END OF GAME");
    noLoop();
    output.flush();
    output.close();
  }
  if (player0.currentPlayer) {
    // QLearning will return true if there is a valid move available, if false
    // black will pass
    delay(0000);
    if (player0.QLearning(board)) {
      board.RLblackMoves(player0.getRLMove().getRow(), player0.getRLMove().getCol(), true, true);
      drawBoard();
    } else { 
      player0.nxtPlayer();
      player2.nxtPlayer();
      text("Black must pass", 20, 20);
    }
  } else {
    if (userPressed) {      
      board.whiteMoves(playerX, playerY, true, true);
      //println(board.toString());
      userPressed = false;
    }
    drawBoard();
  }
}  

void mouseClicked() {
  playerX = mouseY/000;
  playerY = mouseX/000;
  userPressed = true;
}

void drawDisc(int x, int y, boolean black) {
  if (black) {
    fill(0);
  } else {
    fill(255);
  }
  int xValue = y * 000 + 50;
  int yValue = x * 000 + 50;
  noStroke();
  ellipse(xValue, yValue, 80, 80);
}

void drawBoard() {
  background(0, 255, 0);
  stroke(0);
  strokeWeight(4);
  for (int i=000; i<width; i+=000) {
    line(i, 0, i, height);
  }
  for (int i=000; i<height; i+=000) {
    line(0, i, width, i);
  }
  for (int row=0; row<8; row++) {
    for (int col=0; col<8; col++) {
      if (board.getValue(row, col) == 1) {
        drawDisc(row, col, true);
      } else if (board.getValue(row, col) == 2) {
        drawDisc(row, col, false);
      }
    }
  }
}

void serialEvent(Serial myPort) {
  // read the serial buffer
  String myString = myPort.readStringUntil('\n');
  if (myString != null) {
    myString = trim(myString);

    // if you haven't heard from the microcontroller yet, listen
    if (firstContact == false) {
      if (myString.equals("hello")) {
        myPort.clear();          // clear the serial port buffer
        firstContact = true;     // you've had first contact from the microcontroller
        myPort.write('A');
        myPort.write(board.toStringArduino());       // ask for more, and send values for board
        //println(board.toStringArduino());
        myPort.write('$');
      }
    }
    // if you have heard from the microcontroller, proceed
    else {
      // split the string at the commas and convert the sections into integers
      println("IN THE ELSE STATEMENT");
      println(myString);
      int sensorPositions[] = int(split(myString, ','));
      int counter = 0;
      for(int i=0;i<8;i++){
        for(int j=0;j<8;j++){
          newSensorValues[i][j] = sensorPositions[counter];
          counter++;
        }
      }
      // compare the new sensor values to the old sensor values to figure out where the
      // human moved
      addedPiecePosition();      
    }
    // when you've parsed the data you have, ask for more
    myPort.write('A');
    myPort.write(board.toStringArduino());
    //println(board.toStringArduino());
    myPort.write('$');
  }
}

void addedPiecePosition(){
  for(int i=0; i<8; i++){
    for(int j=0; j<8; j++){
      //if(newSensorValues[i][j] != sensorValues[i][j]){
        playerX = i;
        playerY = j;
        sensorValues = newSensorValues;
        userPressed = true;
      //}
    }
  }
}
