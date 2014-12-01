/////////////////////////////////////////
// By: Kat Sullivan
////////////////////////////////////////
PrintWriter output;

String[] weights;
AIPlayer player1;
Player player2;
Board board;

int playerX, playerY;
boolean userPressed = false;


void setup() {
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
//Kat Sullivan

import java.util.Stack;

public class AIPlayer extends Player
{
  //used for the linear function approximation
  private double[][] featureVector = new double[8][2];//the second double tells the user whether
  //it's for the current board or the board with a move
  // double[] weightVector = {
  //   3.226337608403137, 
  //   4.486854233577422, 
  //   5.83624728137885, 
  //   6.5096211433410645, 
  //   2.2986394602593334, 
  //   1.367803291625127, 
  //   1.6891207315180974, 
  //   -7.215159227568421
  // };  
  double[] weightVector = new double[8];

  private boolean firstMove = true;

  //used for the update rule
  private double stepSize = .01;
  private double reward = 0;
  private double Qfunction0 = 0;
  private double Qfunction1 = 0;

  private Stack<Move> RLStack = new Stack<Move>();
  public Move lastMove = new Move();
  public Move RLMove = new Move();

  //constructor based on the Player class
  public AIPlayer(String n, boolean playing, String[] weights)
  {
    super(n, playing);
    Double weight;
    for (int i=0; i<8; i++) {
      weight = Double.parseDouble(weights[i]);
      weightVector[i] = weight;
    }
  }

  public Move getRLMove() {
    return this.RLMove;
  }

  private void setFeatureVectors(Board b, int a)
  {
    featureVector[0][a]=0;
    featureVector[7][a]=0;
    //sets feature vector 0 and feature vector 7 based on the edges on the board        
    for (int i=0; i<8; i++)
    {
      if (b.getValue(i, 0)==1)
        featureVector[0][a]+=0.1;
      else
        if (b.getValue(i, 0)==2)
        featureVector[7][a]-=0.1;
    }

    featureVector[1][a]=0;
    featureVector[6][a]=0;
    //sets feature vector 1 and feature vector 6 based on the edges on the board
    for (int i=0; i<8; i=i+7)
    {
      for (int j=0; j<8; j++)
      {
        if (b.getValue(i, j)==1)
          if (i==0)
            featureVector[i+1][a]+=0.1;
          else
            featureVector[i-1][a]+=0.1;
        else
          if (b.getValue(i, j)==2)
          if (i==0)
            featureVector[i+1][a]-=0.1;
          else
            featureVector[i-1][a]-=0.1;
      }
    }

    //sets feature vector 2 (top left corner)
    if (b.getValue(0, 0)==1)
      featureVector[2][a]=1;
    else
      if (b.getValue(0, 0)==2)
      featureVector[2][a]=-1;

    //sets feature vector 3 (top right corner)
    if (b.getValue(0, 7)==1)
      featureVector[3][a]=1;
    else
      if (b.getValue(0, 7)==2)
      featureVector[3][a]=-1;

    //sets feature vector 4 (bottom left corner)
    if (b.getValue(7, 0)==1)
      featureVector[4][a]=1;
    else
      if (b.getValue(7, 0)==2)
      featureVector[4][a]=-1;

    //sets feature vector 5 (bottom right corner)
    if (b.getValue(7, 7)==1)
      featureVector[5][a]=1;
    else
      if (b.getValue(7, 7)==2)
      featureVector[5][a]=-1;
  }

  //this method sets all feature vectors to zero
  //called after every game (used while training RL)
  public void clearFeatures()
  {
    for (int i=0; i<8; i++)
    {
      featureVector[i][0]=0;
      featureVector[i][1]=0;
    }
  }   

  //Q(s,a) = w1f1(s,a) + w2f2(s,a) + .... + wkfk(s,a)
  public boolean QLearning(Board b)
  {
    boolean canMove = false;
    boolean generateMove=true;  

    //update feature vectors for the current board
    //update Q-Learning for the current board
    if (!firstMove)
    {   
      Qfunction0=Qfunction1;
      for (int i=0; i<8; i++)
        featureVector[i][0]=featureVector[i][1];
    }           

    //have black move
    for (int i=0; i<8; i++)
    {   
      if (featureVector[i][0]!=0)
        generateMove=false;
    }
    if (generateMove)
    {   
      if (randomMove(b))
        canMove=true;
    } else
    {   
      if (doSomething(b))
        canMove=true;
    }   

    setFeatureVectors(b, 1);

    //update Q-Learning for the board after black moves
    for (int i=0; i<8; i++) {
      Qfunction1+=(weightVector[i]*featureVector[i][1]);
    }

    firstMove=false;
    return canMove;
  }

  void updateWeights() {
    for (int i=0; i<8; i++) {
      weightVector[i] += stepSize*(reward+Qfunction1-Qfunction0)*featureVector[i][0];
      println(weightVector[i]);
    }
  }

  private boolean randomMove(Board b)
  {
    for (int i=0; i<8; i++)
    {
      for (int j=0; j<8; j++)
        if (b.getValue(i, j)==0)
          if (b.RLblackMoves(i, j, false, false)==true)
          {   
            b.RLblackMoves(i, j, true, false);
            RLMove = new Move(i, j);
            undoMove(b);
            return true;
          }
    }   

    return false;
  }   

  private boolean doSomething(Board b)
  {
    boolean foundMove = false;
    double counter;
    double valueOfMove = Double.NEGATIVE_INFINITY;

    if (b.gameOver(false))
    {
      return foundMove;
    }
    for (int i=0; i<8; i++)
      for (int j=0; j<8; j++)
      {
        if (b.RLblackMoves(i, j, false, false)==true)
        {
          b.RLblackMoves(i, j, true, false);
          setFeatureVectors(b, 1);
          counter=0;
          for (int k=0; k<8; k++)
            counter+=featureVector[k][1]*weightVector[k];
          undoMove(b);
          if (valueOfMove<counter)
          {   
            valueOfMove=counter;
            RLMove = lastMove;
            foundMove=true;
          }
        }
      }

    reward = valueOfMove;
    return foundMove;
  }

  public void onStack(Move m1)
  {
    RLStack.push(m1);
  }

  private void undoMove(Board b)
  {
    lastMove = RLStack.pop();
    int i = lastMove.getRow();
    int j = lastMove.getCol();
    //take piece off of the board
    b.removePiece(i, j);
    b.player1.subDisk();                 

    //return all pieces that were changed back to their original state
    for (int k=0; k<lastMove.moves.size (); k++)
    {   
      b.undoPiece(lastMove.moves.get(k).getRow(), lastMove.moves.get(k).getCol());
      b.player1.subDisk();     
      b.player2.addDisk();
    }
  }
}
//Kat Sullivan
//Artificial Intelligence
//January 30, 2012
public class Board 
{

  //declares a two dimensional array that represents each space on the board
  private int[][] grid = new int[8][8];
  AIPlayer player1;
  Player player2;

  public Board(AIPlayer player1, Player player2)
  {
    this.player1 = player1;
    this.player2 = player2;
  }

  //removes a piece that was placed on the board, used in undoMove()
  public void removePiece(int i, int j)
  {
    grid[i][j]=0;
  }

  //flips any piece on the board, used in undoMove()
  public void undoPiece(int i, int j)
  {
    if (grid[i][j]==1)
      grid[i][j]=2;
    else
      grid[i][j]=1;
  }

  //sets all 64 squares to zero (clears the board)
  //called after every game (used while training RL)
  public void clearBoard()
  {
    player1.clear();
    player2.clear();
    for (int i=0; i<8; i++)
      for (int j=0; j<8; j++)
        grid[i][j]=0;
  }

  //tells whether a square on the board has a black disk, white disk, or is empty
  public int getValue(int i, int k)
  {
    return grid[i][k];
  }

  //determines whether the game is over
  //if print is true, prints the result of the game to the console
  //set print to false during training to increase running time
  public boolean gameOver(boolean print)
  {
    if (boardFull())
    {
      if (print)
        endOfGame();
      return true;
    }

    if (!validMove1(player1, print) && !validMove2(player2, print))
    {
      if (print)
        endOfGame();
      return true;
    }

    return false;
  }

  private void endOfGame()
  {
    if (player1.getDisks() > player2.getDisks())
      System.out.println("Player 1 Wins!");
    if (player1.getDisks() < player2.getDisks())
      System.out.println("Player 2 Wins!");
    if (player1.getDisks() == player2.getDisks())
      System.out.println("Draw");
  }

  //determine if the human player has at least one valid move on the board
  public boolean validMove1(AIPlayer p1, boolean print)
  {
    if (boardFull())
      return false;

    for (int i=0; i<8; i++)
      for (int j=0; j<8; j++)
        if (grid[i][j]==0)
        {
          if (blackMoves(i, j, false, false)==true)
            return true;
        }

    if (p1.currentPlayer)
    {   
      if (print)
        System.out.println("Black must pass");
    }

    return false;
  }

  //determine if the alpha beta player has at least one valid move on the board
  public boolean validMove2(Player p1, boolean print)
  {
    if (boardFull())
      return false;

    for (int i=0; i<8; i++)
      for (int j=0; j<8; j++)
        if (grid[i][j]==0)
        {
          if (whiteMoves(i, j, false, false))
            return true;
        }

    if (p1.currentPlayer)
    {   
      if (print)
        System.out.println("White must pass");
    }

    return false;
  }

  //this method determines if there is no empty space left on the board
  private boolean boardFull()
  {
    for (int i=0; i<8; i++)
      for (int j=0; j<8; j++)
        if (grid[i][j]==0)
          return false;

    return true;
  }

  //this method can be used to determine if a square is a valid move as well as place
  //a disk on the board
  public boolean RLblackMoves(int i, int k, boolean makeMoves, boolean finalMove)
  {
    Move m1 = new Move(i, k);
    boolean validMove=false;
    if (grid[i][k]!=0)
      return validMove;
    int flips[][] = new int[12][6];
    if (!onEdge0(i, 0) && grid[i-1][k]==2)
    {   
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i-j, k, 0) && grid[i-j][k]==2)
          flips[0][j-2]=(i-j);
        else
          if (grid[i-j][k]==1)
        {   
          if (makeMoves)
          {
            m1.addPiece(i-1, k);
            flipIt(i-1, k, 1);
            int a=0;
            while (flips[0][a]!=0)
            {   
              flipIt(flips[0][a], k, 1);
              m1.addPiece(flips[0][a], k);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }   
    if (!onEdge0(i, 1) && grid[i+1][k] == 2)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i+j, k, 1) && grid[i+j][k]==2)
          flips[1][j-2]=(i+j);
        else
          if (grid[i+j][k]==1)
        {   
          if (makeMoves)
          {   
            m1.addPiece(i+1, k);
            flipIt(i+1, k, 1);
            int a=0;
            while (flips[1][a]!=0)
            {   
              flipIt(flips[1][a], k, 1);
              m1.addPiece(flips[1][a], k);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge0(k, 0) && grid[i][k-1] == 2)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i, k-j, 2) && grid[i][k-j]==2)
          flips[2][j-2]=(k-j);
        else
          if (grid[i][k-j]==1)
        {   
          if (makeMoves)
          {   
            m1.addPiece(i, k-1);
            flipIt(i, k-1, 1);
            int a=0;
            while (flips[2][a]!=0)
            {   
              flipIt(i, flips[2][a], 1);
              m1.addPiece(i, flips[2][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge0(k, 1) && grid[i][k+1] == 2)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i, k+j, 3) && grid[i][k+j]==2)
          flips[3][j-2]=(k+j);
        else
          if (grid[i][k+j]==1)
        {   
          if (makeMoves)
          {   
            m1.addPiece(i, k+1);
            flipIt(i, k+1, 1);
            int a=0;
            while (flips[3][a]!=0)
            {   
              flipIt(i, flips[3][a], 1);
              m1.addPiece(i, flips[3][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge1(i, k, 0) && grid[i+1][k+1] == 2)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i+j, k+j, 4) && grid[i+j][k+j]==2)
        {   
          flips[4][j-2]=(i+j);                        
          flips[5][j-2]=(k+j);
        } else
          if (grid[i+j][k+j]==1)
        {
          if (makeMoves)
          {   
            m1.addPiece(i+1, k+1);
            flipIt(i+1, k+1, 1);
            int a=0;
            while (flips[4][a]!=0)
            {
              flipIt(flips[4][a], flips[5][a], 1);
              m1.addPiece(flips[4][a], flips[5][a]);
              a++;
            }
          }   
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge1(i, k, 1) && grid[i-1][k+1] == 2)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i-j, k+j, 5) && grid[i-j][k+j]==2)
        {   
          flips[6][j-2]=(i-j);                        
          flips[7][j-2]=(k+j);
        } else
          if (grid[i-j][k+j]==1)
        {
          if (makeMoves)
          {   
            m1.addPiece(i-1, k+1);
            flipIt(i-1, k+1, 1);
            int a=0;
            while (flips[6][a]!=0)
            {
              flipIt(flips[6][a], flips[7][a], 1);
              m1.addPiece(flips[6][a], flips[7][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge1(i, k, 2) && grid[i+1][k-1] == 2)
    {           
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i+j, k-j, 6) && grid[i+j][k-j]==2)
        {   
          flips[8][j-2]=(i+j);                        
          flips[9][j-2]=(k-j);
        } else
          if (grid[i+j][k-j]==1)
        {
          if (makeMoves)
          {   
            m1.addPiece(i+1, k-1);
            flipIt(i+1, k-1, 1);
            int a=0;
            while (flips[8][a]!=0)
            {
              flipIt(flips[8][a], flips[9][a], 1);
              m1.addPiece(flips[8][a], flips[9][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge1(i, k, 3) && grid[i-1][k-1] == 2)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i-j, k-j, 7) && grid[i-j][k-j]==2)
        {   
          flips[10][j-2]=(i-j);                       
          flips[11][j-2]=(k-j);
        } else
          if (grid[i-j][k-j]==1)
        {
          if (makeMoves)
          {
            m1.addPiece(i-1, k-1);
            flipIt(i-1, k-1, 1);
            int a=0;
            while (flips[10][a]!=0)
            {
              flipIt(flips[10][a], flips[11][a], 1);
              m1.addPiece(flips[10][a], flips[11][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (validMove && makeMoves)
    {           
      bpieceOnBoard(i, k, finalMove);
      player1.onStack(m1);
    }
    return validMove;
  }

  //this method can be used to determine if a square is a valid move as well as place
  //a disk on the board
  public boolean blackMoves(int i, int k, boolean makeMoves, boolean finalMove)
  {
    Move m1 = new Move(i, k);
    boolean validMove=false;
    if (grid[i][k]!=0)
      return validMove;
    int flips[][] = new int[12][6];
    if (!onEdge0(i, 0) && grid[i-1][k]==2)
    {   
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i-j, k, 0) && grid[i-j][k]==2)
          flips[0][j-2]=(i-j);
        else
          if (grid[i-j][k]==1)
        {   
          if (makeMoves)
          {
            m1.addPiece(i-1, k);
            flipIt(i-1, k, 1);
            int a=0;
            while (flips[0][a]!=0)
            {   
              flipIt(flips[0][a], k, 1);
              m1.addPiece(flips[0][a], k);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }   
    if (!onEdge0(i, 1) && grid[i+1][k] == 2)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i+j, k, 1) && grid[i+j][k]==2)
          flips[1][j-2]=(i+j);
        else
          if (grid[i+j][k]==1)
        {   
          if (makeMoves)
          {   
            m1.addPiece(i+1, k);
            flipIt(i+1, k, 1);
            int a=0;
            while (flips[1][a]!=0)
            {   
              flipIt(flips[1][a], k, 1);
              m1.addPiece(flips[1][a], k);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge0(k, 0) && grid[i][k-1] == 2)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i, k-j, 2) && grid[i][k-j]==2)
          flips[2][j-2]=(k-j);
        else
          if (grid[i][k-j]==1)
        {   
          if (makeMoves)
          {   
            m1.addPiece(i, k-1);
            flipIt(i, k-1, 1);
            int a=0;
            while (flips[2][a]!=0)
            {   
              flipIt(i, flips[2][a], 1);
              m1.addPiece(i, flips[2][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge0(k, 1) && grid[i][k+1] == 2)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i, k+j, 3) && grid[i][k+j]==2)
          flips[3][j-2]=(k+j);
        else
          if (grid[i][k+j]==1)
        {   
          if (makeMoves)
          {   
            m1.addPiece(i, k+1);
            flipIt(i, k+1, 1);
            int a=0;
            while (flips[3][a]!=0)
            {   
              flipIt(i, flips[3][a], 1);
              m1.addPiece(i, flips[3][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge1(i, k, 0) && grid[i+1][k+1] == 2)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i+j, k+j, 4) && grid[i+j][k+j]==2)
        {   
          flips[4][j-2]=(i+j);                        
          flips[5][j-2]=(k+j);
        } else
          if (grid[i+j][k+j]==1)
        {
          if (makeMoves)
          {   
            m1.addPiece(i+1, k+1);
            flipIt(i+1, k+1, 1);
            int a=0;
            while (flips[4][a]!=0)
            {
              flipIt(flips[4][a], flips[5][a], 1);
              m1.addPiece(flips[4][a], flips[5][a]);
              a++;
            }
          }   
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge1(i, k, 1) && grid[i-1][k+1] == 2)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i-j, k+j, 5) && grid[i-j][k+j]==2)
        {   
          flips[6][j-2]=(i-j);                        
          flips[7][j-2]=(k+j);
        } else
          if (grid[i-j][k+j]==1)
        {
          if (makeMoves)
          {   
            m1.addPiece(i-1, k+1);
            flipIt(i-1, k+1, 1);
            int a=0;
            while (flips[6][a]!=0)
            {
              flipIt(flips[6][a], flips[7][a], 1);
              m1.addPiece(flips[6][a], flips[7][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge1(i, k, 2) && grid[i+1][k-1] == 2)
    {           
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i+j, k-j, 6) && grid[i+j][k-j]==2)
        {   
          flips[8][j-2]=(i+j);                        
          flips[9][j-2]=(k-j);
        } else
          if (grid[i+j][k-j]==1)
        {
          if (makeMoves)
          {   
            m1.addPiece(i+1, k-1);
            flipIt(i+1, k-1, 1);
            int a=0;
            while (flips[8][a]!=0)
            {
              flipIt(flips[8][a], flips[9][a], 1);
              m1.addPiece(flips[8][a], flips[9][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge1(i, k, 3) && grid[i-1][k-1] == 2)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i-j, k-j, 7) && grid[i-j][k-j]==2)
        {   
          flips[10][j-2]=(i-j);                       
          flips[11][j-2]=(k-j);
        } else
          if (grid[i-j][k-j]==1)
        {
          if (makeMoves)
          {
            m1.addPiece(i-1, k-1);
            flipIt(i-1, k-1, 1);
            int a=0;
            while (flips[10][a]!=0)
            {
              flipIt(flips[10][a], flips[11][a], 1);
              m1.addPiece(flips[10][a], flips[11][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (validMove && makeMoves)
    {           
      bpieceOnBoard(i, k, finalMove);
      player1.onStack(m1);
    }
    return validMove;
  }

  public void bpieceOnBoard(int i, int k, boolean changePlayer)
  {
    grid[i][k] = 1;
    player1.addDisk();
    if (validMove2(player2, false)==true && changePlayer)
    {
      player1.nxtPlayer();
      player2.nxtPlayer();
    }
  }

  //this method can be used to determine if a square is a valid move as well as place
  //a disk on the board
  public boolean whiteMoves(int i, int k, boolean makeMoves, boolean finalMove)
  {       
    Move m2 = new Move(i, k);
    boolean validMove = false;
    if (grid[i][k]!=0)
    {   
      validMove = false;
      return validMove;
    }
    int flips[][] = new int[12][6];
    if (!onEdge0(i, 0) && grid[i-1][k] == 1)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i-j, k, 0) && grid[i-j][k]==1)
          flips[0][j-2]=(i-j);
        else
          if (grid[i-j][k]==2)
        {   
          if (makeMoves)
          {   
            m2.addPiece(i-1, k);
            flipIt(i-1, k, 2);
            int a=0;
            while (flips[0][a]!=0)
            {   
              flipIt(flips[0][a], k, 2);
              m2.addPiece(flips[0][a], k);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge0(i, 1) && grid[i+1][k] == 1)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i+j, k, 1) && grid[i+j][k]==1)
          flips[1][j-2]=(i+j);
        else
          if (grid[i+j][k]==2)
        {   
          if (makeMoves)
          {
            m2.addPiece(i+1, k);
            flipIt(i+1, k, 2);
            int a=0;
            while (flips[1][a]!=0)
            {   
              flipIt(flips[1][a], k, 2);
              m2.addPiece(flips[1][a], k);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge0(k, 0) && grid[i][k-1] == 1)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i, k-j, 2) && grid[i][k-j]==1)
          flips[2][j-2]=(k-j);                    
        else
          if (grid[i][k-j]==2)
        {   
          if (makeMoves)
          {
            m2.addPiece(i, k-1);
            flipIt(i, k-1, 2);
            int a=0;
            while (flips[2][a]!=0)
            {   
              flipIt(i, flips[2][a], 2);
              m2.addPiece(i, flips[2][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge0(k, 1) && grid[i][k+1] == 1)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i, k+j, 3) && grid[i][k+j]==1)
          flips[3][j-2]=(k+j);
        else
          if (grid[i][k+j]==2)
        {   
          if (makeMoves)
          {
            m2.addPiece(i, k+1);
            flipIt(i, k+1, 2);
            int a=0;
            while (flips[3][a]!=0)
            {   
              flipIt(i, flips[3][a], 2);
              m2.addPiece(i, flips[3][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge1(i, k, 0) && grid[i+1][k+1] == 1)
    {           
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i+j, k+j, 4) && grid[i+j][k+j]==1)
        {   
          flips[4][j-2]=(i+j);                        
          flips[5][j-2]=(k+j);
        } else
          if (grid[i+j][k+j]==2)
        {
          if (makeMoves)
          {
            m2.addPiece(i+1, k+1);
            flipIt(i+1, k+1, 2);
            int a=0;
            while (flips[4][a]!=0)
            {
              flipIt(flips[4][a], flips[5][a], 2);
              m2.addPiece(flips[4][a], flips[5][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge1(i, k, 1) && grid[i-1][k+1] == 1)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i-j, k+j, 5) && grid[i-j][k+j]==1)
        {   
          flips[6][j-2]=(i-j);                        
          flips[7][j-2]=(k+j);
        } else
          if (grid[i-j][k+j]==2)
        {
          if (makeMoves)
          {   
            m2.addPiece(i-1, k+1);
            flipIt(i-1, k+1, 2);
            int a=0;
            while (flips[6][a]!=0)
            {
              flipIt(flips[6][a], flips[7][a], 2);
              m2.addPiece(flips[6][a], flips[7][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge1(i, k, 2) && grid[i+1][k-1] == 1)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i+j, k-j, 6) && grid[i+j][k-j]==1)
        {   
          flips[8][j-2]=(i+j);                        
          flips[9][j-2]=(k-j);
        } else
          if (grid[i+j][k-j]==2)
        {
          if (makeMoves)
          {
            m2.addPiece(i+1, k-1);
            flipIt(i+1, k-1, 2);
            int a=0;
            while (flips[8][a]!=0)
            {
              flipIt(flips[8][a], flips[9][a], 2);
              m2.addPiece(flips[8][a], flips[9][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (!onEdge1(i, k, 3) && grid[i-1][k-1] == 1)
    {
      for (int j=2; j<8; j++)
      {
        if (!onEdge2(i-j, k-j, 7) && grid[i-j][k-j]==1)
        {   
          flips[10][j-2]=(i-j);                       
          flips[11][j-2]=(k-j);
        } else
          if (grid[i-j][k-j]==2)
        {
          if (makeMoves)
          {   
            m2.addPiece(i-1, k-1);
            flipIt(i-1, k-1, 2);
            int a=0;
            while (flips[10][a]!=0)
            {
              flipIt(flips[10][a], flips[11][a], 2);
              m2.addPiece(flips[10][a], flips[11][a]);
              a++;
            }
          }
          validMove=true;
          break;
        } else
          break;
      }
    }
    if (validMove && makeMoves)
    {           
      wpieceOnBoard(i, k, finalMove);
      //player1.onStack(m2);
    }
    return validMove;
  }

  public void wpieceOnBoard(int i, int k, boolean changePlayer)
  {
    grid[i][k] = 2;
    player2.addDisk();
    if (validMove1(player1, false)==true && changePlayer)
    {
      player1.nxtPlayer();
      player2.nxtPlayer();
    }
  }

  //flips a disk to the opposite side
  private void flipIt(int i, int k, int player)
  {
    if (player == 1)
    {
      grid[i][k] = 1;
      player1.addDisk();
      player2.subDisk();
    } else
    {
      grid[i][k] = 2;
      player2.addDisk();
      player1.subDisk();
    }
  }

  private boolean onEdge0(int a, int c)
  {
    boolean b1 = false;
    if (c == 0)
      if (a < 2)
        b1=true;
    if (c == 1)
      if (a > 5)
        b1=true;
    return b1;
  }

  private boolean onEdge1(int a, int b, int c)
  {
    boolean b1 = false;
    if (c == 0)
      if (a > 5 || b > 5)
        b1=true;
    if (c == 1)
      if (a < 2 || b > 5)
        b1=true;
    if (c == 2)
      if (a > 5 || b < 2)
        b1=true;
    if (c == 3)
      if (a < 2 || b < 2)
        b1=true;

    return b1;
  }

  private boolean onEdge2(int a, int b, int c)
  {
    boolean b1 = false;
    if (c == 0)
      if (a <= 0)
        b1=true;
    if (c == 1)
      if (a >= 7)
        b1=true;
    if (c == 2)
      if (b <=0)
        b1=true;
    if (c == 3)
      if (b >= 7)
        b1=true;
    if (c == 4)
      if (a >= 7 || b >= 7)
        b1=true;
    if (c == 5)
      if (a <= 0 || b >= 7)
        b1=true;
    if (c == 6)
      if (a >= 7 || b <= 0)
        b1=true;
    if (c == 7)
      if (a <= 0 || b <= 0)
        b1=true;

    return b1;
  }

  public String toString()
  {
    String s1="";

    for (int i=0; i<8; i++)
    {
      if (i>0)
        s1 += "\n";     
      for (int j=0; j<8; j++)
        s1 += (grid[i][j]) + " ";
    }

    return s1;
  }
}
// //Kat Sullivan
 
// public class Game {
 
//     //creates the 8x8 board
//     public int rows = 8;
//     public int cols = 8;
         
//     //players
//     public AIPlayer player1 = new AIPlayer ("Black", true);
//     public Player player2 = new Player ("White", false);
     
//     //create new board
//     public static Board b1 = new Board();
 
 
//     public static void main(String[] args) 
//     {
         
//             //first moves
//             b1.bpieceOnBoard(3,3, false);
//             b1.wpieceOnBoard(3,4, false);
//             b1.bpieceOnBoard(4,4, false);
//             b1.wpieceOnBoard(4,3, false);
                     
//             System.out.println(b1.toString());
         
//             while(!b1.gameOver(false))
//             {
//                 if(player1.currentPlayer)
//                 {
//                     //QLearning will return true if there is a valid move available, if false 
//                     //black will pass
//                     if(player1.QLearning(b1))
//                         b1.RLblackMoves(AIPlayer.RLMove.getRow(), AIPlayer.RLMove.getCol(), true, true);
//                     else
//                     {
//                         player1.nxtPlayer();
//                         player2.nxtPlayer();
//                         System.out.println("Black must pass");
//                     }       
//                 }
//                 //player 2
//                 else
//                 {
//                     /*System.out.println("Player 2 move ");
//                     int i = keyboard.nextInt();
//                     System.out.println("Player 2 move ");
//                     int k = keyboard.nextInt();
//                     b1.whiteMoves(i-1, k-1, true, true);*/             
                     
//                     player2.minValue(b1, -5000, 5000, 10, 0);
//                     b1.whiteMoves(AIPlayer.RLMove.getRow(), AIPlay.RLMove.getCol(), true, true);    
//                 }
//                 System.out.println();
//                 System.out.println(b1.toString());
//                 System.out.println(Othello.player1.toString());
//                 System.out.println(Othello.player2.toString());
//                 System.out.println();       
                 
//             }               
             
//         }               
//     }
    
import java.util.*;
 
public class Move
{
    //where the initial piece is placed
    private int rowOfPiece;
    private int colOfPiece;
     
    //all pieces that are going to be flipped
    ArrayList<Move> moves = new ArrayList<Move>();
     
    public Move()
    {
         
    }
     
    //this represents the original piece placed on the board 
    public Move(int rFirstPiece, int cFirstPiece)
    {
        rowOfPiece = rFirstPiece;
        colOfPiece = cFirstPiece;
    }
     
    public void firstMove(int rFirstPiece, int cFirstPiece)
    {
        rowOfPiece = rFirstPiece;
        colOfPiece = cFirstPiece;
    }
     
    public void addPiece(int rFlip, int cFlip)
    {
        Move m1 = new Move(rFlip, cFlip);
        moves.add(m1);
    }
     
    public int getRow()
    {
        return rowOfPiece;      
    }
     
    public int getCol()
    {
        return colOfPiece;
    }
     
}
//Kat Sullivan
public class Player 
{
  public String name;
  public int numOfDisks;
  public boolean currentPlayer;

  public Player(String n, boolean playing)
  {
    name = n;
    currentPlayer = playing;
    numOfDisks=0;
  }

  public String toString()
  {
    String s1=name + " - " + numOfDisks + " chips";

    return s1;
  }

  public String getName()
  {
    return name;
  }

  public int getDisks()
  {
    return numOfDisks;
  }

  public void addDisk()
  {
    numOfDisks++;
  }

  public void subDisk()
  {
    numOfDisks--;
  }

  public void nxtPlayer()
  {
    currentPlayer = !currentPlayer;
  }

  public void clear()
  {
    numOfDisks=0;
  }
}

