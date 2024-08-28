#include "motion_function.h"
#include "firestore_functions.h"
#include "SD_functions.h"

// Preference
Preferences prefs;

// Neopixel related variables
Adafruit_NeoPixel pixels(NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);
int low_hue = 0;
int low_saturation = 0;
int low_value = 0;
int high_hue = 0;
int high_saturation = 0;
int high_value = 0;

// Time related variables
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
char currentTime[20];

// Motion variables
int radarState = LOW;
int val = 0;
bool motion_detected = false;


bool engineeringMode = false;
String command;
int lastSeen[10] = {60, 60, 70, 80, 70, 80, 80, 70, 70, 70}; 
int i = 0;
const int size = 10;
int sum = 0;
int j = 0;
int motion_value = 0;


/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Tracking variables
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

// BLE related variables
BLECharacteristic* pCharacteristic_5 = NULL;
BLECharacteristic* pCharacteristic_8 = NULL;

uint32_t lastReading = 0;
bool radarConnected = false;
ld2410 radar;
unsigned long previousMillis = 0; // Variable to store the last time a message was sent
const long interval =    10000; /*600000;*/     // Interval in milliseconds (10 minutes)
//DocumentReference docRef;
//unsigned long sendDataPrevMillis = 0;
int curr_time = -1;
volatile bool dataChanged = false;

//------------------------------------------------------------------------------------------------------
// Setup function
//------------------------------------------------------------------------------------------------------





void setup() {
  MONITOR_SERIAL.begin(115200); //Feedback over Serial Monitor
  //radar.debug(MONITOR_SERIAL); //Uncomment to show debug information from the library on the Serial Monitor. By default this does not show sensor reads as they are very frequent.
  connect_to_radar();
  // Connect with preferences
  connectWithPref();
  // Load settings
  loadPixelSettings();
  loadTimeSettings();
  // Start BLE
  BLEStart();

  initDB();

  SD_setup();
  delay(1000);

}
//------------------------------------------------------------------------------------------------------
// Loop function
//------------------------------------------------------------------------------------------------------

void loop() {
  notifyChange();
  BLEConnectIndication(); 
  delay(100);
 if(!color_page){
    bool detected=detectMotion();
    act_acording_to_time(detected);
  }
  
}

