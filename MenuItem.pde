abstract class MenuItem {
  int lineIndex, startIndex;
  int numChars;

  MenuItem(int _lineIndex, int _startIndex, int _numChars) {
    lineIndex = _lineIndex;
    startIndex = _startIndex;
    numChars = _numChars;
  }
  
  abstract char[] getChar();
  
  abstract void increase();
  abstract void decrease();

  
  //abstract int get();
}
 
