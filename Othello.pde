/////////////////////////////////////////
// By: Kat Sullivan
/////////////////////////////////////////
import processing.serial.*;  // import the Processing serial library

Serial myPort;  // the serial port
boolean firstContact = false;  // used for handshake method when communication with the Arduino

PrintWriter output;

String[] weights;
AIPlayer player1;
Player player2;
Board board;

int playerX, playerY;
boolean userPressed = false;


void setup() {
  String portName = "COM4";
  myPort = new Serial(this, portName, 9600);
  // read incoming bytes to a buffer until you get a linefedd(ASCII 10)
  myPort.bufferUntil('\n');
  
  weights = loadStrings("weights.txt");
  output = createWriter("data/weights.txt");  
  player1 = new AIPlayer("Black", true, weights);
  //player1 = new AIPlayer("Black", true);
  player2 = new Player("White", false);
  board = new Board(player1, player2);

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
    player1.updateWeights();
    for(int i=0; i<8; i++){
      output.println(player1.weightVector[i]);
    }
    println("END OF GAME");
    noLoop();
    output.flush();
    output.close();    
  }
  if (player1.currentPlayer) {
    // QLearning will return true if there is a valid move available, if false
    // black will pass
    if (player1.QLearning(board)) {
      board.RLblackMoves(player1.getRLMove().getRow(), player1.getRLMove().getCol(), true, true);
      drawBoard();
    } else { 
      player1.nxtPlayer();
      player2.nxtPlayer();
      text("Black must pass", 20, 20);
    }
  } else {
    if (userPressed) {      
      board.whiteMoves(playerX, playerY, true, true);
      userPressed = false;
    }
    drawBoard();
  }
}  

void mouseClicked() {
  playerX = mouseX/100;
  playerY = mouseY/100;
  userPressed = true;
}

void drawDisc(int x, int y, boolean black) {
  if (black) {
    fill(0);
  } else {
    fill(255);
  }
  int xValue = x * 100 + 50;
  int yValue = y * 100 + 50;
  noStroke();
  ellipse(xValue, yValue, 80, 80);
}

void drawBoard() {
  background(0, 255, 0);
  stroke(0);
  strokeWeight(4);
  for (int i=100; i<width; i+=100) {
    line(i, 0, i, height);
  }
  for (int i=100; i<height; i+=100) {
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
  if(myString != null){
    myString = trim(myString);
    
    // if you haven't heard from the microcontroller yet, listen
    if(firstContact == false) {
      if(myString.equals("hello")) {
        myPort.clear();          // clear the serial port buffer
        firstContact = true;     // you've had first contact from the microcontroller
        myPort.write(board.toString());       // ask for more, and send values for board
      }
    }
    // if you have heard from the microcontroller, proceed
    else {
      // split the string at the commas and convert the sections into integers
      //int sensors[][] = int(split(myString, ' '));
      
      // stuff
    }
    // when you've parsed the data you have, ask for more
    myPort.write(board.toString());
  }
}
        
  
