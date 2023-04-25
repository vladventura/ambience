import 'package:ambience/GUI/create.dart';
import 'package:ambience/GUI/list.dart';
import 'package:ambience/firebase/fire_handler.dart';
import 'package:ambience/models/location_model.dart';
import 'package:ambience/providers/location_provider.dart';
import 'package:flutter/material.dart';
import "package:ambience/GUI/wallpaperobj.dart";
import 'dart:io';
import "dart:async";

import 'package:provider/provider.dart';

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
    return const Text("\t No wallpaper currently displayed \t");
  }
}

String checkTime() {
  // copy and slightly edit this to convert to regular time
  final now = DateTime.now();
  String hour = (now.hour % 12).toString();
  String minute = now.minute.toString();
  minute = minute.length > 1 ? minute : "0$minute";
  String amPm = now.hour >= 12 ? "PM" : "AM";
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

class FloatingDrawerButton extends StatelessWidget {
  const FloatingDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: FloatingActionButton(
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        child: const Icon(Icons.more_vert),
      ),
    );
  }
}

class CityHeader extends StatelessWidget {
  const CityHeader({super.key});

  @override
  Widget build(BuildContext context) {
    LocationModel? currentLocation = context.read<LocationProvider>().location;
    String message = "No location information set";

    if (currentLocation != null) {
      String head = currentLocation.name;
      String tail = currentLocation.country == "US"
          ? currentLocation.state!
          : currentLocation.country;
      message = "$head, $tail";
    }

    return Text(message);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Widget wallpaperSection() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 32),
          ),
          checkWallpaper(),
          const Padding(
            padding: EdgeInsets.only(right: 32),
          ),
        ],
      ),
    );
  }

  Widget weatherSection() {
    return Container(
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
                      .black45), // placeholder, attach function to icon to change based on weather
              Text(
                checkTime(), // (TimeOfDay(hour: 12, minute: 02) !!! SCHEDULE TO UPDATE TIME EVERY MINUTE THROUGH A FUNCTION CALL !!!
                style: const TextStyle(fontWeight: FontWeight.bold),
              ), // placeholder, attach function to retrieve time
              const CityHeader(), // placeholder, drop menu goes here
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle({
    MaterialStatePropertyAll<EdgeInsets> padding =
        const MaterialStatePropertyAll<EdgeInsets>(
      EdgeInsets.all(32),
    ),
    MaterialStatePropertyAll<Color> backgroundColor =
        const MaterialStatePropertyAll<Color>(Colors.white),
    MaterialStatePropertyAll<BorderSide> side =
        const MaterialStatePropertyAll<BorderSide>(
      BorderSide(color: Colors.black, width: 2),
    ),
  }) {
    return ButtonStyle(
      padding: padding,
      backgroundColor: backgroundColor,
      side: side,
    );
  }

  Widget buttonMenu(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: null, //function to close program
            style: _buttonStyle(),
            child: const Text("Quit"),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () {
              //function here to switch to list screen
              Navigator.pushNamed(context, '/List');
            },
            style: _buttonStyle(),
            child: const Text("List"),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateApp(
                    contextWallpaper: WallpaperObj(context.read<LocationProvider>().location?.id ?? 4930956),
                    intention: 1,
                    location: getLocation(),
                  ),
                ),
              );
            }, //function here to switch to create screen
            style: _buttonStyle(),
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Inside main screen");
    debugPrint(context.read<LocationProvider>().location?.toJson().toString());

    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            weatherSection(),
            wallpaperSection(),
            buttonMenu(context),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: const FloatingDrawerButton(),
        drawer: Drawer(
          child: Column(
            children: [
              const DrawerHeader(
                child: Text("Ambience"),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text("Reset Location"),
                      onTap: () {
                        Navigator.of(context).pushNamed('/LocationRequest');
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text("Log out"),
                onTap: () {
                  FireHandler hand = FireHandler();
                  //hand.fireSignOut();
                  Navigator.of(context).pushNamed('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
