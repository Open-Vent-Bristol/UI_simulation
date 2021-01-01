class ModeHandler extends MenuItem {
  int index;
  int txtIndex;

  String[] modesText = {"PCV ", "PSV ", "QCAL", "FCAL", "OFF "};


  ModeHandler(int _lineIndex, int _startIndex, int _index) {
    super(_lineIndex, _startIndex, 4);
    txtIndex = _index;
    setSelected();
  }

  void increase() {
    txtIndex ++;
    loop();
  }

  void decrease() {
    txtIndex --;
    loop();
  }

  void loop() {
    if (txtIndex > modesText.length-1) txtIndex = 0;
    if (txtIndex < 0) txtIndex = modesText.length-1;
    setSelected();
  }

  int get() {
    return index;
  }
  
   void set(int _index) {
     txtIndex = _index;
     setSelected();
  }
  
  void setSelected() {
    index = txtIndex;
  }

  char[] getChar() {

    char[] valueCharArray = new char[numChars];
    int i = 0;

    // fill up if value is bigger;

    for (int j = 0; j < modesText[index].length() && j < numChars; j++) {
      // println(i + " - " + j);
      valueCharArray[j+i] =  modesText[txtIndex].charAt(j);
    }

    return valueCharArray;
  }
}
