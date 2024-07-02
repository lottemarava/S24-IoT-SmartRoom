#include "led_functions.h"

void light(float fraction, byte mode, bool motion)
{
  int hue = 0;
  int sat = 0;
  int val = 0;
  int top_hue = 0;
  int top_sat = 0;
  int top_val = 23;
  int bot_hue = 0;
  int bot_sat = 0;
  int bot_val = 23;
  if(mode == 0)
  {
    bot_hue = low_hue;
    top_hue = low_hue;
    bot_sat = low_saturation;
    top_sat = low_saturation;
    top_val = low_value;
    if(fraction != 1)
      first_motion = my_now;
  }
  else if(mode == 1)
  {
    bot_hue = low_hue;
    bot_sat = low_saturation;
    bot_val = low_value;
    top_hue = high_hue;
    top_sat = high_saturation;
    top_val = high_value;
  }
  else
  {
    bot_hue = high_hue;
    top_hue = high_hue;
    bot_sat = high_saturation;
    top_sat = high_saturation;
    bot_val = high_value;
  }
  if(motion)
  {
    hue = low_hue;
    sat = low_saturation;
    val = motion_value;
    if(my_now < first_motion + 5){
      val = ((my_now -first_motion)/(float)5) * motion_value + (1-((my_now -first_motion)/(float)5)) * low_value;
      last_motion = my_now;
    }
    else if(my_now > last_motion + delay_time && my_now <= last_motion + delay_time + 5)
      val = ((my_now -(last_motion + delay_time))/(float)5) * low_value + (1-((my_now -(last_motion + delay_time))/(float)5)) * motion_value;
  }
  else
  {
    if((top_hue > bot_hue && top_hue - bot_hue < 32768) || (top_hue <= bot_hue && bot_hue - top_hue < 32768))
      hue = fraction * top_hue + (1-fraction) * bot_hue;
    else if(bot_hue < 32768)
      hue = (int)(fraction * top_hue + (1-fraction) * (65536 + bot_hue)) % 65536;
    else
      hue = (int)(fraction * (65536 + top_hue) + (1-fraction) * bot_hue) % 65536;
    sat = fraction * top_sat + (1-fraction) * bot_sat;
    val = fraction * top_val + (1-fraction) * bot_val;
  }
  uint32_t rgbcolor = pixels.gamma32(pixels.ColorHSV(hue, sat, val));
  pixels.fill(rgbcolor);
  pixels.show();
}

void handleColors(std::string colors, bool high)
{
  int hue = 65535 * ((getValue(String(colors.c_str()), '+', 0)).toFloat())/360;
  int sat = 255 * (getValue(String(colors.c_str()), '+', 1)).toFloat();
  int val = 255 * (getValue(String(colors.c_str()), '+', 2)).toFloat();
  int save = (getValue(String(colors.c_str()), '+', 3)).toInt();
  uint32_t rgbcolor = pixels.gamma32(pixels.ColorHSV(hue, sat, val));
  pixels.fill(rgbcolor);
  if((high && page == "1") || (!high && page == "2"))
    pixels.show();
  if(save == 0)
    return;
  if(high)
  {
    high_hue = hue;
    high_saturation = sat;
    high_value = val;
    prefs.putInt("high_hue", high_hue);
    prefs.putInt("high_saturation", high_saturation);
    prefs.putInt("high_value", high_value);
  }
  else
  {
    low_hue = hue;
    low_saturation = sat;
    low_value = val;
    motion_value = 255*(getValue(String(colors.c_str()), '+', 4)).toFloat();
    prefs.putInt("low_hue", low_hue);
    prefs.putInt("low_saturation", low_saturation);
    prefs.putInt("low_value", low_value);
    prefs.putInt("motion_value", motion_value);
  }
}

void loadPixelSettings()
{
  high_hue = prefs.getInt("high_hue", 0);
  high_saturation = prefs.getInt("high_saturation", 0);
  high_value = prefs.getInt("high_value", 0);
  low_hue = prefs.getInt("low_hue", 0);
  low_saturation = prefs.getInt("low_saturation", 0);
  low_value = prefs.getInt("low_value", 0);
  motion_value = prefs.getInt("motion_value", 0);
}