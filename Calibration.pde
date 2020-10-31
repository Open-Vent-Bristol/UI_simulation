int calState = 0;
long timestampqCal = 0;

/*

 In a nut shell the quick cal will prompt to disconnect the plumbing and turn off O2 inlet.  When acknowledged with the plus (?) button the machine will need to cycle the pump moving maximum air volume for at least 1 minute, maybe 2 or more.  Then the O2 and pressure measurements are taken and it is done.  Does the user need to acknowledge the end of the quick cal mode or does it return to standby automatically?
 The full cal will do similar steps for normal air (nothing on input), 100% N2 on input and 100% O2 on input.  Again, wait times of at minimum 1 minute.
 
 */

void quickCalibration() {
  switch(calState) {
  case 0:
    {
      updateMeasLCD_topRow("QuickCalibration");
      if (isStandby) {
        updateMeasLCD_botRow("Standby");
      } else {
        calState = 1;
        isEditMode = false;
      }
    }
    break;
  case 1:
    {
      updateMeasLCD_topRow("Disconnect tubes");
      updateMeasLCD_botRow("Confirm with Sel");
      if (buttons[0].justReleased) {
        calState = 2;
        timestampqCal = millis();
      }
    }
    break;

  case 2:
    {
      updateMeasLCD_topRow("Reduce O2 to 0");
      updateMeasLCD_botRow("Confirm with Sel");
      if (buttons[0].justReleased) {
        calState = 3;
        timestampqCal = millis();
      }
    }
    break;
  case 3:
    {
      updateMeasLCD_topRow("Please wait.");

      float time = 3000;

      float pct = (millis()-timestampqCal)/time;
      for (int i = 0; i<15; i++) {
        if (i+1<pct/0.066666) {
          lcdMeas[i][1] =  '*';
        } else if ( pct-(i)*0.066666 < 0.022222) {
          lcdMeas[i][1] =  ' ';
        } else if ( pct-(i)*0.066666 < 0.044444) {
          lcdMeas[i][1] =  '+';
        } else {
          lcdMeas[i][1] =  '"';
        }
      }

      if ( pct>1) {
        calState = 4;
        isStandby = true;
        isEditMode = true;
        isEditing = true;
      }
    }
    break;

  case 4:
    {
      updateMeasLCD_topRow("QuickCalibration");
      updateMeasLCD_botRow("Successful");

      if (!isStandby){
        calState = 1;
      }
    }
    break;
  }
}



void fullCalibration() {
  switch(calState) {
  case 0:
    {
      updateMeasLCD_topRow("FullCalibration");
      if (isStandby) {
        updateMeasLCD_botRow("Standby");
      } else {
        calState = 1;
        isEditMode = false;
      }
    }
    break;
  case 1:
    {
      updateMeasLCD_topRow("incr. O2 to 100%");
      updateMeasLCD_botRow("Confirm with Sel");
      if (buttons[0].justReleased) {
        calState = 2;
        timestampqCal = millis();
      }
    }
    break;

  case 2:
    {
      updateMeasLCD_topRow("Please wait.");

      float time = 3000;

      float pct = (millis()-timestampqCal)/time;
      for (int i = 0; i<15; i++) {
        if (i+1<pct/0.066666) {
          lcdMeas[i][1] =  '*';
        } else if ( pct-(i)*0.066666 < 0.022222) {
          lcdMeas[i][1] =  ' ';
        } else if ( pct-(i)*0.066666 < 0.044444) {
          lcdMeas[i][1] =  '+';
        } else {
          lcdMeas[i][1] =  '"';
        }
      }

      if ( pct>1) {
        calState = 3;
      }
    }
    break;
  case 3:
    {
      updateMeasLCD_topRow("remove O2 supply");
      updateMeasLCD_botRow("Confirm with Sel");
      if (buttons[0].justReleased) {
        calState = 4;
        timestampqCal = millis();
      }
    }
    break;

  case 4:
    {
      updateMeasLCD_topRow("Please wait.");

      float time = 3000;

      float pct = (millis()-timestampqCal)/time;
      for (int i = 0; i<15; i++) {
        if (i+1<pct/0.066666) {
          lcdMeas[i][1] =  '*';
        } else if ( pct-(i)*0.066666 < 0.022222) {
          lcdMeas[i][1] =  ' ';
        } else if ( pct-(i)*0.066666 < 0.044444) {
          lcdMeas[i][1] =  '+';
        } else {
          lcdMeas[i][1] =  '"';
        }
      }

      if ( pct>1) {
        calState = 5;
      }
    }
    break;
  case 5:
    {
      updateMeasLCD_topRow("connect N2 100%");
      updateMeasLCD_botRow("Confirm with Sel");
      if (buttons[0].justReleased) {
        calState = 6;
        timestampqCal = millis();
      }
    }
    break;

  case 6:
    {
      updateMeasLCD_topRow("Please wait.");

      float time = 3000;

      float pct = (millis()-timestampqCal)/time;
      for (int i = 0; i<15; i++) {
        if (i+1<pct/0.066666) {
          lcdMeas[i][1] =  '*';
        } else if ( pct-(i)*0.066666 < 0.022222) {
          lcdMeas[i][1] =  ' ';
        } else if ( pct-(i)*0.066666 < 0.044444) {
          lcdMeas[i][1] =  '+';
        } else {
          lcdMeas[i][1] =  '"';
        }
      }

      if ( pct>1) {
        calState = 7;
        isStandby = true;
        isEditMode = true;
        isEditing = true;
      }
    }
    break;

  case 7:
    {
      updateMeasLCD_topRow("FullCalibration");
      updateMeasLCD_botRow("Successful");

      if (!isStandby){
        calState = 1;
      }
    }
    break;
  }
}
