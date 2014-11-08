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
