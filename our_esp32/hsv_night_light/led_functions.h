#ifndef LED_FUNCTIONS_H
#define LED_FUNCTIONS_H

#include <Arduino.h>
#include <Adafruit_NeoPixel.h>
#include <Preferences.h>
#include "info_extractor.h"
#include <string>

#define PIN        26
#define NUMPIXELS 56
extern Adafruit_NeoPixel pixels;
extern Preferences prefs;
extern uint32_t my_now;
extern uint32_t first_motion;
extern int delay_time;
extern uint32_t last_motion; 
extern int low_hue;
extern int low_saturation;
extern int low_value;
extern int high_hue;
extern int high_saturation;
extern int high_value;
extern int motion_value;
extern std::string page;

//lighting the neopixel according to the current mode
void light(float fraction, byte mode, bool motion=false);
//handle color message sent from the application (via BLE)
void handleColors(std::string colors, bool high);
//load color setting from preferences
void loadPixelSettings();

#endif