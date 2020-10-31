class TextMenuItem extends MenuItem {
  String text;

  TextMenuItem(int _lineIndex, int _startIndex, String _text) {
    super(_lineIndex, _startIndex, _text.length());
    text = _text;
  }

  void increase() {
  }

  void decrease() {
  }

  String get() {
    return text;
  }

  void set(String _text) {
    text = _text;
    numChars = text.length();
  }

  char[] getChar() {    
    char[] valueCharArray = new char[numChars];
    for (int j = 0; j < text.length() && j < numChars; j++) {
      // println(i + " - " + j);
      valueCharArray[j] =  text.charAt(j);
    }
    return valueCharArray;
  }
}
