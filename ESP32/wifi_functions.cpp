#include "wifi_functions.h"
const char* ntpServer = "time.google.com";
const long  gmtOffset_sec = 7200;
const int   daylightOffset_sec = 3600;

//using saved credentials to connect to WiFi and NTP
void connectWithPref()
{
  prefs.begin("saved_data", false);
  //prefs.clear();
  unsigned int  ssid_length = prefs.getBytesLength("ssid");
  unsigned int  pw_length = prefs.getBytesLength("pw");
  if(ssid_length > 0 && pw_length > 0)
  {
    char last_ssid[33] = {0};
    prefs.getBytes("ssid", last_ssid, ssid_length);
    char last_pw[64] = {0};
    prefs.getBytes("pw", last_pw, pw_length);
    IPAddress dns(8,8,8,8);
    WiFi.mode(WIFI_STA);
    WiFi.begin(last_ssid, last_pw);
    delay(2000);
    if(WiFi.status() == WL_CONNECTED)
    {
      configTime(0, 0, ntpServer);
      setenv("TZ", "IST-2IDT,M3.4.4/26,M10.5.0", 1);
      tzset();
      struct tm timeinfo;
      if(!getLocalTime(&timeinfo)){
        connected = true;
        return;
      }
      configured = true;
      connected = true;
      WiFi.disconnect(true);
      WiFi.mode(WIFI_OFF);
    }
  }
  else if(ssid_length > 0)
  {
    char last_ssid[33] = {0};
    prefs.getBytes("ssid", last_ssid, ssid_length);
    IPAddress dns(8,8,8,8);
    WiFi.mode(WIFI_STA);
    WiFi.begin(last_ssid);
    delay(2000);
    if(WiFi.status() == WL_CONNECTED)
    {
      configTime(0, 0, ntpServer);
      setenv("TZ", "IST-2IDT,M3.4.4/26,M10.5.0", 1);
      tzset();
      struct tm timeinfo;
      if(!getLocalTime(&timeinfo)){
        connected = true;
        return;
      }
      configured = true;
      connected = true;
      WiFi.disconnect(true);
      WiFi.mode(WIFI_OFF);
    }
  }
}

void handleCredentials(std::string credentials)
{
  bool now_connected = false;
  connecting = true;
  int value = 3;
  for(int i=0; i < 3; i++)
  {
    String ssid;
    String pw;
    ssid = getValue(String(credentials.c_str()), '+', 0);
    const char* input_ssid = ssid.c_str();
    pw = getValue(String(credentials.c_str()), '+', 1);
    const char* input_pw = pw.c_str();
    IPAddress dns(8,8,8,8);
    WiFi.mode(WIFI_STA);
    if(strlen(input_pw) == 0)
    {
      WiFi.begin(input_ssid);
    }
    else
      WiFi.begin(input_ssid, input_pw);
    delay(2000);
    if(WiFi.status() == WL_CONNECTED)
    {
      prefs.putBytes("ssid", input_ssid, strlen(input_ssid));
      if(strlen(input_pw) == 0)
        prefs.remove("pw");
      else
        prefs.putBytes("pw", input_pw, strlen(input_pw));
      configTime(0, 0, ntpServer);
      setenv("TZ", "IST-2IDT,M3.4.4/26,M10.5.0", 1);
      tzset();
      struct tm timeinfo;
      if(!getLocalTime(&timeinfo, 2000)){
        now_connected = true;
        connected = true;
        was_connected = true;
      }
      else
      {
        now_connected = true;
        connected = true;
        was_connected = true;
        WiFi.disconnect(true);
        WiFi.mode(WIFI_OFF);
        was_configured = true;
        configured = true;
        pCharacteristic_5->setValue(value);
        pCharacteristic_5->notify();
        connecting = false;
        return;
      }
    }
  }
  if(now_connected){
    value = 2;
    if(manually_configured)
      value = 5;
  }
  else if (configured || manually_configured)
    value = 1;
  else
    value = 0;
  pCharacteristic_5->setValue(value);
  pCharacteristic_5->notify();
  connecting = false;
}