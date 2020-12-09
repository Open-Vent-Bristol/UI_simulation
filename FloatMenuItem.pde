class FloatMenuItem extends MenuItem {
  float value, max, min, increment;

  FloatMenuItem(int _lineIndex, int _startIndex, int _numChars, 
    float _default, float _min, float  _max, float _increment) {
    super(_lineIndex, _startIndex, _numChars);
    value = _default;
    max = _max;
    min = _min;
    increment = _increment;
  }

  void increase() {
    value += increment;
    limit();
  }

  void decrease() {
    value -= increment;
    limit();
  }

  void limit() {
    if (value < min) value = min;
    if (value > max) value = max;
  }
  
  void setMin(int _min){
    min = _min;
    limit();
  }
  
  void setMax(int _max){
    max = _max;
    limit();
  }

  float get() {
    return value;
  }

  void set(int newValue) {
    value = newValue;
  }

  char[] getChar() {
    String valueStr = String.valueOf(value);
    
   // println(valueStr);
    char[] valueCharArray = new char[numChars];
    int i = 0;
    
    // fill up if value is bigger;
    while (numChars>valueStr.length()+i) {
      valueCharArray[i] = '0';
      i++;
    }

    for (int j = 0; j < valueStr.length() && j < numChars; j++) {
     // println(i + " - " + j);
      valueCharArray[j+i] =  valueStr.charAt(j);
    }

    return valueCharArray;
  }
}
