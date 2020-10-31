public class Button {
  String text;
  boolean isClicked = false;
  boolean isClickedOld = false;
  boolean isHeld3s = false;
  boolean isHeld3sOld = false;
  boolean isHeld = false;
  int timestamp;
  boolean justPressed = false;
  boolean justReleased = false;
  boolean justHeld3s = false;
  int x, y, w, h;

  boolean ignoreMouse = true;

  public Button(int _x, int _y, int _w, int _h, String _text) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    text = _text;
  }

  void update() {
    if (mousePressed) {
      ignoreMouse = false;
    }
    checkMouse();
    justPressed = false;
    justReleased = false;
    justHeld3s = false;
    isHeld = false;
    isHeld3s = false;
    


    if (isClicked == true && isClickedOld == false) {
      justPressed = true;
      timestamp = millis();
    }

    if (isClicked == false && isClickedOld == true) {
      justReleased = true;
    }

    if (isClicked == true && getHoldTime()>500) {
      isHeld = true;
    }

    if ((isClicked||justReleased) && getHoldTime()>3000) {
      isHeld3s = true;
    }
    
    if (isHeld3s == true && isHeld3sOld == false) {
      justHeld3s = true;
    }

    isClickedOld = isClicked;
    isHeld3sOld = isHeld3s;
  }

  int getHoldTime() {
    return (millis()-timestamp);
  }
  
    int getHoldTimeInSec() {
    return getHoldTime()/1000;
  }


  void draw() {
    noStroke();
    if (isClicked) fill(255, 100, 0,30);
    else noFill();//fill(0, 150, 255); 
    rect(x, y, w, h, 5); 
    fill(0);
  }

  void checkMouse() {
    if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h) {
      if (mousePressed) isClicked = true;
      else isClicked = false;
    }
  }
}
