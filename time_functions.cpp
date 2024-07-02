#include "time_functions.h"

void handleCycleTimes(std::string times)
{
  int wake_hours = (getValue(String(times.c_str()), '+', 2)).toInt();
  int wake_minutes = (getValue(String(times.c_str()), '+', 3)).toInt();
  wake_time = wake_hours * 3600 + wake_minutes * 60;
  int sleep_hours = (getValue(String(times.c_str()), '+', 0)).toInt();
  int sleep_minutes = (getValue(String(times.c_str()), '+', 1)).toInt();
  sleep_time = sleep_hours * 3600 + sleep_minutes * 60;
  fade_in_time = 60 * (getValue(String(times.c_str()), '+', 5)).toInt();
  fade_out_time = 60 * (getValue(String(times.c_str()), '+', 4)).toInt();
  delay_time = (getValue(String(times.c_str()), '+', 6)).toInt();
  transition_time = 60 * (getValue(String(times.c_str()), '+', 7)).toInt();
  prefs.putInt("wake_time", wake_time);
  prefs.putInt("sleep_time", sleep_time);
  prefs.putInt("fade_in_time", fade_in_time);
  prefs.putInt("fade_out_time", fade_out_time);
  prefs.putInt("delay_time", delay_time);
  prefs.putInt("transition_time", transition_time);
}

void actAccordingTime(bool motion)
{
  struct tm timeinfo;
  int time = 0;
  if(configured)
  {
    getLocalTime(&timeinfo);
    time = timeinfo.tm_hour * 3600 + timeinfo.tm_min*60 + timeinfo.tm_sec;
  }
  else if(manually_configured)
    time = hour()*3600 + minute()*60 + second();
  else
  {
    if(phase == -1){
      pixels.fill(3350784);
      pixels.show();
      phase = 1;
    }
    else
    {
      pixels.clear();
      pixels.show();
      phase = -1;
    }
    return;
  }
  if(!motion)
    last_motion = 4294967;
  if(wake_time <= sleep_time)
  {
    if(time == wake_time)
      light(0, 2);
    else if(time == sleep_time)
      light(1, 0, motion);
    else if(time > wake_time && time < wake_time + fade_out_time)
      light((time-wake_time)/(float)fade_out_time, 2);
    else if(time >= wake_time + fade_out_time && time < sleep_time)
    {
      if(time < sleep_time - fade_in_time)
        light(1, 2);
      else
        light((time - (sleep_time - fade_in_time))/(float)fade_in_time, 0);
    }
    else if(time >= sleep_time)
    {
      if(wake_time >= transition_time)
      {
        light(0, 1, motion);
      }
      else
      {
        if(time < wake_time - transition_time + 24 * 3600)
          light(0, 1, motion);
        else
        {
          light((time-(wake_time - transition_time + 24 * 3600))/(float)transition_time, 1);
        }
      }
    }
    else
    {
      if(wake_time >= transition_time)
      {
        if(time < wake_time - transition_time)
          light(0, 1, motion);
        else
          light((time-(wake_time - transition_time))/(float)transition_time, 1);
      }
      else
        light((time-(wake_time - transition_time))/(float)transition_time, 1);
    }
  }
  else
  {
    if(time == wake_time)
      light(0, 2);
    else if(time == sleep_time)
      light(1, 0, motion);
    else if(time > sleep_time && time < wake_time - transition_time)
      light(1, 0, motion);
    else if(time >= sleep_time && time < wake_time)
      light((time-(wake_time - transition_time))/(float)transition_time, 1);
    else if(time >= wake_time)
    {
      if(wake_time + fade_out_time >= 24 * 3600)
        light((time-wake_time)/(float)fade_out_time, 2);
      else if(sleep_time > fade_in_time)
      {
        if(time > wake_time + fade_out_time)
          light(1, 2);
        else
          light((time-wake_time)/(float)fade_out_time, 2);
      }
      else
      {
        if(time <= wake_time + fade_out_time)
          light((time-wake_time)/(float)fade_out_time, 2);
        else if(time <= sleep_time - fade_in_time + 24 * 3600)
          light(1, 2);
        else
          light((time-(sleep_time - fade_in_time + 24 * 3600))/(float)fade_in_time, 0);
      }
    }
    else
    {
      if(wake_time + fade_out_time >= 24 * 3600)
      {
        if(time <= wake_time + fade_out_time - 24 * 3600)
          light((time-(wake_time - 24 * 3600))/(float)fade_out_time, 2);
        else if(time <= sleep_time - fade_in_time)
          light(0, 0);
        else
          light((time-(sleep_time - fade_in_time))/(float)fade_in_time, 0);
      }
      else if(sleep_time > fade_in_time)
      {
        if(time <= sleep_time - fade_in_time)
          light(0, 0);
        else
          light((time-(sleep_time - fade_in_time))/(float)fade_in_time, 0);
      }
      else
        light((time-(sleep_time - fade_in_time + 24 * 3600))/(float)fade_in_time, 0);
    }
  }
}

void handleTimeConfig(std::string curr_time)
{
  int hour = (getValue(String(curr_time.c_str()), '+', 0)).toInt();
  int minute =(getValue(String(curr_time.c_str()), '+', 1)).toInt();
  int second =(getValue(String(curr_time.c_str()), '+', 2)).toInt();
  int day =(getValue(String(curr_time.c_str()), '+', 3)).toInt();
  int month =(getValue(String(curr_time.c_str()), '+', 4)).toInt();
  int year =(getValue(String(curr_time.c_str()), '+', 5)).toInt();
  setTime(hour, minute, second, day, month, year);
  manually_configured = true;
  int value = 1;
  if(connected)
    value = 5;
  pCharacteristic_8->setValue(value);
  pCharacteristic_8->notify();
}

void loadTimeSettings()
{
  wake_time = prefs.getInt("wake_time", 0);
  sleep_time = prefs.getInt("sleep_time", 0);
  fade_in_time = prefs.getInt("fade_in_time", 0);
  fade_out_time = prefs.getInt("fade_out_time", 0);
  delay_time = prefs.getInt("delay_time", 0);
  transition_time = prefs.getInt("transition_time", 0);
}