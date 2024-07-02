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
int radarState = LOW;
int val = 0;
bool motion_detected = false;





#define MONITOR_SERIAL Serial
#define RADAR_SERIAL Serial1
#define RADAR_RX_PIN 32
#define RADAR_TX_PIN 33


ld2410 radar;
bool engineeringMode = false;
String command;


int lastSeen[20] = {60, 60, 70, 80, 70, 80, 80, 70, 70, 70, 60, 70, 70, 70, 80, 60, 60, 60, 60, 60}; 
int i = 0;
const int size = 20;
int sum = 0;
int j=0;






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
  MONITOR_SERIAL.begin(115200); //Feedback over Serial Monitor
  delay(500); //Give a while for Serial Monitor to wake up
  Serial.print("reached line 88");
  //radar.debug(Serial); //Uncomment to show debug information from the library on the Serial Monitor. By default this does not show sensor reads as they are very frequent.
  RADAR_SERIAL.begin(256000, SERIAL_8N1, RADAR_RX_PIN, RADAR_TX_PIN); //UART for monitoring the radar
  Serial.print("reached line 91");
  connectWithPref();
  loadPixelSettings();
  loadTimeSettings();
  BLEStart();
  Serial.print("reached line 96");

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
