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
    
