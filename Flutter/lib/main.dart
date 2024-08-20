import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'HomePage.dart';
import 'NavigateToBluetooth.dart';
import 'activityPage.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', 
  importance: Importance.high,
);

Future<void> initLocalNotifications() async {
  final AndroidInitializationSettings initializationSettingsAndroid = 
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = 
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}


class myProvider extends ChangeNotifier {
  bool wifiConnected = false;
  bool timeConfigured = false;
  bool timeManConfigured = false;

  void updateWiFiStatus(bool isConnected) async {
    wifiConnected = isConnected;
    notifyListeners();
  }

  void updateTimeConfigured(bool isConfigured) async {
    timeConfigured = isConfigured;
    notifyListeners();
  }

  void updateTimeManConfigured(bool isConfigured) async {
    timeManConfigured = isConfigured;
    notifyListeners();
  }
}

FirebaseFirestore firestore = FirebaseFirestore.instance;
bool popup = false;
bool escaped = false;
bool is_awake = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(App());      
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text(
                  snapshot.error.toString(),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => myProvider())
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Night Light',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
                useMaterial3: true,
                fontFamily: 'Alef',
              ),
              home: StartPage(),
            ),
          );
        }

        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<StartPage> with WidgetsBindingObserver {
  late FirebaseMessaging _firebaseMessaging;

  void updateWiFiStatus(bool isConnected) {
    Provider.of<myProvider>(context, listen: false).updateWiFiStatus(isConnected);
  }

  void updateTimeConfigured(bool isConfigured) {
    Provider.of<myProvider>(context, listen: false).updateTimeConfigured(isConfigured);
  }

  void updateTimeManConfigured(bool isConfigured) {
    Provider.of<myProvider>(context, listen: false).updateTimeManConfigured(isConfigured);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _firebaseMessaging = FirebaseMessaging.instance;
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received: ${message.notification?.title}");
      _showNotification(message.notification);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification opened: ${message.notification?.title}");
      
      if (message.notification != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ActivitiesPage(),
          ),
        );
      }
    });

    // Prevent Firebase from automatically displaying notifications
    _firebaseMessaging.subscribeToTopic('NightLight');
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

void _showNotification(RemoteNotification? notification) {
  if (notification != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
      0,
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
    is_awake = true;
                      
    Timer(Duration(minutes: 2), () {
        is_awake = false; // Change back to grey after 2 minutes
    });
  }
}
