#include <WiFi.h>
#include "time.h"
#include "esp_sntp.h"
#include <Arduino.h>
#if defined(ESP32) || defined(ARDUINO_RASPBERRY_PI_PICO_W)
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#elif __has_include(<WiFiNINA.h>)
#include <WiFiNINA.h>
#elif __has_include(<WiFi101.h>)
#include <WiFi101.h>
#elif __has_include(<WiFiS3.h>)
#include <WiFiS3.h>
#endif
#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <TimeLib.h>

#include "SD_functions.h"

/* 2. Define the API Key */
#define API_KEY ""
/* 3. Define the project ID */
#define FIREBASE_PROJECT_ID ""
/* 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL ""
#define USER_PASSWORD ""

// Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

unsigned long dataMillis = 0;
int count = 0;

#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
WiFiMulti multi;
#endif


/* 1. Define the WiFi credentials */
const char *ssid = "";
const char *password = "";


const char *ntpServer1 = "pool.ntp.org";
const char *ntpServer2 = "time.nist.gov";
const long gmtOffset_sec = 10800;
const int daylightOffset_sec = 0;

// The Firestore payload upload callback function
void fcsUploadCallback(CFS_UploadStatusInfo info)
{
    if (info.status == firebase_cfs_upload_status_init)
    {
        Serial.printf("\nUploading data (%d)...\n", info.size);
    }
    else if (info.status == firebase_cfs_upload_status_upload)
    {
        Serial.printf("Uploaded %d%s\n", (int)info.progress, "%");
    }
    else if (info.status == firebase_cfs_upload_status_complete)
    {
        Serial.println("Upload completed ");
    }
    else if (info.status == firebase_cfs_upload_status_process_response)
    {
        Serial.print("Processing the response... ");
    }
    else if (info.status == firebase_cfs_upload_status_error)
    {
        Serial.printf("Upload failed, %s\n", info.errorMsg.c_str());
    }
}

void printLocalTime() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("No time available (yet)");
    return;
  }
  Serial.println(&timeinfo, "%A, %B %d %Y %H:%M:%S");
}

// Callback function (gets called when time adjusts via NTP)
void timeavailable(struct timeval *t) {
  Serial.println("Got time adjustment from NTP!");
  printLocalTime();
}


void initDB() {
     Serial.begin(115200);

#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
    multi.addAP(ssid, password);
    multi.run();
#else
    WiFi.begin(ssid, password);
#endif

    Serial.print("Connecting to Wi-Fi");
    unsigned long ms = millis();
    while (WiFi.status() != WL_CONNECTED)
    {
        Serial.print(".initdb.");
        delay(300);
#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
        if (millis() - ms > 10000)
            break;
#endif
    }
    // First step is to configure WiFi STA and connect in order to get the current time and date.


  // set notification call-back function
  sntp_set_time_sync_notification_cb(timeavailable);

  /**
   * NTP server address could be acquired via DHCP,
   *
   * NOTE: This call should be made BEFORE esp32 acquires IP address via DHCP,
   * otherwise SNTP option 42 would be rejected by default.
   * NOTE: configTime() function call if made AFTER DHCP-client run
   * will OVERRIDE acquired NTP server address
   */
  esp_sntp_servermode_dhcp(1);  // (optional)

  /**
   * This will set configured ntp servers and constant TimeZone/daylightOffset
   * should be OK if your time zone does not need to adjust daylightOffset twice a year,
   * in such a case time adjustment won't be handled automagically.
   */
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer1, ntpServer2);

  /**
   * A more convenient approach to handle TimeZones with daylightOffset
   * would be to specify a environment variable with TimeZone definition including daylight adjustmnet rules.
   * A list of rules for your zone could be obtained from https://github.com/esp8266/Arduino/blob/master/cores/esp8266/TZ.h
   */
  //configTzTime(time_zone, ntpServer1, ntpServer2);

    Serial.println();
    Serial.print("Connected with IP: ");
    Serial.println(WiFi.localIP());
    Serial.println();

    Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

    /* Assign the api key (required) */
    config.api_key = API_KEY;

    /* Assign the user sign in credentials */
    auth.user.email = USER_EMAIL;
    auth.user.password = USER_PASSWORD;

    // The WiFi credentials are required for Pico W
    // due to it does not have reconnect feature.
#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
    config.wifi.clearAP();
    config.wifi.addAP(ssid, password);
#endif

    /* Assign the callback function for the long running token generation task */
    config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

    // Comment or pass false value when WiFi reconnection will control by your code or third party library e.g. WiFiManager
    Firebase.reconnectNetwork(true);

    // Since v4.4.x, BearSSL engine was used, the SSL buffer need to be set.
    // Large data transmission may require larger RX buffer, otherwise connection issue or data read time out can be occurred.
    fbdo.setBSSLBufferSize(4096 /* Rx buffer size in bytes from 512 - 16384 */, 1024 /* Tx buffer size in bytes from 512 - 16384 */);

    // Limit the size of response payload to be collected in FirebaseData
    fbdo.setResponseSize(2048);

    Firebase.begin(&config, &auth);


}

void updateDB() {

        struct tm timeinfo;

   if (Firebase.ready())
    {
      dataMillis = millis();

      Serial.print("Commit a document (append array)... ");
      // The dyamic array of write object firebase_firestore_document_write_t.
      std::vector<struct firebase_firestore_document_write_t> writes;

      // A write object that will be written to the document.
      struct firebase_firestore_document_write_t transform_write;
      transform_write.type = firebase_firestore_document_write_type_transform;

      if (getLocalTime(&timeinfo)) {
      
        char timeStr[20];
        char dateStr[20];
        snprintf(timeStr, sizeof(timeStr), "%02d:%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);
        snprintf(dateStr, sizeof(dateStr), "%04d-%02d-%02d", timeinfo.tm_year + 1900, timeinfo.tm_mon + 1, timeinfo.tm_mday);
        std::string strDate(dateStr);

      // Construct the path using the std::string
        std::string pathh = "woke_up_collection/" + strDate;

        // Set the document path of document to write (transform)
        transform_write.document_transform.transform_document_path = pathh.c_str();;

        // Set a transformation of a field of the document.
        struct firebase_firestore_document_write_field_transforms_t field_transforms;

        // Set field path to write.
        field_transforms.fieldPath = "appended_data";

        field_transforms.transform_type = firebase_firestore_transform_type_append_missing_elements;

        // For the usage of FirebaseJson, see examples/FirebaseJson/BasicUsage/Create_Edit_Parse/Create_Edit_Parse.ino
        FirebaseJson content;

        content.set("values/[0]/stringValue",timeStr );

        // Set the transformation content.
        field_transforms.transform_content = content.raw();

        // Add a field transformation object to a write object.
        transform_write.document_transform.field_transforms.push_back(field_transforms);

        // Add a write object to a write array.
        writes.push_back(transform_write);

        if (Firebase.Firestore.commitDocument(&fbdo, FIREBASE_PROJECT_ID, "" /* databaseId can be (default) or empty */, writes /* dynamic array of firebase_firestore_document_write_t */, "" /* transaction */))
            Serial.printf("ok\n%s\n\n", fbdo.payload().c_str());
        else{
            Serial.println(fbdo.errorReason());
        }
        std::string event_To_write=strDate+" "+timeStr+"\n";

        SD_appendFile(SD, "/evevts_documentation.txt",event_To_write.c_str() );

    } else {
      Serial.println("Failed to obtain time");
      timeinfo.tm_hour=hour();
      timeinfo.tm_min= minute();
      timeinfo.tm_sec=second();
      timeinfo.tm_year=year();
      timeinfo.tm_mon=month();
      timeinfo.tm_mday=day();
      char timeStr[20];
      char dateStr[20];
      snprintf(timeStr, sizeof(timeStr), "%02d:%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);
      snprintf(dateStr, sizeof(dateStr), "%04d-%02d-%02d", timeinfo.tm_year , timeinfo.tm_mon , timeinfo.tm_mday);
      std::string strDate(dateStr);

      // Construct the path using the std::string
      std::string pathh = "woke_up_collection/" + strDate;

      // Set the document path of document to write (transform)
        transform_write.document_transform.transform_document_path = pathh.c_str();;

        // Set a transformation of a field of the document.
        struct firebase_firestore_document_write_field_transforms_t field_transforms;

        // Set field path to write.
        field_transforms.fieldPath = "appended_data";

        field_transforms.transform_type = firebase_firestore_transform_type_append_missing_elements;

        // For the usage of FirebaseJson, see examples/FirebaseJson/BasicUsage/Create_Edit_Parse/Create_Edit_Parse.ino
        FirebaseJson content;
        content.set("values/[0]/stringValue",timeStr );
        // Set the transformation content.
        field_transforms.transform_content = content.raw();

        // Add a field transformation object to a write object.
        transform_write.document_transform.field_transforms.push_back(field_transforms);

        // Add a write object to a write array.
        writes.push_back(transform_write);

        if (Firebase.Firestore.commitDocument(&fbdo, FIREBASE_PROJECT_ID, "" /* databaseId can be (default) or empty */, writes /* dynamic array of firebase_firestore_document_write_t */, "" /* transaction */))
            Serial.printf("ok\n%s\n\n", fbdo.payload().c_str());
        else {
            Serial.println(fbdo.errorReason());
        }
          std::string event_To_write=strDate+" "+timeStr+"\n";
          SD_appendFile(SD, "/evevts_documentation.txt",event_To_write.c_str() );

    }
   }
}

