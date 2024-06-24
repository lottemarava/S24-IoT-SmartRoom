import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'HomePage.dart';
import 'NavigateToBluetooth.dart';
import 'WIFISettingsPage.dart';

/*
void main() {
  runApp(const MyApp());
}
*/
class myProvider extends ChangeNotifier {
  bool wifiConnected = false;
  bool timeConfigured = false;
  bool timeManConfigured = false;

  void updateWiFiStatus(bool isConnected) async {
    wifiConnected = isConnected;
    notifyListeners(); // Notify listeners of the change
  }

  void updateTimeConfigured(bool isConfigured) async {
    timeConfigured = isConfigured;
    notifyListeners(); // Notify listeners of the change
  }
  void updateTimeManConfigured(bool isConfigured) async {
    timeManConfigured = isConfigured;
    notifyListeners(); // Notify listeners of the change
  }

}

bool popup = false;
bool escaped = false;
void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => myProvider())
        ],
        child:
        MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Night Light',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
            fontFamily: 'Alef'
        ),
        home: StartPage(),
        //home: MyHomePage(title: 'Night light'),
      ),
  ));
}
class StartPage extends StatefulWidget {
  const StartPage({super.key}) ;
    @override
    _MyAppState createState() => _MyAppState();
    Widget build(BuildContext context) {
      /*return FutureBuilder<List<BluetoothDevice>>(
        future: FlutterBlue.instance.connectedDevices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Stream is still loading
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle error
            return Text('Error: ${snapshot.error}');
          } else {
            // Check if there is at least one connected device
            List<BluetoothDevice> connectedDevices = snapshot.data!;
            for (var device in connectedDevices) {
              if (device.name.contains("ESP32")) {
                return MyHomePage(title: 'Night light');
              }
            }
            return BluetoothButtonPage();
            //return MyHomePage(title: 'Night light');
          }
        }
      );*/
      return MyHomePage(title: 'Night light');
    }
  }

class _MyAppState extends State<StartPage> with WidgetsBindingObserver {
  void updateWiFiStatus(bool isConnected) {
    Provider.of<myProvider>(context, listen: false)
        .updateWiFiStatus(isConnected);
  }

  void updateTimeConfigured(bool isConfigured) {
    Provider.of<myProvider>(context, listen: false)
        .updateTimeConfigured(isConfigured);
  }
  void updateTimeManConfigured(bool isConfigured) {
    Provider.of<myProvider>(context, listen: false)
        .updateTimeManConfigured(isConfigured);
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (exiting) {
      if (initialized)
        await targetDevice.disconnect();
      connected = false;
      exiting = false;
      print("ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ");
    }
    else {
      switch (state) {
        case AppLifecycleState.resumed:
        // --
          print(connected);
          print(inside);
          print(popup);
          print(escaped);
          if (!connected && !inside && !popup && !escaped) {
            showDialog(context: context, builder: (context) {
              return PopScope(child: Center(child: CircularProgressIndicator()),
                canPop: false,
                onPopInvoked: (bool didPop) {
                  return;
                },);
            },);
            bool this_connected = false;
            Future.delayed(const Duration(milliseconds: 5000), () async {
              if (!this_connected) {
                escaped = true;
                Navigator.of(context).pop();
              }
            });
            await targetDevice.connect(autoConnect: true);
            await discoverServices(context);
            connected = true;
            this_connected = true;
            if (!escaped)
              Navigator.of(context).pop();
            else
              escaped = false;
          }
          print('Resumed');
          break;
        case AppLifecycleState.inactive:
        // --
          print('Inactive');
          break;
        case AppLifecycleState.paused:
        // --
          if (initialized && connected)
            targetDevice.disconnect();
          connected = false;
          print('Paused');
          break;
        case AppLifecycleState.detached:
        // --
          if (initialized && connected)
            targetDevice.disconnect();
          connected = false;
          print('Detached');
          break;
        case AppLifecycleState.hidden:
        // A new **hidden** state has been introduced in latest flutter version
          if (initialized && connected)
            targetDevice.disconnect();
          connected = false;
          print('Hidden');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BluetoothButtonPage();
  }
}

