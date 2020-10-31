class IERatioMenuItem extends MenuItem {
  float value, max, min, increment;

  float inhale;
  float exhale;

  IERatioMenuItem(int _lineIndex, int _startIndex, float _increment) {
    super(_lineIndex, _startIndex, 5);
    inhale = 1;
    exhale = 2;
    increment = _increment;
  }

  void increase() {
    exhale += increment;
    if (exhale>3) exhale = 3;

    /*
    if (inhale == 1 && exhale >= 1) {
     exhale -= increment;
     if (exhale > 3) exhale = 3;
     if (exhale < 1) exhale = 1;
     }
     if (exhale == 1 && inhale >= 1 ) {
     inhale += increment;
     if (inhale > 3) inhale = 3;
     if (inhale < 1) inhale = 1;
     }*/
  }

  void decrease() {     
    exhale -= increment;
    if (exhale<1) exhale = 1;
    /*
    if (inhale == 1 && exhale >= 1) {
     exhale += increment;
     if (exhale > 3) exhale = 3;
     if (exhale < 1) exhale = 1;
     }
     if (exhale == 1 && inhale >= 1 ) {
     inhale -= increment;
     if (inhale > 3) inhale = 3;
     if (inhale < 1) inhale = 1;
     }*/
  }

  float get() {
    return inhale/(inhale+exhale);
  }

  char[] getChar() {


    String inhaleStr = String.valueOf(inhale);
    String exhaleStr = String.valueOf(exhale);

    char[] valueCharArray = new char[numChars];

    if (inhale == 1) {
      valueCharArray[0] = inhaleStr.charAt(0);
      valueCharArray[1] = ':';
      valueCharArray[2] = exhaleStr.charAt(0);
      valueCharArray[3] = exhaleStr.charAt(1);
      valueCharArray[4] = exhaleStr.charAt(2);
    } else {
      valueCharArray[0] = inhaleStr.charAt(0);
      valueCharArray[1] = inhaleStr.charAt(1);
      valueCharArray[2] = inhaleStr.charAt(2);
      valueCharArray[3] = ':';
      valueCharArray[4] = exhaleStr.charAt(0);
    }
    return valueCharArray;
  }
}
