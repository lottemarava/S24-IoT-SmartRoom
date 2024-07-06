import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ActivitiesPage extends StatefulWidget {
  @override
  _ActivitiesPageState createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialValues();
  }

  Future<void> _fetchInitialValues() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref();
      DatabaseEvent event = await ref.child('Activity').once();

      Map<String, dynamic>? activity =
          (event.snapshot.value as Map<dynamic, dynamic>?)?.cast<String, dynamic>();
      if (activity != null) {
        setState(() {
          _activities = activity.entries
              .map((entry) => {
                    'id': entry.key,
                    ...entry.value as Map<String, dynamic>
                  })
              .toList();
        });
      }
    } catch (error) {
      print('Error fetching initial values: $error');
      // Handle the error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Night Active Time',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 35, 109, 247),
      ),
      body: _activities.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_activities[index]['title'] ?? 'No Title'),
                  subtitle: Text(_activities[index]['description'] ?? 'No Description'),
                );
              },
            ),
    );
  }
}
