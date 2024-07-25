import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nightlight/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static const String channelId = 'activity_channel';
  static const String channelName = 'Activity Notifications';
  static const String channelDescription = 'Notifications for new activities detected';
  bool _isFirstLoad = true; // Flag to track the first data load

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _createNotificationChannel();
  }

  void _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(channelId, channelName,
            importance: Importance.max, priority: Priority.high, showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Stream<QuerySnapshot> _getActivityStream() {
    return firestore.collection('Activity').orderBy('time', descending: true).snapshots();
  }

  Map<String, List<DocumentSnapshot>> _groupDocumentsByDate(List<DocumentSnapshot> documents) {
    Map<String, List<DocumentSnapshot>> groupedDocuments = {};
    for (var doc in documents) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      var date = data['date'];

      if (!groupedDocuments.containsKey(date)) {
        groupedDocuments[date] = [];
      }
      groupedDocuments[date]!.add(doc);
    }
    return groupedDocuments;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getActivityStream(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white70,
            appBar: basicAppBar(),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData && snapshot.data != null) {
            List<DocumentSnapshot> documents = snapshot.data!.docs;
            Map<String, List<DocumentSnapshot>> groupedDocuments = _groupDocumentsByDate(documents);
            if (snapshot.hasData && documents.isNotEmpty && !_isFirstLoad) {
              _showNotification('New Activity Detected', 'A new activity has been recorded.');
            }
            _isFirstLoad = false; // Update the flag after the first load

            return Scaffold(
              backgroundColor: Colors.white70,
              appBar: basicAppBar(),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.teal.shade600,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Night Active Times Detected',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      padding: EdgeInsets.all(8.0),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: groupedDocuments.isEmpty
                          ? Center(child: Text('No Night Active Times Detected.'))
                          : ListView(
                              children: groupedDocuments.entries.map((entry) {
                                String date = entry.key;
                                List<DocumentSnapshot> docs = entry.value;

                                return ExpansionTile(
                                  title: Text(
                                    date,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade800,
                                    ),
                                  ),
                                  children: [
                                    ListTile(
                                      title: Text(
                                        '${docs.length} night active times detected',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal.shade700,
                                        ),
                                      ),
                                    ),
                                    ...docs.map((doc) {
                                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                                      String time = data['time'];

                                      return ListTile(
                                        title: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.teal.shade100,
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Time: $time',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: Colors.white70,
              appBar: basicAppBar(),
              body: Center(child: Text('No Night Active Times Detected.')),
            );
          }
        }

        return Scaffold(
          backgroundColor: Colors.white70,
          appBar: basicAppBar(),
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

AppBar basicAppBar() {
  return AppBar(
    centerTitle: true,
    automaticallyImplyLeading: false,
    backgroundColor: Colors.teal.shade800,
    title: Text(
      'Night Light',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}
