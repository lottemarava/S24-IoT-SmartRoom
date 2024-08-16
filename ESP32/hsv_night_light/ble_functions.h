#ifndef BLE_FUNCTIONS_H
#define BLE_FUNCTIONS_H

#include <Arduino.h>
#include <Adafruit_NeoPixel.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

extern Adafruit_NeoPixel pixels;
extern int low_hue;
extern int low_saturation;
extern int low_value;
extern int high_hue;
extern int high_saturation;
extern int high_value;
extern std::string page;
extern bool color_page;
extern BLECharacteristic* pCharacteristic_5;
extern BLECharacteristic* pCharacteristic_8;
extern bool BT_connected;
extern bool BT_connecting;
extern bool connected;
extern bool connecting;
extern bool was_connected;
extern bool configured;
extern bool manually_configured;
extern bool was_configured;
extern void handleCredentials(std::string credentials);
extern void handleCycleTimes(std::string times);
extern void handleTimeConfig(std::string curr_time);
extern void handleColors(std::string colors, bool high);

//initializing BLE and its onWrite/Connect/Disconnet handlers
void BLEStart();
//notify application on changes of connection/time configuration if needed
void notifyChange();
//indication when BLE connection occurs (blinking thrice)
void BLEConnectIndication();

#endif