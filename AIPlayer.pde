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
