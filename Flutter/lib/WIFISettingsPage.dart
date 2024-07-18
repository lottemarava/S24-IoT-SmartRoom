import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:nightlight/main.dart';
import 'HomePage.dart';
import 'NavigateToBluetooth.dart';
import 'package:provider/provider.dart';


class WIFISettingsPage extends StatefulWidget {
  WIFISettingsPage(this.c_uid, {super.key});
  late String c_uid;
  String password='';
  String ssid = '';
  @override
  State<WIFISettingsPage> createState() => _WIFISettingsPageState();
}

Future<int> receiveDataFromESP(String UUID, int count) async {
  BluetoothCharacteristic? ch = characteristicDictionary[UUID];
  if (ch == null) {
    return -1;
  }
  if(count == 25)
    return -1;
  int x = -1;
  try {
    await ch.setNotifyValue(true);
  }
  catch (err) {
    if (err.toString().contains("no instance of BluetoothGatt")) {
      return -100;
    }
    x = -1;
  }
  ch.value.listen((value) {
    if (value.isNotEmpty) {
      x = value[0];
    }
  });
  //print(x);
  await Future.delayed(const Duration(milliseconds: 500));
  if (x == -1) {
    return await receiveDataFromESP(UUID, count + 1);
  }
  return x;
}

class _WIFISettingsPageState extends State<WIFISettingsPage> {

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Instructions"),
          content: Text(
            "1. Enter WiFi Network Name and Password\n"
                "2. Press on \"Connect to Wifi\" to connect\n"
                "3. *If configuring Time fails a message will pop up that asks you if you want to configure it with the phone's time",
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
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: Colors.teal.shade800,
        title: Text('Night Light',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold, color: Colors.white

            )),
      ),
      body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Center(
        child:
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.help),
                  onPressed: () {
                    _showInstructions();
                  },
                ),
              ],
            ),
            SizedBox(height: 200,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SSID',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 250.0, 
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.ssid = value;
                      });

                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),

                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Password',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 250.0, 
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        widget.password = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), 
                    ),
                    obscureText: true, 

                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(onPressed: () async {
              var data = '${widget.ssid}+${widget.password}';
              writeDataWithCharacteristic(widget.c_uid,data,context);
              showDialog(context: context, builder: (context) {
                Future.delayed(const Duration(seconds: 10), () async {
                  return -10;
                });
                return PopScope(child: Center(child: CircularProgressIndicator()),
                  canPop: false,
                  onPopInvoked: (bool didPop) {
                    return;
                  },);
              },);
              int x = await receiveDataFromESP("be31c4e4-c3f7-4b6f-83b3-d9421988d355", 0);
              if(x == 0)
              {
                Navigator.of(context).pop();
                  // set up the button
                showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: Row(
                            children: [
                              Icon(Icons.cancel,color: Colors.red,), 
                              SizedBox(width: 8), 
                              Text("Connection Failed",style: TextStyle(fontSize: 20,)),
                            ]
                        ),
                        content: const Text("Do you Want to configure time with phone clock instead?"),
                        actions: <Widget> [
                          TextButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, child: const Text("No")),
                          TextButton(onPressed: (){
                            var data = '${TimeOfDay.now().hour}+${TimeOfDay.now().minute}+${0},${DateTime.now().day}+${DateTime.now().month}+${DateTime.now().year}';
                            writeDataWithCharacteristic("6d6fb840-ed2b-438f-8375-9220a5164be8", data, context);
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                      children: [
                                        Icon(Icons.check_circle,color: Colors.green,), 
                                        SizedBox(width: 8), 
                                        Text("Time Configured",style: TextStyle(fontSize: 20,)),
                                      ]
                                  ),
                                  content: Text(
                                    "",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        context.read<myProvider>().updateTimeManConfigured(true);
                                        //manually_configured = true;
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          }, child: const Text("Yes")),
                        ],);
                    });
              }
              else if (x == 1)
              {
                Navigator.of(context).pop();
                  Widget okButton = TextButton(
                    child: Text("OK"),
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                  );
                  AlertDialog alert = AlertDialog(
                    title:  Row(
                        children: [
                          Icon(Icons.warning,color: Colors.yellow,), 
                          SizedBox(width: 8), 
                          Text("Connection Failed",style: TextStyle(fontSize: 20,)),
                        ]
                    ),
                    content: Text("Time is already configured"),
                    actions: [
                      okButton,
                    ],
                  );

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );
              }
              else if(x == 2)
              {
                context.read<myProvider>().updateWiFiStatus(true);
                //wifi_connected = true;
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title:  Row(
                            children: [
                              Icon(Icons.warning,color: Colors.yellow.shade200), 
                              SizedBox(width: 5), 
                              Text("Connection Succeeded \nbut failed to configure\ntime",style: TextStyle(fontSize: 20,),),
                            ]
                        ),
                        content: const Text("Do you Want to configure time with phone clock instead?"),
                        actions: <Widget> [
                          TextButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, child: const Text("No")),
                          TextButton(onPressed: (){
                            var data = '${TimeOfDay.now().hour}+${TimeOfDay.now().minute}+${0},${DateTime.now().day}+${DateTime.now().month}+${DateTime.now().year}';
                            writeDataWithCharacteristic("6d6fb840-ed2b-438f-8375-9220a5164be8", data, context);
                            Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title:  Row(
                                        children: [
                                          Icon(Icons.check_circle,color: Colors.green,), 
                                          SizedBox(width: 8),
                                          Text("Time Configured",style: TextStyle(fontSize: 20,)),
                                        ]
                                    ),
                                    content: Text(
                                      "",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          context.read<myProvider>().updateTimeManConfigured(true);
                                          //manually_configured = true;
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                          }, child: const Text("Yes")),
                        ],);
                    });
              }
              else if (x == 3)
              {
                //wifi_connected = true;
                //configured = true;
                context.read<myProvider>().updateWiFiStatus(true);
                context.read<myProvider>().updateTimeConfigured(true);
                Navigator.of(context).pop();
                // set up the button
                Widget okButton = TextButton(
                  child: Text("OK"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                );

                AlertDialog alert = AlertDialog(
                  title:  Row(
                      children: [
                        Icon(Icons.check_circle,color: Colors.green,), // Add an icon if you want
                        SizedBox(width: 8), // Add some space between the icon and text
                        Text("Connection Succeeded",style: TextStyle(fontSize: 20,)),
                      ]
                  ),
                  content: Text("Time Configured"),
                  actions: [
                    okButton,
                  ],
                );

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              }
              else if (x == 5)
              {
                Navigator.of(context).pop();
                Widget okButton = TextButton(
                  child: Text("OK"),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                );

                AlertDialog alert = AlertDialog(
                  title: Row(
                      children: [
                        Icon(Icons.warning,color: Colors.yellow.shade200),
                        SizedBox(width: 8),
                        Text("Connection Failed",style: TextStyle(fontSize: 20,)),
                      ]
                  ),
                  content: Text("Time is already configured"),
                  actions: [
                    okButton,
                  ],
                );

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              }
              else if(x == -100)
              {
                Navigator.of(context).pop();
                  Widget okButton = TextButton(
                    child: Text("OK"),
                    onPressed: () { Navigator.of(context).pop();popup=false;
                    targetDevice.disconnect();
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) =>BluetoothButtonPage())
                    );},
                  );

                  AlertDialog alert = AlertDialog(
                    title: Row(
                        children: [
                          Icon(Icons.cancel,color: Colors.red), // Add an icon if you want
                          SizedBox(width: 8), // Add some space between the icon and text
                          Text("Bluetooth Disconnected",style: TextStyle(fontSize: 20,)),
                        ]
                    ),
                    content: Text("Connect to Bluetooth again"),
                    actions: [
                      okButton,
                    ],
                  );

                popup = true;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );
              }
              else
              {
                Navigator.of(context).pop();
                  Widget okButton = TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();popup=false;
                      },

                  );

                  AlertDialog alert = AlertDialog(
                    title:
                    Row(
                        children: [
                          Icon(Icons.cancel,color: Colors.red,),
                          SizedBox(width: 8),
                          Text("Unexpected Error",style: TextStyle(fontSize: 20,)),
                        ]
                    ),
                    content: Text("Try Connecting again"),
                    actions: [
                      okButton,
                    ],
                  );

                popup = true;
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return alert;
                    },
                  );
              }
              //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SeekWifiMessage()));
            }, style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade800,
              minimumSize: Size(200, 40),
            ),
                child: Text('Connect to Wifi',style: TextStyle(color: Colors.white),))
          ],
        ),
      )),
    );
  }

  void _configuredmessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Time Configured"),
          content: Text(
            "",
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



}
