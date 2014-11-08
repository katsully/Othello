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
