import processing.sound.*; //<>// //<>//

String releaseTag = "V12 24.Mai 2021";

PFont fLCD;
PImage overlay;

SoundFile triggerSound;
SoundFile holdSound;

SimulateMachine sim = new SimulateMachine();

IntMenuItem pressure = new IntMenuItem(0, 1, 2, 35, 0, 45, 1); 
IntMenuItem bpm = new IntMenuItem(0, 4, 2, 20, 10, 30, 2); 
FloatMenuItem iT = new FloatMenuItem(0, 7, 3, 2.0, 0.0, 6.0, 0.1); 
IntMenuItem apnea = new IntMenuItem(0, 11, 2, 20, 0, 60, 1); 
IntMenuItem deltaPT = new IntMenuItem(0, 14, 2, 2, 0, 20, 1); 
//IERatioMenuItem ieRatio = new IERatioMenuItem(0, 7, 0.1); 
IntMenuItem lowerTidalVolume = new IntMenuItem(1, 13, 3, 400, 0, 700, 10); 
IntMenuItem upperTidalVolume = new IntMenuItem(1, 9, 3, 500, 0, 700, 10); 
IntMenuItem fio2 = new IntMenuItem(1, 5, 3, 20, 0, 100, 5); 

// Modes: 0 - PCV, 1 - PSV, 2 - QCAL, 3 - FCAL, 4 - OFF
ModeHandler modeHandler = new ModeHandler(1, 1, 4);


ArrayList<MenuItem> menuPCV = new ArrayList<MenuItem>();
ArrayList<MenuItem> menuPSV = new ArrayList<MenuItem>();
ArrayList<MenuItem> menuCal = new ArrayList<MenuItem>();

char[][] lcdSet;
char[][] lcdMeas;
char selectChar = '>';
char editChar = '>';

int lastInputTimeStamp = 0;
int lastModeSelectedTimeStamp = 0;
int lastSec = 0;

int menuIndex;
int oldModeState = 4;

int standbyTransition = 0; 
int standbyChangeTimestamp = 0;

boolean isEditing;


Button[] buttons;

String[] buttonsText = {"Edit", "-", "+", "Mute\nStandby"}; 

boolean isEditMode = false;
boolean isStandby = false;

int xLCDMeas = 118;
int yLCDMeas = 278;
int xLCDSet = xLCDMeas + 537;
int yLCDSet = yLCDMeas;
int fontSize = 28;
int fontH = 28;
float fontW = 20.8;
int wLCD = 392;
int hLCD = 97;

void setup() {
  size(1455, 1098);
  background(0);
  overlay = loadImage("frontpanel.png");

  menuPCV.add(pressure);
  menuPCV.add(bpm);
  menuPCV.add(iT);
  menuPCV.add(lowerTidalVolume);
  menuPCV.add(upperTidalVolume);
  menuPCV.add(fio2);
  menuPCV.add(modeHandler);

  menuPSV.add(pressure);
  menuPSV.add(apnea);
  menuPSV.add(deltaPT);
  menuPSV.add(lowerTidalVolume);
  menuPSV.add(upperTidalVolume);
  menuPSV.add(fio2);
  menuPSV.add(modeHandler);

  menuCal.add(modeHandler);

  lcdSet = new char[16][2];
  lcdMeas = new char[16][2];

  clearLCDs();



  buttons = new Button[buttonsText.length];
  for (int i = 0; i < buttonsText.length; i++) {
    buttons[i] = new Button(422+i*85, 475, 66, 66, buttonsText[i]);
  }

  // Create the font
  fLCD = createFont("5x8-LCD.ttf", fontSize); //createFont("SourceCodePro-Regular.ttf", 24);


  triggerSound = new SoundFile(this, "tick.aif");
  holdSound = new SoundFile(this, "Boop_256_8cyc.aif");

  /*
  draw();
   save("screen.png");
   */
} 

void clearLCDs() {
  for (int i = 0; i<lcdSet.length; i++) {
    for (int j = 0; j<lcdSet[i].length; j++) {

      lcdSet[i][j] = ' ';
      lcdMeas[i][j] = ' ';
    }
  }
}

void startupMachineDefinition() {

  modeHandler.set(0);
  isEditMode = true;
  isStandby = true;
}


void draw() {
  clearLCDs();

  sim.updateValues(pressure.get(), bpm.get(), iT.get());

  // Sound control on button action
  for (int i = 0; i<buttons.length; i++) {
    buttons[i].update();
    if (buttons[i].justReleased && !buttons[i].isHeld3s) {
      triggerSound.play();
    }
    if (buttons[i].justHeld3s) {
      holdSound.play();
    }
  }

  // sound control on state transition
  if (buttons[3].isHeld &&  !isStandby) {
    if (buttons[3].justHeld1s)
    {
      holdSound.play();
    }
    if (buttons[3].getHoldTimeInSec()>1 && buttons[3].getHoldTime()<3001) {
      if ((buttons[3].getHoldTime()/125)%2 == 0) {
        holdSound.play();
        delay(125); // not a nice way to avoid multi sound triggers.
      }
    }
  }

  // if no action within the last 120 sec. go to idle
  boolean noAction = true;
  for (int i = 0; i < 3; i++) {
    if (millis()-buttons[i].timestamp < 120000) {
      noAction = false;
    }
  }
  if (noAction) {
    isEditMode = false;
  }


  ArrayList<MenuItem> menu = menuPCV;
  switch (modeHandler.get()) {
  case 0:
    if (isStandby) {
      updateMeasLCD_topRow("MODE: PCV");
      updateMeasLCD_botRow("Standby");
    } else {
      updateMeasLCD_breath();
    }
    runMachine(menuPCV);
    menu = menuPCV;
    break;
  case 1:
    if (isStandby) {
      updateMeasLCD_topRow("MODE: PSV");
      updateMeasLCD_botRow("Standby");
    } else {
      updateMeasLCD_breath();
    }
    runMachine(menuPSV);
    menu = menuPCV;
    break;
  case 2:
    quickCalibration();
    runMachine(menuCal);
    menu = menuPCV;

    break;
  case 3:
    fullCalibration();
    runMachine(menuCal);
    menu = menuPCV;

    break;
  case 4: // OFF / STORAGE   
    if (isStandby) {
      updateMeasLCD_topRow("Hold Mute/Select");
      updateMeasLCD_botRow("To turn off");
      runMachine(menuCal);
      menu = menuPCV;
    }

    if (buttons[0].justHeld3s) {
      startupMachineDefinition();
    }
    break;
  }


  // ugly way to deal with calibrationstate reset on mode change
  if (modeHandler.get() != oldModeState) {
    calState = 0;
    menuIndex = menu.size()-1;
  }
  oldModeState = modeHandler.get();

  background(150);
  image(overlay, 0, 0, overlay.width, overlay.height);

  if (modeHandler.get() == 4 && !isStandby) { // not OFF
    drawOffLCDs();
  } else {
    drawLCDs();
  }

  for (int i = 0; i<buttons.length; i++) {
    buttons[i].draw();
  }

  fill(0);
  text(releaseTag, 100, 20);
}


void runMachine(ArrayList<MenuItem> menu) {

  // drawing menues;
  char menuChar = ' ';

  // Holding edit button for 3 sec toggles Edit Mode
  if (buttons[0].justHeld3s) {
    isEditMode = !isEditMode;
  } 

  // switch standby/run mode
  switch(standbyTransition) {

  case 0:
    {
      if (buttons[3].justHeld3s) {
        standbyTransition = 1;
        standbyChangeTimestamp = millis();
      }
    }
    break;

  case 1:
    {
      if (buttons[0].justPressed) {
        standbyTransition = 0;
        isStandby = !isStandby;
      } else if (buttons[1].justPressed || buttons[2].justPressed || buttons[3].justPressed) {
        standbyTransition = 0;
      }
      if (millis()-standbyChangeTimestamp>10000) {
        standbyTransition = 0;
      }
    }
    break;
  }    



  if (!isEditMode) {
    updateMenuOnLCD(menu);
  } else {
    if (menuIndex>menu.size()-1) {
      menuIndex = menu.size()-1;
    }
    MenuItem miEdit = menu.get(menuIndex);
    boolean isModeMenu = menuIndex == menu.size()-1;

    if (isEditing) {
      if (buttons[0].justReleased) isEditing = false;
      if (isStandby || !isModeMenu) {
        if (buttons[2].justReleased) miEdit.increase();
        if (buttons[1].justReleased) miEdit.decrease();
      }

      menuChar = editChar;
    } else {
      if (buttons[0].justReleased && !buttons[0].isHeld3s) isEditing = true;

      selectMenuItem(menu);
      menuChar = selectChar;
    }

    // blink cursor
    boolean doBlink = false;
    if (millis()%800 >= 600) {
      //menuChar = ' ';
      doBlink = true;
    }


    // go to submenu Mode
    if (isModeMenu) {
      if (buttons[0].justReleased) {
        modeHandler.setSelected();
        //lastModeSelectedTimeStamp = millis();
      }
    }


    // update lcd
    updateMenuOnLCD(menu);
    // draw cursor
    lcdSet[miEdit.startIndex-1][miEdit.lineIndex] = menuChar;
    if (doBlink) {
      if (isEditing) {
        for (int i = 0; i < miEdit.numChars; i++) {
          lcdSet[miEdit.startIndex+i][miEdit.lineIndex] = ' ';
        }
      } else {
        lcdSet[miEdit.startIndex-1][miEdit.lineIndex] = ' ';
      }
    }
  }
  // confirm screen
  if (standbyTransition == 1) {
    updateConfirmLCD();
  }
}



MenuItem selectMenuItem(ArrayList<MenuItem> menu) {

  if (buttons[2].justReleased) menuIndex +=1;
  if (buttons[1].justReleased) menuIndex -=1;

  if (menuIndex >= menu.size()) menuIndex = 0;
  if (menuIndex < 0) menuIndex = menu.size()-1;
  // menuIndex = menuIndex % menu.size();

  return menu.get(menuIndex);
}


void updateMenuOnLCD(ArrayList<MenuItem> menu) {
  for (MenuItem mi : menu) {
    char[] charArray = mi.getChar();
    for (int i = 0; i<charArray.length; i++) {
      lcdSet[mi.startIndex+i][mi.lineIndex] = charArray[i];
      lcdSet[mi.startIndex-1][mi.lineIndex] = ' ';
    }
  }
}

void updateKeepHoldLCD(int sec, char[] target) {
  String text0 = "HOLD FOR XSEC TO";
  String text1 = "CHANGE TO       ";
  for (int i = 0; i<16; i++) {
    lcdSet[i][0] = text0.charAt(i);
    lcdSet[i][1] = text1.charAt(i);
  }
  // write sec
  lcdSet[9][0] = String.valueOf(sec).charAt(0);

  // write target
  for (int i = 0; i<target.length && i<6; i++) {
    lcdSet[10+i][1] = target[i];
  }
}

void updateConfirmLCD() {
  String text0 = "Select > run Ma.";
  if (!isStandby) {
    text0 = "Select > Standby";
  }
  String text1 = "AnyKey > return ";
  for (int i = 0; i<16; i++) {
    lcdSet[i][0] = text0.charAt(i);
    lcdSet[i][1] = text1.charAt(i);
  }
}

void updateInfoSetLCD(String text) {
  for (int i = 0; i<text.length(); i++) {
    if (i<16) {
      lcdSet[i][0] = text.charAt(i);
    } else {
      lcdSet[i-16][1] = text.charAt(i);
    }
  }
}

void updateMeasLCD_topRow(String text) {
  for (int i = 0; i<16; i++) {
    if (i<text.length()) {
      lcdMeas[i][0] = text.charAt(i);
    } else {
      lcdMeas[i][0] = ' ';
    }
  }
}

void updateMeasLCD_botRow(String text) {
  for (int i = 0; i<16; i++) {
    if (i<text.length()) {
      lcdMeas[i][1] = text.charAt(i);
    } else {
      lcdMeas[i][1] = ' ';
    }
  }
}


void updateMeasLCD_breath() {

  float targetVol = 432;
  char volChar[] = getChar( sim.createVolCurve()*targetVol, 3);
  for (int i = 0; i<volChar.length; i++) {
    lcdMeas[i][0] =  volChar[i];
  }

  float targetFlow = 53;
  char flowChar[] = getChar( sim.createFlowCurve()*targetFlow, 4);
  for (int i = 0; i<flowChar.length; i++) {
    lcdMeas[i+4][0] =  flowChar[i];
  }

  char bpmChar[] = getChar( sim.createBPM()*bpm.get(), 2);
  for (int i = 0; i<bpmChar.length; i++) {
    lcdMeas[i+9][0] =  bpmChar[i];
  }

  int calcFio2 = int(fio2.get()+noise(minute())*0.05);
  char fio2Char[] = getChar( calcFio2, 3);
  for (int i = 0; i<fio2Char.length; i++) {
    lcdMeas[i+12][0] =  fio2Char[i];
  }

  lcdMeas[15][0] =  '§';


  float calcPressure = sim.createPressureCurve()*pressure.get();
  char pressureChar[] = getChar(calcPressure, 2);
  for (int i = 0; i<pressureChar.length; i++) {
    lcdMeas[i][1] =  pressureChar[i];
  }

  for (int i = 0; i<14; i++) {

    if (i+1<calcPressure/3.2142) {
      lcdMeas[i+2][1] =  '*';
    } else if ( calcPressure-(i)*3.2142 < 1.07) {
      lcdMeas[i+2][1] =  ' ';
    } else if ( calcPressure-(i)*3.2142 < 2.14) {
      lcdMeas[i+2][1] =  '+';
    } else {
      lcdMeas[i+2][1] =  '"';
    }
  }
}





void keyPressed() {
  if (key >= '1' && key<='4') {
    for (int i = 0; i<4; i++) {
      buttons[i].ignoreMouse = true;
    }
  }
  if (key == '1') {
    buttons[0].isClicked = true;
  } else if (key == '2') {
    buttons[1].isClicked = true;
  } else if (key == '3') {
    buttons[2].isClicked = true;
  } else if (key == '4') {
    buttons[3].isClicked = true;
  } else if ( key == 's' ) {
    save("screen.png");
  }
}

void keyReleased() {
  if (key == '1') {
    buttons[0].isClicked = false;
  } else if (key == '2') {
    buttons[1].isClicked = false;
  } else if (key == '3') {
    buttons[2].isClicked = false;
  } else if (key == '4') {
    buttons[3].isClicked = false;
  }
}

void drawOffLCDs() {
  fill(50); 
  rect(xLCDMeas, yLCDMeas, wLCD, hLCD); 
  rect(xLCDSet, yLCDSet, wLCD, hLCD);
}



void drawLCDs() {
  textFont(fLCD); 
  textAlign(LEFT, TOP); 
  fill(100, 225, 0); 

  rect(xLCDMeas, yLCDMeas, wLCD, hLCD); 
  fill(0); 

  for (int i = 0; i < lcdMeas.length; ++i) {
    for (int j = 0; j < lcdMeas[i].length; ++j) {
      text(lcdMeas[i][j], xLCDMeas+i*fontW+(wLCD-16*fontW)/2, yLCDMeas+j*fontH+(hLCD-2*fontH)/2-fontH/3+j*fontH/5);
    }
  }


  fill(100, 225, 0); 
  rect(xLCDSet, yLCDSet, wLCD, hLCD); 

  fill(0); 
  for (int i = 0; i < lcdSet.length; ++i) {
    for (int j = 0; j < lcdSet[i].length; ++j) {
      text(lcdSet[i][j], xLCDSet+i*fontW+(wLCD-16*fontW)/2, yLCDSet+j*fontH+(hLCD-2*fontH)/2-fontH/3+j*fontH/5);
    }
  }
}

void drawLineTopLCD(int x, int y, int d1, int d2) {
  line(x+d1*20+11, y, x+d2*20+11, y);
}

void drawHorizontalText(int x, int y, int d1, String text) {
  //  line(x+d1*20+11, y, x+d2*20+11, y);
}

char[] getChar(float value, int numChars) {
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

char[] getChar(int value, int numChars) {
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
