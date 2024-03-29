class SimulateMachine {

  int targetPressure;
  float breathPeriod;
  float inhalePeriod;
  float exhalePeriod;
  float timeOffset = 0;
      float outNorm = 0;
      float out = 0;


  void updateValues(int targetPress, int bpm, float iT) {
    targetPressure = targetPress;
    breathPeriod = (60 / bpm) * 1000;
    inhalePeriod = iT*1000;
    exhalePeriod = breathPeriod-inhalePeriod;
    //timeOffset = millis();
  }

  float createVolCurve() {
    float outNorm = 0;
    float currentTimePos = (millis()-timeOffset)%breathPeriod;
    if (currentTimePos < inhalePeriod) {
      outNorm = easeOutSine(currentTimePos/inhalePeriod);
    } else if (currentTimePos < breathPeriod) {
      outNorm = 1+noise(second())*0.01;
    }
    return outNorm;
    
    
   // return 1+noise(second())*0.01;
  }



  float createFlowCurve() {
    
    float outNorm = 0;
    float currentTimePos = (millis()-timeOffset)%breathPeriod;
    if (currentTimePos < inhalePeriod*0.8) {
      outNorm = easeOutSine(currentTimePos/(inhalePeriod*0.8));
    } else if (currentTimePos < breathPeriod) {
      outNorm = 1+noise(second())*0.01;
    }
    return outNorm;
    
    /*
    float outNorm = 0;
    float currentTimePos = (millis()-timeOffset)%breathPeriod;
    if (currentTimePos < inhalePeriod/10) {
      outNorm = currentTimePos/(inhalePeriod/10);
    } else if (currentTimePos < inhalePeriod) {
      outNorm = (currentTimePos-(inhalePeriod/10))/(inhalePeriod-inhalePeriod/10);
    } else if (currentTimePos < breathPeriod) {
      outNorm = 0;
    }

    return outNorm; //int(outNorm*float(targetPressure));
    */
    
    //return 1+noise(second())*0.1;  

  }
  
    float createBPM() {
    /*
    float outNorm = 0;
    float currentTimePos = (millis()-timeOffset)%breathPeriod;
    if (currentTimePos < inhalePeriod/10) {
      outNorm = currentTimePos/(inhalePeriod/10);
    } else if (currentTimePos < inhalePeriod) {
      outNorm = (currentTimePos-(inhalePeriod/10))/(inhalePeriod-inhalePeriod/10);
    } else if (currentTimePos < breathPeriod) {
      outNorm = 0;
    }

    return outNorm; //int(outNorm*float(targetPressure));
    */
        return 1+noise(second())*0.1;

  }

  float createPressureCurve() {
    float currentTimePos = (millis()-timeOffset)%breathPeriod;
    if (currentTimePos < inhalePeriod/3) {
      outNorm = inhaleShape(currentTimePos*3/inhalePeriod);
    } else if (currentTimePos < inhalePeriod) {
      outNorm = 1+noise((millis()/100.0))*0.02;
    } else if (currentTimePos < breathPeriod) {
      outNorm = exhaleShape(1-((currentTimePos-inhalePeriod)/exhalePeriod));
    }

    return out = out*0.9+outNorm*0.1; //int(outNorm*float(targetPressure));
  }

  float inhaleShape(float x) {
    //quint ease out
    return 1 - pow(1 - x, 5);
  }

  float exhaleShape(float x) {
    //https://easings.net/#easeOutQuad
    return 1 - (1 - x) * (1 - x);
  }

  float easeOutSine(float x) {
    return sin((x * PI) / 2);
  }
}
