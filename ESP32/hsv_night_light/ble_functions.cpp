#include "ble_functions.h"

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic_1 = NULL;
BLECharacteristic* pCharacteristic_2 = NULL;
BLECharacteristic* pCharacteristic_3 = NULL;
BLECharacteristic* pCharacteristic_4 = NULL;
BLECharacteristic* pCharacteristic_6 = NULL;
BLECharacteristic* pCharacteristic_7 = NULL;
BLEDescriptor *pDescr;
BLE2902 *pBLE2902_1;
BLE2902 *pBLE2902_2;
#define SERVICE_UUID        "cfdfdee4-a53c-47f4-a4f1-9854017f3817"
#define CHAR1_UUID          "006e3a0b-1a72-427b-8a00-9d03f029b9a9"
#define CHAR2_UUID          "81b703d5-518a-4789-8133-04cb281361c3"
#define CHAR3_UUID          "3ca69c2c-0868-4579-8fa8-91a203a5b931"
#define CHAR4_UUID          "125f4480-415c-46e0-ab49-218377ab846a"
#define CHAR5_UUID          "be31c4e4-c3f7-4b6f-83b3-d9421988d355"
#define CHAR6_UUID          "c78ed52c-7a26-49ab-ba3c-c4133568a8f2"
#define CHAR7_UUID          "6d6fb840-ed2b-438f-8375-9220a5164be8"
#define CHAR8_UUID          "69ce5b3b-3db5-4511-acd1-743d30bcfb37"

class CharacteristicCallBack: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pChar) override { 
    if((pChar->getUUID()).toString() == CHAR1_UUID)
      handleCredentials((pChar->getValue()).c_str());
    else if((pChar->getUUID()).toString() == CHAR2_UUID)
      handleColors((pChar->getValue()).c_str(), true);
    else if((pChar->getUUID()).toString() == CHAR3_UUID)
      handleColors((pChar->getValue()).c_str(), false);
    else if((pChar->getUUID()).toString() == CHAR4_UUID)
      handleCycleTimes((pChar->getValue()).c_str());
    else if((pChar->getUUID()).toString() == CHAR6_UUID){
      page = (pChar->getValue()).c_str();
      color_page = (page != "0");
      if(!color_page)
        return;
      int hue = high_hue;
      int sat = high_saturation;
      int val = high_value;
      if(page == "2")
      {
        hue = low_hue;
        sat = low_saturation;
        val = low_value;
      }
      uint32_t rgbcolor = pixels.gamma32(pixels.ColorHSV(hue, sat, val));
      pixels.fill(rgbcolor);
      pixels.show();
    }
    else if((pChar->getUUID()).toString() == CHAR7_UUID)
      handleTimeConfig((pChar->getValue()).c_str());
  }
};

class MyServerCallbacks: public BLEServerCallbacks {
    void onDisconnect(BLEServer* pServer) {
      Serial.println("DISCONNECTED");
      color_page = false;
      BT_connected = false;
      pServer->startAdvertising();
    }
    void onConnect(BLEServer* pServer) {
      BT_connecting = true;
      BT_connected = true;
    }
};

void BLEStart()
{
  BLEDevice::init("NightLightIOT");
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  BLEService *pService = pServer->createService(BLEUUID(SERVICE_UUID), 50);
  pCharacteristic_1 = pService->createCharacteristic(
                      CHAR1_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
                    );                   
  pCharacteristic_1->addDescriptor(new BLE2902());
  pCharacteristic_1->setCallbacks(new CharacteristicCallBack());
  pCharacteristic_2 = pService->createCharacteristic(
                      CHAR2_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
                    );                   
  pCharacteristic_2->addDescriptor(new BLE2902());
  pCharacteristic_2->setCallbacks(new CharacteristicCallBack());
  pCharacteristic_3 = pService->createCharacteristic(
                      CHAR3_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
                    );                   
  pCharacteristic_3->addDescriptor(new BLE2902());
  pCharacteristic_3->setCallbacks(new CharacteristicCallBack());
  pCharacteristic_4 = pService->createCharacteristic(
                      CHAR4_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
                    );                   
  pCharacteristic_4->addDescriptor(new BLE2902());
  pCharacteristic_4->setCallbacks(new CharacteristicCallBack());
  pCharacteristic_5 = pService->createCharacteristic(
                      CHAR5_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );                   
  pBLE2902_1 = new BLE2902();
  pBLE2902_1->setNotifications(true);
  pCharacteristic_5->addDescriptor(pBLE2902_1);
  pCharacteristic_5->setCallbacks(new CharacteristicCallBack());
  pCharacteristic_6 = pService->createCharacteristic(
                      CHAR6_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
                    );                   
  pCharacteristic_6->addDescriptor(new BLE2902());
  pCharacteristic_6->setCallbacks(new CharacteristicCallBack());
  pCharacteristic_7 = pService->createCharacteristic(
                      CHAR7_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  
                    );                   
  pCharacteristic_7->addDescriptor(new BLE2902());
  pCharacteristic_7->setCallbacks(new CharacteristicCallBack());
  pCharacteristic_8 = pService->createCharacteristic(
                      CHAR8_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );                   
  pBLE2902_2 = new BLE2902();
  pBLE2902_2->setNotifications(true);
  pCharacteristic_8->addDescriptor(pBLE2902_2);
  pCharacteristic_8->setCallbacks(new CharacteristicCallBack());
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);  // set value to 0x00 to not advertise this parameter
  BLEDevice::startAdvertising(); 
}

void notifyChange()
{
  if(configured && !was_configured && BT_connected && !BT_connecting)
  {
    was_configured = true;
    int value = 3;
    pCharacteristic_8->setValue(value);
    pCharacteristic_8->notify();
    was_connected = true;
  }
  else if(connected && !was_connected && BT_connected && !BT_connecting)
  {
    was_connected = true;
    int value = 2;
    if(configured)
    {
      value = 3;
      was_configured = true;
    }
    else if(manually_configured)
      value = 5;
    pCharacteristic_8->setValue(value);
    pCharacteristic_8->notify();
  }
}

void BLEConnectIndication()
{
  if(BT_connecting)
  {
    for(int i=0; i < 3; i++){
        pixels.fill(6553600);
        pixels.show();
        delay(400);
        pixels.clear();
        pixels.show();
        delay(400);
      }
      if(page != "0")
      {
        int hue = high_hue;
        int sat = high_saturation;
        int val = high_value;
        if(page == "2")
        {
          hue = low_hue;
          sat = low_saturation;
          val = low_value;
        }
        uint32_t rgbcolor = pixels.gamma32(pixels.ColorHSV(hue, sat, val));
        Serial.println(rgbcolor);
        pixels.fill(rgbcolor);
        pixels.show();
        color_page = true;
      }
      int value = 0;
      if(connected)
      {
        was_connected = true;
        value = 2;
        if(configured)
        {
          was_configured = true;
          value = 3;
        }
        else if(manually_configured)
          value = 5;
      }
      else if(manually_configured)
        value = 1;
      Serial.println(value);
      pCharacteristic_8->setValue(value);
      pCharacteristic_8->notify();
      BT_connecting = false;
  }
}