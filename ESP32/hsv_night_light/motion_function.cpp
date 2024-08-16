#include "HardwareSerial.h"
#include "Arduino.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/uart.h"
#include "esp_log.h"
#include "ld2410.h"
#include "motion_function.h"
static const char *TAG = "LD2410";


void connect_to_radar(){
   #if defined(ESP32)
    RADAR_SERIAL.begin(256000, SERIAL_8N1, RADAR_RX_PIN, RADAR_TX_PIN); //UART for monitoring the radar
  #elif defined(__AVR_ATmega32U4__)
    RADAR_SERIAL.begin(256000); //UART for monitoring the radar
  #endif 
  delay(1000);
  MONITOR_SERIAL.print(F("\nConnect LD2410 radar TX to GPIO:"));
  MONITOR_SERIAL.println(RADAR_RX_PIN);
  MONITOR_SERIAL.print(F("Connect LD2410 radar RX to GPIO:"));
  MONITOR_SERIAL.println(RADAR_TX_PIN);
  MONITOR_SERIAL.print(F("LD2410 radar sensor initialising: "));
  if(radar.begin(RADAR_SERIAL))
  {
    MONITOR_SERIAL.println(F("OK"));
    MONITOR_SERIAL.print(F("LD2410 firmware version: "));
    MONITOR_SERIAL.print(radar.firmware_major_version);
    MONITOR_SERIAL.print('.');
    MONITOR_SERIAL.print(radar.firmware_minor_version);
    MONITOR_SERIAL.print('.');
    MONITOR_SERIAL.println(radar.firmware_bugfix_version, HEX);
  }
  else
  {
    //MONITOR_SERIAL.println(F("not connected"));
  }


}


 bool detectMotion() {


  radar.read();
  if(radar.isConnected() )
  {
    lastReading = millis();
    if(radar.presenceDetected())
    {
      if(radar.stationaryTargetDetected())
      {
        Serial.print(F("Stationary target: "));
        Serial.print(radar.stationaryTargetDistance());
        if (radar.stationaryTargetDistance()-80>=lastSeen[(i%size)]){
          Serial.println("noiseeeeeeeeeeee");
        }//noise- dont add
        else{
          lastSeen[(i%size)]=radar.stationaryTargetDistance();
          i++;
          sum=0;
          for (int x=0;x<10;x++){
            sum+=lastSeen[x];
          }
          sum/=10;
          if (sum<=84){
              Serial.println("UP!!");
              return true;
          }
          Serial.println(sum);
        }
      }
      if(radar.movingTargetDetected()){
        Serial.print(F("Moving target: "));
        Serial.print(radar.movingTargetDistance());
      }
      Serial.println();
    }else{
      Serial.println(F("No target"));
    }
  }
  return false;

  }


  void act_acording_to_time(bool val){
  if (val == HIGH){
    if(!motion_detected){
      first_motion = millis()/1000 - offset;
      Serial.println(" here!");
      updateDB();
      
    }
    motion_detected = true;
    my_now = millis()/1000;
    if(my_now < first_motion){
      my_now = my_now + 4294967;}
    last_motion = millis()/1000;
    if(configured || manually_configured){
      actAccordingTime(true);}
    else if(!connecting)
    {
      actAccordingTime();
      connectWithPref();
    }
  }else{
    if(configured || manually_configured){
      my_now = millis()/1000;
      if(my_now < last_motion){
        my_now = my_now + 4294967;}
      if(my_now - last_motion >= delay_time){
        motion_detected = false;
        offset = 5 - (my_now - last_motion - delay_time);
      }if((my_now - last_motion >= delay_time + 5 && my_now - first_motion >= delay_time + 10) || last_motion == 4294967){
        actAccordingTime();
        offset = 0;
      }else{
        actAccordingTime(true);}
    }else if(!connecting){
      actAccordingTime();
      connectWithPref();
    }
  }

}
