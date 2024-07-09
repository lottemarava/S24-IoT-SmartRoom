import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nightlight/main.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {


//   Future<List<Map<String, dynamic>>> _fetchInitialValues() async {
//     try {
//       DatabaseReference ref = FirebaseDatabase.instance.ref();
//       DatabaseEvent event = await ref.child('Activity').once();

//       Map<String, dynamic>? activity =
//           (event.snapshot.value as Map<dynamic, dynamic>?)?.cast<String, dynamic>();
//       if (activity != null) {
//         setState(() {
//           _activities = activity.entries
//               .map((entry) => {
//                     'id': entry.key,
//                     ...entry.value as Map<String, dynamic>
//                   })
//               .toList();
//         });
//       }
//     } catch (error) {
//       print('Error fetching initial values: $error');
//       // Handle the error as needed
//     }
//     return _activities;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white70,
//       appBar: AppBar(
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//         //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         backgroundColor: Colors.teal.shade800,
//         title: Text('Night Light',
//             style: TextStyle(
//               fontSize: 30,
//               fontWeight: FontWeight.bold, color: Colors.white

//             )),
//       ),
//       body: _activities.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: _activities.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_activities[index]['title'] ?? 'No Title'),
//                   subtitle: Text(_activities[index]['description'] ?? 'No Description'),
//                 );
//               },
//             ),
//     );
//   }
// }

Future<QuerySnapshot> _getActivity() {
  return firestore
    .collection('Activity')
    .get();
}

@override
Widget build(BuildContext context) {
  return FutureBuilder<QuerySnapshot>(
    future: _getActivity(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          backgroundColor: Colors.white70,
          appBar: AppBar(
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
          ),
          body: Center(child: Text('Error: ${snapshot.error}')),
        );
      }

      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasData && snapshot.data != null) {
          List<DocumentSnapshot> documents = snapshot.data!.docs;
          List<Widget> dataWidgets = documents.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text("Data Recieved" ?? data.toString()),
              subtitle: Text(data['description'] ?? 'No Description'),
            );
          }).toList();

          return Scaffold(
            backgroundColor: Colors.white70,
            appBar: AppBar(
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
            ),
            body: dataWidgets.isEmpty
                ? Center(child: Text('No data found.'))
                : ListView(children: dataWidgets),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.white70,
            appBar: AppBar(
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
            ),
            body: Center(child: Text('No data found.')),
          );
        }
      }

      return Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
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
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    },
  );
}

}