import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nightlight/main.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  Stream<QuerySnapshot> _getActivityStream() {
    return firestore.collection('Activity').snapshots();
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
            List<Widget> dataWidgets = documents.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String time = data['time'] ?? 'No Time';
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
            }).toList();

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
                    const SizedBox(height: 16), // Add some space between the title and the list
                    Expanded(
                      child: dataWidgets.isEmpty
                          ? Center(child: Text('No Night Active Times Detected.'))
                          : ListView(children: dataWidgets),
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
