import 'dart:io';
import 'package:ambience/models/weather_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ambience/handlers/file_handler.dart';
import 'package:ambience/handlers/wallpaper_handler.dart';
import 'package:ambience/weatherEntry/weather_entry.dart';
import 'package:flutter/material.dart';
import 'package:ambience/api/weather.dart';
import "package:ambience/daemon/daemon.dart";
import 'package:ambience/firebase/fire_handler.dart';

void main(List<String> args) async {
  await dotenv.load();
  FireHandler.initialize();
  TimeOfDay time = const TimeOfDay(hour: 23, minute: 45);
  DayOfWeek dow = DayOfWeek.tuesday;
  WeatherCondition wc = WeatherCondition.Clouds;
  String curr = Directory.current.path;
  String testPaper = "$curr/test.jpg";
  String city = 'New York';
  WeatherEntry mockObj = WeatherEntry(time, dow, testPaper, wc, city);

  //if not args passed, GUI MODE
  if (args.isEmpty) {
    runApp(const MyApp());
  }
  //if there are command line args, GUI-Less mode
  else {
    //boot daemon case
    if (args[0] == 'boot') {
      Daemon.bootWork();
    } else {
      String idSchema = args[1];
      var ruleObj = await WeatherEntry.getRule(idSchema);
      WeatherModel weatherData = await Daemon.getWeatherData(ruleObj);
      Daemon.weatherCheck(ruleObj, weatherData);
    }
    //explict exit, else Windows task scheduler will never know the task ended
    exit(0);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _input = "";

  void _pickFile() async {
    // An alternative approach can be the following
    /* 
    String pathToFile = await getImagePathFromPicker();
    if (pathToFile.isNotEmpty) {
      setState(() {
        _input = pathToFile;
      });
    }
    */
    // And we get rid of exceptions
    String pathToFile = "";
    try {
      pathToFile = await getImagePathFromPicker();
    } on NoFileChosenException {
      debugPrint("No files chosen");
    } on FileNotFoundException {
      debugPrint("No path was found for the given file");
    } finally {
      setState(() {
        _input = pathToFile;
      });
    }
  }

  void _setWallpaper() async => await WallpaperHandler.setWallpaper(_input);

  @override
  Widget build(BuildContext context) {
    String? cityInput;
    //mock object for testing
    //==========================
    TimeOfDay time = const TimeOfDay(hour: 23, minute: 45);
    DayOfWeek dow = DayOfWeek.tuesday;
    WeatherCondition wc = WeatherCondition.Clouds;
    String curr = Directory.current.path;
    String testPaper = "$curr/test.jpg";
    String city = 'New York';
    WeatherEntry mockObj = WeatherEntry(time, dow, testPaper, wc, city);
    //===========================

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //weather api text field
            // ignore: prefer_const_constructors
            TextField(
              // ignore: prefer_const_constructors
              decoration: InputDecoration(
                // ignore: prefer_const_constructors
                border: OutlineInputBorder(),
                labelText: 'enter email',
              ),
              onChanged: (text) {
                cityInput = text;
              },
            ),
            TextField(
              // ignore: prefer_const_constructors
              decoration: InputDecoration(
                // ignore: prefer_const_constructors
                border: OutlineInputBorder(),
                labelText: 'Enter password',
              ),
              onChanged: (text) {
                cityInput = text;
              },
            ),
            TextField(
              // ignore: prefer_const_constructors
              decoration: InputDecoration(
                // ignore: prefer_const_constructors
                border: OutlineInputBorder(),
                hintText: 'Enter city name to get weather for',
              ),
              onChanged: (text) {
                cityInput = text;
              },
            ),
            ElevatedButton(
                onPressed: () => weather(cityInput),
                child: const Text("Get weather")),
            ElevatedButton(
                onPressed: () => Daemon.daemonSpawner(mockObj),
                child: const Text("Demon Mock Obj Test")),
            //open file
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text("Open File"),
            ),
            ElevatedButton(
              onPressed: () => Daemon.daemonBanisher(mockObj.idSchema),
              child: const Text("banish thy daemon"),
            ),
            if (_input.isNotEmpty) Text("Path to file is $_input"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _setWallpaper,
        tooltip: 'Set Wallpaper',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
