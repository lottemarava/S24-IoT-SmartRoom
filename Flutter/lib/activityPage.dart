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
  String? _requestedDate; // Store the requested date

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
    if (_requestedDate != null && _requestedDate!.isNotEmpty) {
      return firestore
          .collection('Dates')
          .where(FieldPath.documentId, isEqualTo: _requestedDate)
          .snapshots();
    }
    return firestore.collection('Dates').snapshots();
  }

  void _requestDate(String date) {
    setState(() {
      _requestedDate = date;
    });
  }

@override
Widget build(BuildContext context) {
  TextEditingController _dateController = TextEditingController();

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
          TextField(
            controller: _dateController,
            decoration: InputDecoration(
              labelText: 'Enter date (YYYY-MM-DD)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              _requestDate(_dateController.text);
            },
            child: Text('Request Data By Date'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getActivityStream(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData && snapshot.data != null) {
                    List<DocumentSnapshot> documents = snapshot.data!.docs;
                    if (documents.isNotEmpty && !_isFirstLoad) {
                      _showNotification('New Activity Detected', 'A new activity has been recorded.');
                    }
                    _isFirstLoad = false; // Update the flag after the first load

                    return documents.isEmpty
                        ? Center(child: Text('No Night Active Times Detected.'))
                        : ListView(
                            children: documents.map((doc) {
                              String date = doc.id;
                              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                              List<dynamic> times = data['time'];

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
                                      '${times.length} night active times detected',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade700,
                                      ),
                                    ),
                                  ),
                                  ...times.map((time) {
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
                          );
                  } else {
                    return Center(child: Text('No Night Active Times Detected.'));
                  }
                }

                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    ),
  );
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
}