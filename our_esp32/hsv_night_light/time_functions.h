#ifndef TIME_FUNCTIONS_H
#define TIME_FUNCTIONS_H

#include <Arduino.h>
#include <TimeLib.h>
#include "ble_functions.h"
#include "info_extractor.h"
#include "led_functions.h"

extern int wake_time;
extern int sleep_time;
extern int fade_in_time;
extern int fade_out_time;
extern int transition_time;
extern int phase;
extern bool connected;
extern bool configured;
extern bool manually_configured;
extern BLECharacteristic* pCharacteristic_8;

//handle time message sent from the application (via BLE)
void handleCycleTimes(std::string times);
//call the light function with the mode according to current time
void actAccordingTime(bool motion = false);
//configure current time according to time sent by application (via BLE)
void handleTimeConfig(std::string curr_time);
//load times settings from preferences
void loadTimeSettings();

#endif