import processing.sound.*; //<>// //<>//

String releaseTag = "V7 29.Oct 2020";

PFont fLCD;
PImage overlay;

SoundFile triggerSound;
SoundFile holdSound;

SimulateMachine sim = new SimulateMachine();

IntMenuItem pressure = new IntMenuItem(0, 1, 2, 35, 0, 45, 1); 
IntMenuItem bpm = new IntMenuItem(0, 4, 2, 20, 10, 30, 2); 
IERatioMenuItem ieRatio = new IERatioMenuItem(0, 7, 0.1); 
IntMenuItem upperTidalVolume = new IntMenuItem(0, 13, 3, 500, 0, 700, 10); 
IntMenuItem lowerTidalVolume = new IntMenuItem(1, 13, 3, 400, 0, 700, 10); 
IntMenuItem apnea = new IntMenuItem(1, 10, 2, 20, 20, 60, 1); 
IntMenuItem fio2 = new IntMenuItem(1, 6, 3, 20, 0, 100, 5); 

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

boolean isEditing;

int[] nrOfMenuItems = {8, 5, 4};
int[][] menuLCDPositions = {{}, {0, 3, 6, 12, 28, 25, 21, 16}, {16, 20, 24, 5, 11}, {16, 21, 26, 11}};
int menuCurrentPosition = 0;

Button[] buttons;

String[] buttonsText = {"Edit", "-", "+", "Mute\nStandby"}; 

boolean isEditMode = false;
boolean isStandby = true;


void setup() {
  size(1455, 1098);
  background(0);
  overlay = loadImage("frontpanel.png");

  menuPCV.add(pressure);
  menuPCV.add(bpm);
  menuPCV.add(ieRatio);
  menuPCV.add(upperTidalVolume);
  menuPCV.add(lowerTidalVolume);
  menuPCV.add(fio2);
  menuPCV.add(modeHandler);

  menuPSV.add(pressure);
  menuPSV.add(upperTidalVolume);
  menuPSV.add(lowerTidalVolume);
  menuPSV.add(apnea);
  menuPSV.add(fio2);
  menuPSV.add(modeHandler);

  menuCal.add(modeHandler);

  lcdSet = new char[16][2];
  lcdMeas = new char[16][2];

  clearLCDs();



  buttons = new Button[buttonsText.length];
  for (int i = 0; i < buttonsText.length; i++) {
    buttons[i] = new Button(422+i*85, 480, 66, 66, buttonsText[i]);
  }

  // Create the font
  fLCD = createFont("5x8-LCD.ttf", 28); //createFont("SourceCodePro-Regular.ttf", 24);


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

  sim.updateValues(pressure.get(), bpm.get(), ieRatio.get());

  // Sound control
  for (int i = 0; i<buttons.length; i++) {
    buttons[i].update();
    if (buttons[i].justReleased && !buttons[i].isHeld3s) {
      triggerSound.play();
    }
    if (buttons[i].justHeld3s) {
      holdSound.play();
    }
  }

  /*
  if (isOneHeld && !holdSound.isPlaying()) {
   //holdSound.play();
   } else if (!isOneHeld && holdSound.isPlaying()) {
   //holdSound.stop();
   }*/

  /*
  if (isOneHeld && lastSec != second()) {
   lastSec = second();
   triggerSound.play();
   }*/




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



  switch (modeHandler.get()) {
  case 0:
    if (isStandby) {
      updateMeasLCD_topRow("MODE: PCV");
      updateMeasLCD_botRow("Standby");
    } else {
      updateMeasLCD_breath();
    }
    runMachine(menuPCV);
    break;
  case 1:
    if (isStandby) {
      updateMeasLCD_topRow("MODE: PSV");
      updateMeasLCD_botRow("Standby");
    } else {
      updateMeasLCD_breath();
    }
    runMachine(menuPSV);
    break;
  case 2:
    quickCalibration();
    runMachine(menuCal);
    break;
  case 3:
    fullCalibration();
    runMachine(menuCal);
    break;
  case 4: // OFF / STORAGE    
    if (buttons[0].justHeld3s) {
      startupMachineDefinition();
    }
    break;
  }


  // ugly way to deal with calibrationstate reset on mode change
  if (modeHandler.get() != oldModeState) {
    calState = 0;
  }
  oldModeState = modeHandler.get();

  background(150);
  image(overlay, 0, 0, overlay.width, overlay.height);

  if (modeHandler.get() == 4) { // not OFF
    drawOffLCDs();
  } else {
    drawLCDs();
  }

  for (int i = 0; i<buttons.length; i++) {
    buttons[i].draw();
  }

  fill(0);
  text(releaseTag, 120, 40);
}


void runMachine(ArrayList<MenuItem> menu) {

  // drawing menues;
  char menuChar = ' ';

  // Holding edit button for 3 sec toggles Edit Mode
  if (buttons[0].justHeld3s) {
    isEditMode = !isEditMode;
  } 

  // Holding Mute/standby button for 3 sec toggles Edit Mode
  if (buttons[3].justHeld3s) {
    isStandby = !isStandby;
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
        lastModeSelectedTimeStamp = millis();
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
    lcdMeas[i+5][0] =  flowChar[i];
  }

  int calcFio2 = int(fio2.get()+noise(minute())*0.05);
  char fio2Char[] = getChar( calcFio2, 3);
  for (int i = 0; i<fio2Char.length; i++) {
    lcdMeas[i+11][0] =  fio2Char[i];
  }

  lcdMeas[15][0] =  '§';


  float calcPressure = sim.createPressureCurve()*pressure.get();
  char pressureChar[] = getChar(calcPressure, 2);
  for (int i = 0; i<pressureChar.length; i++) {
    lcdMeas[i][1] =  pressureChar[i];
  }

  for (int i = 0; i<13; i++) {

    if (i+1<calcPressure/3.4615) {
      lcdMeas[i+3][1] =  '*';
    } else if ( calcPressure-(i)*3.4615 < 1.15) {
      lcdMeas[i+3][1] =  ' ';
    } else if ( calcPressure-(i)*3.4615 < 2.3) {
      lcdMeas[i+3][1] =  '+';
    } else {
      lcdMeas[i+3][1] =  '"';
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
  int x = 133;
  int y = 290;
  rect(x, y, 16*20+45, 2*26+20);
  x += 537;
  rect(x, y, 16*20+45, 2*26+20);
}



void drawLCDs() {
  textFont(fLCD); 
  textAlign(LEFT, TOP); 
  fill(255, 150, 0); 
  int x = 133;
  int y = 290;
  rect(x, y, 16*20+45, 2*26+20); 
  fill(0); 

  for (int i = 0; i < lcdMeas.length; ++i) {
    for (int j = 0; j < lcdMeas[i].length; ++j) {
      text(lcdMeas[i][j], x+i*22+8, y+j*30);
    }
  }


  fill(255, 150, 0); 
  x += 537;
  rect(x, y, 16*20+45, 2*26+20); 

  fill(0); 
  for (int i = 0; i < lcdSet.length; ++i) {
    for (int j = 0; j < lcdSet[i].length; ++j) {
      text(lcdSet[i][j], x+i*22+8, y+j*30);
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
