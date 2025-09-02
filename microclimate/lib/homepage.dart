import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'image_and_icons.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic> sensorData = {
    'temp': '--',
    'humidity': '--',
    'ldr': '--',
    'soil': '--',
  };
  bool fanOn = false;
  bool mistOn = false;
  bool shadeOn = false;
  String espUrl = 'http://192.168.4.1';
  //stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;

  Future<void> fetchSensorData() async {
    try {
      final response = await http
          .get(Uri.parse('$espUrl/sensors'))
          .timeout(Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => sensorData = data);
      }
    } catch (e) {
      print("Failed to fetch sensor data: $e");
    }
  }

  Future<void> sendControl(String device, String state) async {
    try {
      await http
          .post(Uri.parse('$espUrl/control'), body: {device: state})
          .timeout(Duration(seconds: 3));
    } catch (e) {
      print("Failed to send control: $e");
    }
  }

  Future<void> processVoiceCommand(String command) async {
    command = command.toLowerCase();
    if (command.contains("fan on")) {
      await sendControl('fan', 'on');
    } else if (command.contains("fan off") || command.contains("fan of")) {
      await sendControl('fan', 'off');
    } else if (command.contains("mist on") || command.contains("miss on")) {
      await sendControl('mist', 'on');
    } else if (command.contains("mist off") ||
        command.contains("miss off") ||
        command.contains("mist of") ||
        command.contains("miss of")) {
      await sendControl('mist', 'off');
    } else if (command.contains("shade on")) {
      await sendControl('shade', '90');
    } else if (command.contains("shade off") || command.contains("shade of")) {
      await sendControl('shade', '0');
    } else {
      print("Unrecognized command: $command");
    }
  }

  static const platform = MethodChannel('speech.recognition');

  void startListening() async {
    try {
      setState(() => isListening = true);
      final String result = await platform.invokeMethod('startListening');
      await processVoiceCommand(result);
    } catch (e) {
      print("Voice error: $e");
    } finally {
      setState(() => isListening = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSensorData();
    Timer.periodic(Duration(seconds: 10), (_) => fetchSensorData());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 8,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade400, Colors.green.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Microclimate Dashboard',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              ImageAndIcons(
                size: size,
                temp: sensorData['temp'].toString(),
                humidity: sensorData['humidity'].toString(),
                ldr: sensorData['ldr'].toString(),
                soil: sensorData['soil'].toString(),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Fan'),
                      secondary: Icon(Icons.wind_power),
                      value: fanOn,
                      activeColor: Colors.green,
                      onChanged: (val) {
                        setState(() => fanOn = val);
                        sendControl('fan', val ? 'on' : 'off');
                      },
                    ),
                    SwitchListTile(
                      title: Text('Mist'),
                      secondary: Icon(Icons.grain),
                      value: mistOn,
                      activeColor: Colors.green,
                      onChanged: (val) {
                        setState(() => mistOn = val);
                        sendControl('mist', val ? 'on' : 'off');
                      },
                    ),
                    SwitchListTile(
                      title: Text('Shade'),
                      secondary: Icon(Icons.window),
                      value: shadeOn,
                      activeColor: Colors.green,
                      onChanged: (val) {
                        setState(() => shadeOn = val);
                        sendControl('shade', val ? '90' : '0');
                      },
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Spacer(),
                  Text(
                    isListening ? "Listening..." : "Tap to Speak",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    iconSize: 30,
                    icon: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: isListening ? Colors.red : Colors.green,
                    ),
                    onPressed: isListening
                        ? () {
                            setState(() {
                              isListening = false;
                            });
                          }
                        : startListening,
                  ),
                  Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
