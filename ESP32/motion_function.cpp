#include "motion_function.h"

void detectMotion()
{
  val = digitalRead(PIRInput);
  if (val == HIGH) 
  {
    if(pirState == LOW){
      pirState = HIGH;
    }
    if(!motion_detected)
      first_motion = millis()/1000 - offset;
    motion_detected = true;
    my_now = millis()/1000;
    if(my_now < first_motion)
      my_now = my_now + 4294967;
    last_motion = millis()/1000;
    if(configured || manually_configured)
      actAccordingTime(true);
    else if(!connecting)
    {
      actAccordingTime();
      connectWithPref();
    }
  }
  else 
  {
    if(configured || manually_configured)
    {
      if (pirState == HIGH) {
        pirState = LOW;
      }
      my_now = millis()/1000;
      if(my_now < last_motion)
        my_now = my_now + 4294967;
      if(my_now - last_motion >= delay_time){
        motion_detected = false;
        offset = 5 - (my_now - last_motion - delay_time);
      }
      if((my_now - last_motion >= delay_time + 5 && my_now - first_motion >= delay_time + 10) || last_motion == 4294967){
        actAccordingTime();
        offset = 0;
      }
      else
        actAccordingTime(true);
    }
    else if(!connecting)
    {
      actAccordingTime();
      connectWithPref();
    }
  }
}