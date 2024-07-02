#include "motion_function.h"
//------------------------------------------------------------------------------------------------------
//Global Variables
//------------------------------------------------------------------------------------------------------
//Preference
Preferences prefs;
//neopixel related variables
Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);
int low_hue = 0;
int low_saturation = 0;
int low_value = 0;
int high_hue = 0;
int high_saturation = 0;
int high_value = 0;
int motion_value = 0;
//time related variables
uint32_t first_motion = 0;
uint32_t last_motion = 4294967;
int delay_time = 0;
uint32_t my_now = 0;
int offset = 0;
int wake_time = 0;
int sleep_time = 0;
int fade_in_time = 0;
int fade_out_time = 0;
int transition_time = 0;
int phase = -1;
//motion variables
int pirState = LOW;
int val = 0;
bool motion_detected = false;
//tracking variables
bool configured = false;
bool manually_configured = false;
bool was_configured = false;
bool connecting = false;
bool color_page = false;
bool BT_connecting = false;
bool connected = false;
bool was_connected = false;
bool BT_connected = false;
std::string page = "0";
//BLE related variables
BLECharacteristic* pCharacteristic_5 = NULL;
BLECharacteristic* pCharacteristic_8 = NULL;
//------------------------------------------------------------------------------------------------------
//setup
//------------------------------------------------------------------------------------------------------
void setup(){
  Serial.begin(115200); 
  pinMode(PIRInput, INPUT);
  connectWithPref();
  loadPixelSettings();
  loadTimeSettings();
  BLEStart();
}
//------------------------------------------------------------------------------------------------------
//loop
//------------------------------------------------------------------------------------------------------
void loop(){
  notifyChange();
  BLEConnectIndication();
  delay(200);
  if(!color_page)
    detectMotion();
}
