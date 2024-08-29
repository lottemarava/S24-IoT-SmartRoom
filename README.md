# Smart Room Project

## By: Amal Hihi, Sarah Hamou, Lottem Arava

---

## Project Overview

- This project incorporates software from the following GitHub project:

- IOT-NightLight https://github.com/MhamedAhmad/IOT-NightLight/tree/main

---

## Project Overall Explanation:


The night light project is designed to enhance both sleep quality and nighttime mobility for elderly residents in nursing homes. This specialized lighting solution caters to the specific needs of older adults by integrating motion detection with customizable features. The night light offers adjustable colors and intensity levels tailored to create a sleep-friendly environment. By using a motion detection sensor, the light adapts to movements, ensuring safe navigation during the night without disrupting the sleep experience.

## Our Project in details

## Main Features: 
1.**Time-Based Lighting:** Adjusts light color and intensity for better sleep.

2.**Motion Detection:** Utilizes a motion sensor that turns the lights up when a person is detected getting up, ensuring safe navigation during the night.

3.**Data Logging:** Saves activity data to Firebase, accessible via a Flutter app.

4. **Real-Time Notifications**: Sends instant notifications through FCM for relevant events, ensuring timely alerts.

5.**SD Card Recovery**: Provides a recovery mechanism using an SD card to restore data in case of issues.


## How To Use : 

1.Download 'nightlight' app.

2.Turn on both bluetooth and location in your phone.

3.Press on connect to connect to the ESP via bluetooth and give permissions for location/bluetooth if asked.

4.In WiFi page enter network information to connect in order for the ESP to keep track of the current time (doing so once is enough as long as the network info doesn't change since they will be saved).

5.if connecting to WiFi fails the option to send the phone's current time to ESP can be used *this option is less accurate (up to 1 minute error) and the time will be lost if if the ESP gets turned off.

6.Set the preferred settings you want to use and Do Not Forget To Press Save :) (the settings will be saved untill changed again).

![Connection Diagram](https://github.com/lottemarava/S24-IoT-SmartRoom/blob/main/lighttranstiojn.PNG)

## Folder Structure

- **ESP32**: Source code for the ESP side (firmware).
- **Documentation**: Wiring diagram and basic operating instructions.
- **Unit Tests**: Tests for individual hardware components (input/output devices).
- **Flutter App**: Dart code for our Flutter application.
- **Parameters**: Descriptions of configurable parameters.
- **Assets**: 3D printed parts and audio files used in this project.

---
## Folder Description
- **Flutter** : dart code for our Flutter app.
- **UnitTests** : tests for individual hardware components (input / output devices).
- **hsv_night_light** : source code for the esp side (firmware).
---
## Arduino/ESP32 Libraries

The following libraries were installed and used for this project:

- **AdaFruit Neopixek** - Version 1.12.3
- **SD** - Version 1.3.0
- **FireBase Arduino Client Library for ESP8266 & ESP32** - Version 4.4.14
- **FireBase ESP32 Client** - Version 4.4.14
- **Time** - Version 1.6.1
- **ld2410** - Version 0.1.3

---
## Hardware Used
- 1 X ESP32 (30pins)
- 1 X HLK-LD2410C
- 1 X Neopixel 
- 1 X Micro SD 

## Project Diagram
![Connection Diagram](https://github.com/lottemarava/S24-IoT-SmartRoom/blob/main/connectionDiagram.png)

## Project Poster
For a detailed overview, refer to the project poster. This project is part of ICST - The Interdisciplinary Center for Smart Technologies, Taub Faculty of Computer Science, Technion.

[ICST Website](https://icst.cs.technion.ac.il/)

---
