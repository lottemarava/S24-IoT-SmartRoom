import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../HomePage.dart';

Color sleepColor = Color(0xFF49120C);
double motionDetectionValue = 0;
bool sleepSaved=false;
bool sleepApplied=false;

void _saveColorAndMotionDetection(Color color, double motionDetectionValue) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('sleepColor', color.value);
  prefs.setDouble('motionDetectionValue', motionDetectionValue);
}

void ApplyColor(bool save, BuildContext context,String c_uid) {
  HSVColor hsvDecode = HSVColor.fromColor(sleepColor);
  var data =
      '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${save ? '1' : '0'}+${motionDetectionValue}';
  writeDataWithCharacteristic(c_uid, data, context);
}

class SleepColorPage extends StatefulWidget {
  SleepColorPage(this.c_uid, {super.key});

  late String c_uid;
  bool isLoading = true; // Add a loading indicator
  String loadingMessage = 'Loading Data...'; // Add a loading message

  @override
  State<SleepColorPage> createState() => SleepColorPageState();
}

class SleepColorPageState extends State<SleepColorPage> {
  static const String COLOR_MODE_UUID = "c78ed52c-7a26-49ab-ba3c-c4133568a8f2";

  @override
  void initState() {
    super.initState();
    _loadColorAndMotionDetection(); // Load the saved color and motion detection value when the page is initialized.
  }

  void _onColorChanged(HSVColor color) {
    setState(() => sleepColor = color.toColor());
  }

  void _loadColorAndMotionDetection() async {
    widget.isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int colorValue = prefs.getInt('sleepColor') ?? 0xFF49120C;
    double motionDetectionVal = prefs.getDouble('motionDetectionValue') ?? 0.6;

    setState(() {
      sleepColor = Color(colorValue);
      motionDetectionValue = motionDetectionVal;
      widget.isLoading = false; // Set loading to false after data is loaded
    });
  }
/*
  void _saveColorAndMotionDetection(Color color, double motionDetectionValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('endColor', color.value);
    prefs.setDouble('motionDetectionValue', motionDetectionValue);
  }

  void ApplyColor(bool save, BuildContext context) {
    HSVColor hsvDecode = HSVColor.fromColor(sleepColor);
    var data =
        '${hsvDecode.hue}+${hsvDecode.saturation}+${hsvDecode.value}+${save ? '1' : '0'}+${widget.motionDetectionValue}';
    writeDataWithCharacteristic(widget.c_uid, data, context);
  }

 */

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Instructions"),
          content: Text(
            "1. Pick a color from the box\n"
                "2. Change the brightness for night mode by using the top slider\n"
                "3. Press 'Apply Changes' to see the night mode color on the lights\n"
                "4. Change the brightness for motion mode by using the top slider\n"
                "5. Press 'Save Changes' if you want to change the lights to the selected colors\n\n"
                "*night mode color can be viewed at the top left corner while motion mode can be viewed above its slider without even applying but could be inaccurate",
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
          color: Colors.white,
        ),
      ),
    ),
    body:PopScope(
    canPop: true,
    onPopInvoked: (didPop) {
      var data = '${0}';
      writeDataWithCharacteristic(COLOR_MODE_UUID, data, context);
    },
    child: SingleChildScrollView(
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Please Choose Night Mode Color',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.help),
                        onPressed: () {
                          _showInstructions();
                        },
                      ),
                    ],
                  ),
                ),
                _buildHead(sleepColor),
                PaletteValuePicker(
                  color: HSVColor.fromColor(sleepColor),
                  onChanged: (value) => _onColorChanged(value),
                ),
                SizedBox(height: 20,),

                Divider(
                  height: 15,
                  color: Colors.grey,
                  thickness: 2,
                ),
                SizedBox(height: 20,),

                Text(
                  'Motion Detection Brightness',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                _buildHead(HSVColor.fromColor(sleepColor).withValue(motionDetectionValue).toColor()),
                SliderPicker(
                  value: motionDetectionValue,
                  onChanged: (value) => setState((){motionDetectionValue = value;}),
                  colors: valueColors,
                ),
                SizedBox(height: 14,),

                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                ElevatedButton(
                  onPressed: () {
                    sleepApplied = true;
                    sleepSaved = false;
                    ApplyColor(false, context, widget.c_uid);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade800,
                  ),
                  child: Text('Apply Changes', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 8,),
                ElevatedButton(
                  onPressed: () {
                    sleepApplied = false;
                    sleepSaved = true;
                    _saveColorAndMotionDetection(sleepColor, motionDetectionValue);
                    ApplyColor(true, context, widget.c_uid);
                    Widget okButton = TextButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                       /* Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Night Light')),
                        );*/
                      },
                    );

                    // set up the AlertDialog
                    AlertDialog alert = AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Night Color Settings Changed",
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
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
                  child: Text('Save Changes', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 30),
    ]
                )
              ],
            ),
      )),
    ),
  );

  }

}

Widget _buildHead(Color color) {
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
              color: color,
            ),
          ),
        ),

        const SizedBox(width: 22),

        // HexPicker
        Expanded(
          child: HexPicker(
            color: color,
            onChanged: (Color value) => {},
          ),
        )
      ],
    ),
  );
}

List<Color> get valueColors => <Color>[
  Colors.black,
  HSVColor.fromColor(sleepColor).withValue(1.0).toColor(),
];