#ifndef WIFI_FUNCTIONS_H
#define WIFI_FUNCTIONS_H

#include <Arduino.h>
#include <Preferences.h>
#include <WiFi.h>
#include "info_extractor.h"
#include "ble_functions.h"

extern Preferences prefs;
extern bool connected;
extern bool connecting;
extern bool was_connected;
extern bool configured;
extern bool manually_configured;
extern bool was_configured;
extern BLECharacteristic* pCharacteristic_5;
//using saved credentials to connect to WiFi and NTP
void connectWithPref();
//connecting with credentials sent by the application (via BLE)
void handleCredentials(std::string credentials);

#endif