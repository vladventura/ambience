// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, sort_child_properties_last, unused_import


import 'dart:async';
import 'dart:math';

import 'package:ambience/GUI/create.dart';
import 'package:ambience/GUI/list.dart';
import 'package:flutter/material.dart';
import "package:ambience/GUI/wallpaperobj.dart";
import 'dart:io';

void main() => runApp(const MainApp());

String current = Directory.current.path;

Widget checkWallpaper() {
  String currentFile = ""; // current wallpaper function goes here

  // ignore: dead_code, dart's just being a baby
  if (File(currentFile).existsSync()) {
    return Expanded(
      child: Image.file(
        File(currentFile),
        fit: BoxFit.fitHeight,
      ), // placeholder, retrieve wallpaper image here
    );
  } else {
    return Container(
      child: const Text("\t No wallpaper currently displayed \t"),
    );
  }
}

String checkTime() { // copy and slightly edit this to convert to regular time
  final now = DateTime.now();
  String hour = (now.hour % 12).toString();
  String minute = now.minute.toString();
  minute = minute.length > 1 ? minute : "0$minute";
  String amPm = now.hour % 12 > 0 ? "AM" : "PM";
  String fmt = "$hour:$minute $amPm";
  return fmt;
}

// function to send new location data to backend,
// is called when location drop menu is changed.

//only ONE location is used for every WeatherEntry

void setLocation(String location) {
  // may not be string, just a placeholder for now

  // send location data to backend here

  // push location screen here
}

String getLocation() {
  // retrieve the current location here
// may not be final
  String location = "placeholder location";

  return location;
}

class TimeDisplay extends StatefulWidget {
  const TimeDisplay({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TimeDisplayState createState() => _TimeDisplayState();
}

class _TimeDisplayState extends State<TimeDisplay> {
  String _currentTime = checkTime();
  void updateTime() {
    setState(() {
      _currentTime = checkTime();
    });
  }

  @override
  void initState() {
    // update time every minute
    Timer.periodic(Duration(minutes: 1), (timer) {
      updateTime();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_currentTime);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget weatherSection = Container(
        padding: const EdgeInsets.all(32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.sunny,
                    size: 80,
                    color: Colors
                        .amber), // placeholder, attach function to icon to change based on weather
                TimeDisplay(),
                const Text("Boston, MA"), // placeholder, drop menu goes here
              ],
            ),
          ],
        ));

    Widget wallpaperSection = Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.only(left: 32)),
          checkWallpaper(),
          Padding(padding: EdgeInsets.only(right: 32)),
        ],
      ),
    );

    Widget buttonMenu = Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: null, //function to close program
            child: const Text("Quit"),
            style: ButtonStyle(
              padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
              backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
              side: MaterialStatePropertyAll<BorderSide>(
                BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
          Spacer(),
          OutlinedButton(
            onPressed: () {
              //function here to switch to list screen
              Navigator.pushNamed(context, '/List');
            },
            child: const Text("List"),
            style: ButtonStyle(
              padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
              backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
              side: MaterialStatePropertyAll<BorderSide>(
                BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
          Spacer(),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateApp(
                          contextWallpaper: WallpaperObj(),
                          intention: 1,
                          location: getLocation())));
            }, //function here to switch to create screen
            child: const Text("Create"),
            style: ButtonStyle(
              padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
              backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
              side: MaterialStatePropertyAll<BorderSide>(
                BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
        ],
      ),
    );

    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            weatherSection,
            wallpaperSection,
            buttonMenu,
          ],
        ),
      ),
    );
  }
}
