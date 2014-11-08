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
