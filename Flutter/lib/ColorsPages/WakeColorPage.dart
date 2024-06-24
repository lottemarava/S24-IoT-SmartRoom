import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomePage.dart';


class WakeColorPage extends StatefulWidget {
  WakeColorPage(this.c_uid, {super.key});

  late String c_uid;
  bool isLoading = true; // Add a loading indicator
  String loadingMessage = 'Loading Data...'; // Add a loading message

  @override
  State<WakeColorPage> createState() => WakeColorPageState();
}

Color wakeColor=Color(0xFF979DF2);
bool wakeSaved=false;
bool wakeApplied=false;

void _saveWakeColor(Color color) async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('wakeColor', color.value);
}

void ApplyWakeColor(bool save,BuildContext context, String c_uid) {

  HSVColor hsvDecode = HSVColor.fromColor(wakeColor);
  var data = '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${save ? '1' : '0'}';
  writeDataWithCharacteristic(c_uid, data, context);

}

class WakeColorPageState extends State<WakeColorPage> {
  static const String COLOR_MODE_UUID = "c78ed52c-7a26-49ab-ba3c-c4133568a8f2";

  @override
  void initState() {
    super.initState();
    _loadWakeColor(); // Load the saved color when the page is initialized.
  }

  void _onColorChanged(HSVColor color) {
    setState(() => wakeColor = color.toColor());
  }

  void _loadWakeColor() async {
    widget.isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int colorValue = prefs.getInt('wakeColor') ?? 0xFF979DF2;

    setState(() {
      wakeColor = Color(colorValue);
      widget.isLoading = false; // Set loading to false after data is loaded
    });
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Instructions"),
          content: Text(
            "1. Pick a color from the box\n"
                "2. Change the brightness by using the slider below\n"
                "3. Press 'Apply Changes' to see the selected color on the lights\n"
                "4. Press 'Save Changes' if you want to change the lights to the selected color\n\n"
              "*Color can be viewed at the top left corner even without applying but could be inaccurate",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }


  Widget build(BuildContext context) {
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
            color: Colors.white
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
    child: Center(
          child: widget.isLoading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                widget.loadingMessage,
                style: TextStyle(fontSize: 16),
              ),
            ],
          )
              : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Please Choose Day Mode Color',
                    style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 15,),
                  IconButton(
                    icon: Icon(Icons.help),
                    onPressed: () {
                      _showInstructions();
                    },
                  ),
                ],
              ),
              _buildHead(),
              PaletteValuePicker(
                color: HSVColor.fromColor(wakeColor),
                onChanged: (value) => _onColorChanged(value),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              ElevatedButton(
                onPressed: () {
                  wakeApplied=true;
                  wakeSaved=false;
                  ApplyWakeColor(false,context,widget.c_uid);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade800,
                ),
                child: Text('Apply Changes',style: TextStyle(color:Colors.white)),
              ),
              SizedBox(width: 8,),
              ElevatedButton(
                onPressed: () {
                  wakeApplied=false;
                  wakeSaved=true;
                  _saveWakeColor(wakeColor); // Save the current color
                  ApplyWakeColor(true,context,widget.c_uid);
                  Widget okButton = TextButton(
                  child: Text("OK"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                );

                // set up the AlertDialog
                AlertDialog alert = AlertDialog(
                  title: Row(
                      children: [
                        Icon(Icons.check_circle,color: Colors.green,), // Add an icon if you want
                        SizedBox(width: 8), // Add some space between the icon and text
                        Text("Day Color Settings Changed",style: TextStyle(fontSize: 17),),
                      ]

                  ),
                  actions: [
                    okButton,
                  ],
                );

                // show the dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade800,
                ),
                child: Text('Save Changes',style: TextStyle(color:Colors.white),),
              ),
            ],
          ),
          ],
          ),
        )),
    );
  }
}

Widget _buildHead() {
  return SizedBox(
    height: 50,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Avator
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.black26),
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: const Border.fromBorderSide(
                BorderSide(color: Colors.white, width: 3),
              ),
              color: wakeColor,
            ),
          ),
        ),

        const SizedBox(width: 22),

        // HexPicker
        Expanded(
          child: HexPicker(
            color: wakeColor,
            onChanged: (Color value) => {},
          ),
        )
      ],
    ),
  );
}