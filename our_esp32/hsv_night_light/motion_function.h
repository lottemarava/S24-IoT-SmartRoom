#include "WString.h"
#ifndef MOTION_FUNCTION_H
#define MOTION_FUNCTION_H

#include <Arduino.h>
#include <ld2410.h>
#include "time_functions.h"
#include "wifi_functions.h"
#include "firestore_functions.h"
#define LD24_INPUT 35
#if defined(ESP32)
  #ifdef ESP_IDF_VERSION_MAJOR // IDF 4+
    #if CONFIG_IDF_TARGET_ESP32 // ESP32/PICO-D4
      #define MONITOR_SERIAL Serial
      #define RADAR_SERIAL Serial1
      #define RADAR_RX_PIN 32
      #define RADAR_TX_PIN 33
    #elif CONFIG_IDF_TARGET_ESP32S2
      #define MONITOR_SERIAL Serial
      #define RADAR_SERIAL Serial1
      #define RADAR_RX_PIN 9
      #define RADAR_TX_PIN 8
    #elif CONFIG_IDF_TARGET_ESP32C3
      #define MONITOR_SERIAL Serial
      #define RADAR_SERIAL Serial1
      #define RADAR_RX_PIN 4
      #define RADAR_TX_PIN 5
    #else 
      #error Target CONFIG_IDF_TARGET is not supported
    #endif
  #else // ESP32 Before IDF 4.0
    #define MONITOR_SERIAL Serial
    #define RADAR_SERIAL Serial1
    #define RADAR_RX_PIN 32
    #define RADAR_TX_PIN 33
  #endif
#elif defined(__AVR_ATmega32U4__)
  #define MONITOR_SERIAL Serial
  #define RADAR_SERIAL Serial1
  #define RADAR_RX_PIN 0
  #define RADAR_TX_PIN 1
#endif



extern ld2410 radar;

extern bool motion_detected;
extern int offset;
extern int  radarState;
extern int val;
extern uint32_t lastReading;
extern int lastSeen[10]; 
extern int i ;
extern const int size ;
extern int sum ;
extern int j;
extern char currentTime[20]; // Adjust the size according to your needs
//extern DocumentReference docRef;
extern unsigned long previousMillis; // Variable to store the last time a message was sent
extern const long interval;     // Interval in milliseconds (10 minutes)


extern unsigned long dataMillis ;
extern int count ;


void connect_to_radar();
bool detectMotion();
void act_acording_to_time(bool val); 

#endif