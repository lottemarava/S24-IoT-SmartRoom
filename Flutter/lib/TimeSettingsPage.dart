import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nightlight/ColorsPages/SleepColorPage.dart';
import 'package:nightlight/ColorsPages/WakeColorPage.dart';
import 'HomePage.dart';
import 'package:provider/provider.dart'; 
import 'package:percent_indicator/percent_indicator.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:widget_zoom/widget_zoom.dart';

class TimeSettingsPage extends StatefulWidget {
  TimeSettingsPage(this.c_uid, {Key? key});

  late String c_uid;
  TimeOfDay? _startTime = TimeOfDay(hour: 21, minute: 0);
  TimeOfDay? _endTime = TimeOfDay(hour: 7, minute: 0);
  int delayTime = 115;
  int transitionTime = 30;
  int fadeOut = 60;
  int fadeIn = 10;
  bool isLoading = true;
  String loadingMessage = 'Loading Data...';

  TimeOfDay? _startTimeSaved = TimeOfDay(hour: 21, minute: 0);
  TimeOfDay? _endTimeSaved = TimeOfDay(hour: 7, minute: 0);
  int delayTimeSaved = 115;
  int transitionTimeSaved = 30;
  int fadeOutSaved = 60;
  int fadeInSaved = 10;

  @override
  State<TimeSettingsPage> createState() => _TimeSettingsPageState();
}

Color sleepColorSaved = Colors.blue;
Color wakeColorSaved = Colors.blue;

class _TimeSettingsPageState extends State<TimeSettingsPage> {
  double _progress = 0.0;
  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _progress = _calculateProgress();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTimeSettings();
    _loadSavedTimeSettings();
    _startTimer();
  }

  bool get _isFadingIn {
    DateTime now = DateTime.now();
    DateTime startTime = DateTime(now.year, now.month, now.day,
            widget._startTimeSaved!.hour, widget._startTimeSaved!.minute)
        .subtract(Duration(minutes: widget.fadeInSaved));
    DateTime fadeInEndTime = DateTime(now.year, now.month, now.day,
        widget._startTimeSaved!.hour, widget._startTimeSaved!.minute);
    if (!now.isBefore(fadeInEndTime)) now = now.subtract(Duration(days: 1));
    return now.isAfter(startTime);
  }

  bool get _isNightMode {
    DateTime now = DateTime.now();
    DateTime startTime = DateTime(now.year, now.month, now.day,
        widget._startTimeSaved!.hour, widget._startTimeSaved!.minute);
    DateTime endTime = DateTime(now.year, now.month, now.day,
        widget._endTimeSaved!.hour, widget._endTimeSaved!.minute);
    DateTime tranistion =
        endTime.subtract(Duration(minutes: widget.transitionTimeSaved));

    if (!tranistion.isAfter(startTime) &&
        !tranistion.isAtSameMomentAs(startTime)) {
      tranistion = tranistion.add(Duration(days: 1));
    }
    if (!now.isAfter(startTime)) {
      now = now.add(Duration(days: 1));
    }
    return now.isBefore(tranistion);
  }

  bool get _isTransitioning {
    DateTime now = DateTime.now();
    DateTime endTime = DateTime(now.year, now.month, now.day,
        widget._endTimeSaved!.hour, widget._endTimeSaved!.minute);
    DateTime tranistion = DateTime(now.year, now.month, now.day,
            widget._endTimeSaved!.hour, widget._endTimeSaved!.minute)
        .subtract(Duration(minutes: widget.transitionTimeSaved));
    if (!now.isBefore(endTime)) now = now.subtract(Duration(days: 1));
    return now.isAfter(tranistion);
  }

  bool get _isFadingOut {
    DateTime now = DateTime.now();
    DateTime endTime = DateTime(now.year, now.month, now.day,
        widget._endTimeSaved!.hour, widget._endTimeSaved!.minute);
    DateTime fadeOutEndTime = DateTime(now.year, now.month, now.day,
            widget._endTimeSaved!.hour, widget._endTimeSaved!.minute)
        .add(Duration(minutes: widget.fadeOutSaved));
    if (!now.isAfter(endTime)) now = now.add(Duration(days: 1));
    return now.isBefore(fadeOutEndTime);
  }

  Widget _buildCenterText() {
    if (_isFadingIn) {
      return Text(
        "Fading In",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      );
    } else if (_isNightMode) {
      return Text(
        "Night Mode",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      );
    } else if (_isTransitioning) {
      return Text(
        "Transitioning",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      );
    } else if (_isFadingOut) {
      return Text(
        "Fading Out",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      );
    } else {
      return Text(
        "OFF",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      );
    }
  }

  Color _buildColor() {
    if (_isFadingIn) {
      return sleepColorSaved.withAlpha(128);
    } else if (_isNightMode) {
      print(sleepColorSaved);
      return sleepColorSaved;
    } else if (_isTransitioning) {
      return sleepColorSaved.withAlpha(128);
    } else if (_isFadingOut) {
      return wakeColorSaved;
    } else {
      return Colors.grey.shade300;
    }
  }

  void updateVals() {
    setState(() {
      widget.fadeOut =
          min(widget.fadeOut, min(120, max((limitFade() - widget.fadeIn), 0)));
      widget.fadeIn =
          min(widget.fadeIn, min(120, max((limitFade() - widget.fadeOut), 0)));
      widget.transitionTime = min(widget.transitionTime, limitTrans());
    });
  }

  double _calculateProgress() {
    if (widget._startTimeSaved == null || widget._endTimeSaved == null) {
      return 0.0;
    }

    DateTime now = DateTime.now();
    DateTime startTime = DateTime(now.year, now.month, now.day,
        widget._startTimeSaved!.hour, widget._startTimeSaved!.minute);
    DateTime startTimeWithFadeIn = DateTime(now.year, now.month, now.day,
            widget._startTimeSaved!.hour, widget._startTimeSaved!.minute)
        .subtract(Duration(minutes: widget.fadeInSaved));
    if (!startTimeWithFadeIn.isAfter(startTime))
      startTimeWithFadeIn = startTimeWithFadeIn.add(Duration(days: 1));

    DateTime endTimeWithFadeOut = DateTime(now.year, now.month, now.day,
            widget._endTimeSaved!.hour, widget._endTimeSaved!.minute)
        .add(Duration(minutes: widget.fadeOutSaved));

    while (!now.isAfter(startTimeWithFadeIn)) now = now.add(Duration(days: 1));
    while (!endTimeWithFadeOut.isAfter(startTimeWithFadeIn)) {
      endTimeWithFadeOut = endTimeWithFadeOut.add(Duration(days: 1));
    }

    //print(startTimeWithFadeIn);
    //print(endTimeWithFadeOut);

    Duration totalDuration =
        startTimeWithFadeIn.difference(endTimeWithFadeOut).abs();
    //print(totalDuration);
    Duration elapsedTime = now.difference(startTimeWithFadeIn).abs();
    double progress = elapsedTime.inMilliseconds / totalDuration.inMilliseconds;
    //print(elapsedTime);

    // Ensure progress is between 0 and 1
    progress = progress.clamp(0.0, 1.0);

    //print(progress);

    return progress;
  }

  void _showTimePicker(bool setStart) {
    showTimePicker(
      context: context,
      initialTime: setStart
          ? (widget._startTime ?? TimeOfDay.now())
          : (widget._endTime ?? TimeOfDay.now()),
    ).then((value) {
      setState(() {
        if (value != null) {
          if (setStart)
            widget._startTime = value!;
          else
            widget._endTime = value!;
          updateVals();
        }
      });
    });
  }

  int limitTrans() {
    // Convert string times to DateTime objects
    if (widget._startTime == null || widget._endTime == null) return 0;
    int startTimeInMinutes =
        widget._startTime!.hour * 60 + widget._startTime!.minute;
    int endTimeInMinutes = widget._endTime!.hour * 60 + widget._endTime!.minute;

    // Calculate available time for the light to be on
    int availableTime = (startTimeInMinutes > endTimeInMinutes)
        ? 24 * 60 - (startTimeInMinutes - endTimeInMinutes)
        : endTimeInMinutes - startTimeInMinutes;

    // Calculate maximum allowed rise time and fade time (capped at 10 minutes)
    return (availableTime.clamp(0, 120) ~/ 10) * 10;
  }

  int limitDelay() {
    return 120;
  }

  int limitFade() {
    // Convert string times to DateTime objects
    if (widget._startTime == null || widget._endTime == null) return 0;
    int startTimeInMinutes =
        widget._startTime!.hour * 60 + widget._startTime!.minute;
    int endTimeInMinutes = widget._endTime!.hour * 60 + widget._endTime!.minute;

    // Calculate available time for the light to be on
    int availableTime = (startTimeInMinutes > endTimeInMinutes)
        ? (startTimeInMinutes - endTimeInMinutes)
        : 24 * 60 - (startTimeInMinutes - endTimeInMinutes);

    // Calculate maximum allowed rise time and fade time (capped at 10 minutes)
    return (availableTime.clamp(0, 240) ~/ 10) * 10;
  }

  void _loadTimeSettings() async {
    widget.isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int startHour = prefs.getInt('startHour') ?? 21;
    int startMinute = prefs.getInt('startMinute') ?? 0;
    int endHour = prefs.getInt('endHour') ?? 7;
    int endMinute = prefs.getInt('endMinute') ?? 0;

    setState(() {
      widget._startTime = TimeOfDay(hour: startHour, minute: startMinute);
      widget._endTime = TimeOfDay(hour: endHour, minute: endMinute);
      widget.delayTime = prefs.getInt('delayTime') ?? 110;
      widget.fadeOut = prefs.getInt('fadeOut') ?? 60;
      widget.fadeIn = prefs.getInt('fadeIn') ?? 10;
      widget.transitionTime = prefs.getInt('transitionTime') ?? 30;
      widget.isLoading = false;
    });
  }

  void _loadSavedTimeSettings() async {
    widget.isLoading = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int startHour = prefs.getInt('startHour') ?? TimeOfDay.now().hour;
    int startMinute = prefs.getInt('startMinute') ?? TimeOfDay.now().minute;
    int endHour = prefs.getInt('endHour') ?? TimeOfDay.now().hour;
    int endMinute = prefs.getInt('endMinute') ?? TimeOfDay.now().minute;

    setState(() {
      widget._startTimeSaved = TimeOfDay(hour: startHour, minute: startMinute);
      widget._endTimeSaved = TimeOfDay(hour: endHour, minute: endMinute);
      widget.delayTimeSaved = prefs.getInt('delayTime') ?? 0;
      widget.fadeOutSaved = prefs.getInt('fadeOut') ?? 0;
      widget.fadeInSaved = prefs.getInt('fadeIn') ?? 0;
      widget.transitionTimeSaved = prefs.getInt('transitionTime') ?? 0;
      sleepColorSaved = Color(prefs.getInt('sleepColor') ?? Colors.blue.value);
      wakeColorSaved = Color(prefs.getInt('wakeColor') ?? Colors.blue.value);
      widget.isLoading = false;
    });
  }

  void _saveTimeSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('startHour', widget._startTime!.hour);
    prefs.setInt('startMinute', widget._startTime!.minute);
    prefs.setInt('endHour', widget._endTime!.hour);
    prefs.setInt('endMinute', widget._endTime!.minute);
    prefs.setInt('delayTime', widget.delayTime);
    prefs.setInt('fadeOut', widget.fadeOut);
    prefs.setInt('fadeIn', widget.fadeIn);
    prefs.setInt('transitionTime', widget.transitionTime);
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Instructions"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1. Set sleep and wake up times for the night light.\n"
                "2. Set motion delay time,transition time, fade in time, and fade out time (in minutes) as desired.\n"
                "2. Checkout the time graph for more details\n"
                "3. Press 'Save Changes' to save the settings.",
              ),
            ],
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

  void _showRadarInstruction() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Placement Instructions"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1. Height: Place the LD2410C about 120 cm high for best results.\n"
                "2. Mounting: It can be hung from the ceiling or attached to a wall.\n"
                "3. Clear View: Ensure the sensor has a clear view of the area you want to monitor, without obstructions.\n"
                "4. Angle: Position it to cover the space you need, using its wide detection angle of ±60 degrees.\n"
                "5. Good Environment: Place it in a spot protected from dust, moisture, and direct sunlight for better performance.\n",
              ),
            ],
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

  void _showGraph() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          title: Text("Time Graph"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetZoom(
                heroAnimationTag: 'tag',
                zoomWidget: Image.asset(
                  'assets/graph.jpg',
                  width: 500,
                  height: 200,
                ),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal.shade800,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Night Light',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Text("Choose Time Settings",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                        //SizedBox(width: 30,),
                        IconButton(
                          icon: Icon(Icons.auto_graph_outlined),
                          onPressed: () {
                            _showGraph();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.help),
                          onPressed: () {
                            _showInstructions();
                          },
                        ),

                        IconButton(
                          icon: Icon(Icons.bed),
                          onPressed: () {
                            _showRadarInstruction();
                          },
                        ),
                      ],
                    ),
                    // SizedBox(height: 20,),
                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal.shade800),
                        child: Icon(
                          Icons.bedtime_rounded,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Sleep Time',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: OutlinedButton(
                        onPressed: () => _showTimePicker(true),
                        child: Text.rich(
                          TextSpan(
                            text: (widget._startTime != null
                                ? widget._startTime!.format(context)
                                : TimeOfDay.now().format(context)),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 25,
                    ),
                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal.shade800),
                        child: Icon(
                          Icons.sunny,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Wake Up Time',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: OutlinedButton(
                        onPressed: () => _showTimePicker(false),
                        child: Text.rich(
                          TextSpan(
                            text: (widget._endTime != null
                                ? widget._endTime!.format(context)
                                : TimeOfDay.now().format(context)),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),

                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal.shade800),
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Fade In',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: DropdownButton<int>(
                          value: min(widget.fadeIn,
                              min(120, max((limitFade() - widget.fadeOut), 0))),
                          onChanged: (int? newValue) {
                            setState(() {
                              widget.fadeIn = newValue!;
                            });
                            updateVals();
                          },
                          items: List.generate(
                            min(
                                13,
                                max(((limitFade() - widget.fadeOut) ~/ 10) + 1,
                                    1)),
                            (index) {
                              return DropdownMenuItem<int>(
                                value: index * 10,
                                child: Row(
                                  children: [
                                    Text('${index * 10}'), 
                                    SizedBox(
                                        width:
                                            4), 
                                    Text('min'),
                                  ],
                                ),
                              );
                            },
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                          dropdownColor: Colors.white,
                          elevation: 4,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24.0,
                          isDense: true,
                          underline: Container(
                            height: 2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),

                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal.shade800),
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Fade Out',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: DropdownButton<int>(
                          value: min(widget.fadeOut,
                              min(120, max((limitFade() - widget.fadeIn), 0))),
                          onChanged: (int? newValue) {
                            setState(() {
                              widget.fadeOut = newValue!;
                            });
                            updateVals();
                          },
                          items: List.generate(
                            min(
                                13,
                                max(((limitFade() - widget.fadeIn) ~/ 10) + 1,
                                    1)),
                            (index) {
                              return DropdownMenuItem<int>(
                                value: index * 10,
                                child: Row(
                                  children: [
                                    Text('${index * 10}'),
                                    SizedBox(
                                        width:
                                            4),
                                    Text('min'),
                                  ],
                                ),
                              );
                            },
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                          dropdownColor: Colors.white,
                          elevation: 4,
                          iconSize: 24.0,
                          isDense: true,
                          underline: Container(
                            height: 2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.teal.shade800),
                        child: Icon(
                          Icons.transform_rounded,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Transition Time',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Alef',
                        ),
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: DropdownButton<int>(
                          value: min(widget.transitionTime, limitTrans()),
                          onChanged: (int? newValue) {
                            setState(() {
                              widget.transitionTime = newValue!;
                            });
                          },
                          items: List.generate(
                            (limitTrans() ~/ 10) + 1,
                            (index) {
                              return DropdownMenuItem<int>(
                                value: index * 10,
                                child: Row(
                                  children: [
                                    Text('${index * 10}'),
                                    SizedBox(
                                        width:
                                            4),
                                    Text('min'),
                                  ],
                                ),
                              );
                            },
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                          dropdownColor: Colors.white,
                          elevation: 4,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24.0,
                          isDense: true,
                          underline: Container(
                            height: 2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal.shade800,
                        ),
                        child: Icon(
                          Icons.directions_walk,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Motion Delay Time',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Alef',
                        ),
                      ),
                      trailing: SizedBox(
                        width:
                            100, 
                        child: DropdownButton<int>(
                          value: widget.delayTime,
                          onChanged: (int? newValue) {
                            setState(() {
                              widget.delayTime = newValue!;
                            });
                          },
                          items: List.generate(
                            (limitDelay() ~/ 10) + 1,
                            (index) {
                              return DropdownMenuItem<int>(
                                value: index * 10,
                                child: Row(
                                  children: [
                                    Text('${index * 10}'),
                                    SizedBox(
                                        width:
                                            4),
                                    Text('sec'),
                                  ],
                                ),
                              );
                            },
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                          dropdownColor: Colors.white,
                          elevation: 4,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24.0,
                          isDense: true,
                          underline: Container(
                            height: 2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        _saveTimeSettings();
                        _loadSavedTimeSettings();
                        setState(() {
                          _progress = _calculateProgress();
                        });
                        var start = widget._startTime ?? TimeOfDay.now();
                        var end = widget._endTime ?? TimeOfDay.now();
                        var data =
                            '${start.hour}+${start.minute}+${end.hour}+${end.minute}+${widget.fadeOut}+${widget.fadeIn}+${widget.delayTime}+${widget.transitionTime}';
                        writeDataWithCharacteristic(
                            widget.c_uid, data, context);
                        Widget okButton = TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        );
                        AlertDialog alert = AlertDialog(
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Time Cycle Settings Changed",
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            okButton,
                          ],
                        );

                        print(widget.transitionTime);
                        print(widget.delayTime);
                        print(widget.fadeIn);
                        print(widget.fadeOut);

                        print(widget.transitionTimeSaved);
                        print(widget.delayTimeSaved);
                        print(widget.fadeInSaved);
                        print(widget.fadeOutSaved);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade800,
                        minimumSize: Size(300, 40),
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 30),
                    CircularPercentIndicator(
                      radius: 100.0,
                      animation: true,
                      animateFromLastPercent: true,
                      animationDuration: 2000,
                      lineWidth: 15.0,
                      percent: _progress,
                      center: _buildCenterText(),
                      circularStrokeCap: CircularStrokeCap.butt,
                      backgroundColor: Colors.grey.shade300,
                      progressColor: _buildColor(),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
        ),
      ),
    );
  }
}