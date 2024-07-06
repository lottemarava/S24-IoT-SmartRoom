import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:nightlight/activityPage.dart';
import 'package:nightlight/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ColorsPages/WakeColorPage.dart';
import 'ColorsPages/SleepColorPage.dart';
import 'NavigateToBluetooth.dart';
import 'TimeSettingsPage.dart';
import 'WIFISettingsPage.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

Map<String, BluetoothCharacteristic?> characteristicDictionary = {};
StreamSubscription<List<int>>? stream;
bool exiting = false;


class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
writeDataWithCharacteristic(String c, String data, BuildContext context) async {
  BluetoothCharacteristic? bc=characteristicDictionary[c];
  if (bc == null)
    return;

  List<int> bytes = utf8.encode(data);
  try{
    await bc.write(bytes);
  }
  catch(error)
  {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () { Navigator.of(context).pop();popup=false;
      targetDevice.disconnect();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) =>BluetoothButtonPage())
      );},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Row(
          children: [
            Icon(Icons.cancel,color: Colors.red), // Add an icon if you want
            SizedBox(width: 8), // Add some space between the icon and text
            Text("Bluetooth Disconnected",style: TextStyle(fontSize: 20,)),
          ]
      ),
      content: Text("Connect to Bluetooth again"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    popup = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {

  static const String SERVICE_UUID = "cfdfdee4-a53c-47f4-a4f1-9854017f3817";
  static const String TIME_UUID = "125f4480-415c-46e0-ab49-218377ab846a";
  static const String WAKE_COLOR_UUID = "81b703d5-518a-4789-8133-04cb281361c3";
  static const String SLEEP_COLOR_UUID = "3ca69c2c-0868-4579-8fa8-91a203a5b931";
  static const String WIFI_UUID = "006e3a0b-1a72-427b-8a00-9d03f029b9a9";
  static const String WIFI_SIGNAL_UUID = "be31c4e4-c3f7-4b6f-83b3-d9421988d355";
  static const String COLOR_MODE_UUID = "c78ed52c-7a26-49ab-ba3c-c4133568a8f2"; //todo: CHANGE THIS
  static const String TIME_CONFIG = "6d6fb840-ed2b-438f-8375-9220a5164be8";
  static const String TARGET_DEVICE_NAME = "ESP32";


  FlutterBlue flutterBlue = FlutterBlue.instance;
  late StreamSubscription<ScanResult>? scanSubscription;
  late BluetoothCharacteristic targetCharacteristic;
  String connectionText = "";

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    TimeSettingsPage(TIME_UUID),
    WakeColorPage(WAKE_COLOR_UUID),
    SleepColorPage(SLEEP_COLOR_UUID),
    WIFISettingsPage(WIFI_UUID),
    ActivitiesPage(),
  ];

  Future<void> _onItemTapped(int index) async {
    if ((_selectedIndex == 1 && index != 1)) {
      if(wakeSaved==false && wakeApplied==true) {
        wakeApplied = false;
        showWarningDialog('WakeColorPage', index);
      }
      if(index != 2){
        var data = '${0}';
        await writeDataWithCharacteristic(COLOR_MODE_UUID, data, context);
      }
      else
      {
        var data = '${2}';
        await writeDataWithCharacteristic(COLOR_MODE_UUID, data, context);
      }
    }else if((_selectedIndex == 2 && index != 2)){
      if(sleepSaved==false && sleepApplied==true) {
        sleepApplied = false;
        showWarningDialog('SleepColorPage', index);
      }
      if(index != 1){
        var data = '${0}';
        await writeDataWithCharacteristic(COLOR_MODE_UUID, data, context);
      }
      else
      {
        var data = '${1}';
        await writeDataWithCharacteristic(COLOR_MODE_UUID, data, context);
      }
    }
    else if(index == 1 || index == 2)
    {
      var data = '${index}';
      await writeDataWithCharacteristic(COLOR_MODE_UUID, data, context);
    }
      setState(() {
        _selectedIndex = index;
      });
  }

  void showWarningDialog(String pageName, int index) {
    Widget saveButton = TextButton(
      child: Row(
        children: [
          Icon(Icons.save,color: Colors.green,), // Add an icon if you want
          SizedBox(width: 8), // Add some space between the icon and text
          Text(
            "Save and Continue",
            textAlign: TextAlign.left, // Align the text to the left
          ),
        ],
      ),
      onPressed: () {
        if (pageName == 'WakeColorPage') {
          wakeApplied = false;
          wakeSaved = true;
          saveWakeChanges(true, context, WAKE_COLOR_UUID, wakeColor);
        } else {
          sleepApplied = false;
          sleepSaved = true;
          saveSleepChanges(true, context, SLEEP_COLOR_UUID, motionDetectionValue, sleepColor);
        }
        Navigator.of(context).pop();
      },
    );

    Widget discardButton = TextButton(
      child: Row(
        children: [
          Icon(Icons.delete,color: Colors.red.shade800,), // Add an icon if you want
          SizedBox(width: 8), // Add some space between the icon and text
          Text(
            "Discard Changes and Continue",
            textAlign: TextAlign.left, // Align the text to the left
          ),
        ],
      ),
      onPressed: () {
        if (pageName == 'WakeColorPage') {
          wakeApplied = false;
          wakeSaved = true;
        } else {
          sleepApplied = false;
          sleepSaved = true;
        }

        Navigator.of(context).pop();
      },

    );

    AlertDialog alert = AlertDialog(
      //title: Text("Alert",),
      content: Text("Do you want to save your changes before leaving?",style: TextStyle(fontSize: 16),),
      actions: [
        saveButton,
        discardButton,
      ],
    );


    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

  }


  Future<void> saveWakeChanges(bool save,BuildContext context, String c_uid,Color color) async {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('wakeColor', color.value);
      wakeColorSaved=color;

      HSVColor hsvDecode = HSVColor.fromColor(wakeColor);
      var data = '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${save ? '1' : '0'}';
      writeDataWithCharacteristic(c_uid, data, context);

  }

  Future<void> saveSleepChanges(bool save,BuildContext context, String c_uid,double motionDetectionValue ,Color color) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('sleepColor', color.value);
    prefs.setDouble('motionDetectionValue', motionDetectionValue);
    sleepColorSaved=color;

    HSVColor hsvDecode = HSVColor.fromColor(sleepColor);
    var data =
        '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${save ? '1' : '0'}+${motionDetectionValue}';
    writeDataWithCharacteristic(c_uid, data, context);

  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: _pages[_selectedIndex],
              ),
            ],
          ),
          bottomNavigationBar: Builder(
            builder: (context) {
              return ConvexAppBar(
                style: TabStyle.reactCircle,
                color: Colors.white,
                backgroundColor: Colors.teal.shade800,
                items: [
                  TabItem(
                    icon: (context.watch<myProvider>().timeConfigured ||
                        context.watch<myProvider>().timeManConfigured)
                        ? Icons.timer_outlined
                        : Icons.timer_off_outlined,
                    title: 'Time',
                  ),
                  TabItem(icon: Icons.sunny, title: 'Wake Color'),
                  TabItem(icon: Icons.nightlight_outlined, title: 'Sleep Color'),
                  TabItem(
                    icon: context.watch<myProvider>().wifiConnected
                        ? Icons.wifi
                        : Icons.wifi_off,
                    title: 'WiFi',
                  ),
                  TabItem(icon: Icons.cloud_circle, title: 'Activity'),
                ],
                onTap: _onItemTapped,
              );
            },
          ),

        ),

        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop)
            return;
          _onBackButtonPressed(context);
        }
    );
  }



    Future<void> _onBackButtonPressed(BuildContext context) async{
      await showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: const Text("Closing App"),
              content: const Text("Do you Want to close the app?"),
              actions: <Widget> [
                TextButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: const Text("No")),
                TextButton(onPressed: (){
                  exiting = true;
                  SystemNavigator.pop();
                }, child: const Text("Yes")),
              ],);
          });
    }

}
