import 'package:ambience/GUI/create.dart';
import 'package:ambience/api/weather.dart';
import 'package:ambience/handlers/wallpaper_handler.dart';
import 'package:ambience/models/location_model.dart';
import 'package:ambience/providers/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:ambience/GUI/wallpaperobj.dart";
import 'dart:io';
import "dart:async";
import "package:ambience/constants.dart";
import "package:ambience/utils.dart";

import 'package:provider/provider.dart';

void main() => runApp(const MainApp());

String current = Directory.current.path;

Widget checkWallpaper() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return const Text("\tCurrent wallpaper not available on Android!");
  }
  return FutureBuilder(
    future: WallpaperHandler.getCurrentWallpaperPath(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Text("\tLoading current wallpaper...");
      } else if (snapshot.data != null) {
        File f = snapshot.data!;
        debugPrint(f.path);
        if (f.existsSync()) {
          return Expanded(
            child: Image.file(
              f,
              fit: BoxFit.fitHeight,
            ),
          );
        }
      }
      return const Text("\tFailed to find current wallpaper!\t");
    },
  );
}

String checkTime() {
  // copy and slightly edit this to convert to regular time
  final now = DateTime.now();
  String hour = (now.hour % 12).toString();
  if (now.hour == 12 || now.hour == 24) {
    hour = "12";
  }
  String minute = now.minute.toString();
  minute = minute.length > 1 ? minute : "0$minute";
  String amPm = now.hour >= 12 ? "PM" : "AM";
  String fmt = "$hour:$minute $amPm";
  return fmt;
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
    Timer.periodic(const Duration(minutes: 1), (timer) {
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
      child: Tooltip(
        message: locationToolTip,
        child: FloatingActionButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          child: const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}

class _CityHeader extends StatelessWidget {
  const _CityHeader();

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

  Future<IconData> getCurrentWeather() async {

    Map<String, dynamic> json =
        await weatherNow(await Utils.loadFromLocationFile());
    //error exit early
    if(json.isEmpty){
      return Icons.question_mark; 
    }
    // in the form of a (city?)
    String mainWeather = json['weather'][0]['main'];
    // debugPrint(stringToIcon[json['weather'][0]['main'].toString()].toString());

    if (stringToIcon.containsKey(mainWeather)) {
      return stringToIcon[mainWeather]!;
    } // in the event that the current weather is something we aren't prepared for (such as ash or tornado)
    return Icons.question_mark;
  }

  ButtonStyle _buttonStyle({
    MaterialStatePropertyAll<EdgeInsets> padding =
        const MaterialStatePropertyAll<EdgeInsets>(
      EdgeInsets.all(24),
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
          Tooltip(
            message: quitToolTip,
            child: OutlinedButton(
              onPressed: () {
                exit(0);
              }, //function to close program
              style: _buttonStyle(),
              child: const Text("Quit"),
            ),
          ),
          const Spacer(),
          Tooltip(
            message: listToolTip,
            child: OutlinedButton(
              onPressed: () {
                //function here to switch to list screen
                Navigator.pushNamed(context, '/List');
              },
              style: _buttonStyle(),
              child: const Text("List"),
            ),
          ),
          const Spacer(),
          Tooltip(
            message: createToolTip,
            child: OutlinedButton(
              onPressed: () {
                if(context.read<LocationProvider>().location != null){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateApp(
                      contextWallpaper: WallpaperObj(
                        context.read<LocationProvider>().location?.id ??
                            4930956,
                      ),
                      intention: 1,
                      location:
                          "placeholder", //placeholder value, it's just so dart doesn't act like such a baby
                    ),
                  ),
                );
              }},
              style: _buttonStyle(),
              child: const Text("Create"),
                          ),
          ),
        ],
      ),
    );
  }

  Container _weatherInfoHeader(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 80,
                  color: Colors
                      .black45), // placeholder, attach function to icon to change based on weather
              Text(
                checkTime(), // (TimeOfDay(hour: 12, minute: 02) !!! SCHEDULE TO UPDATE TIME EVERY MINUTE THROUGH A FUNCTION CALL !!!
                style: const TextStyle(fontWeight: FontWeight.bold),
              ), // placeholder, attach function to retrieve time
              const _CityHeader(), // placeholder, drop menu goes here
            ],
          ),
        ],
      ),
    );
  }

  Drawer _drawer(BuildContext context) {
    return Drawer(
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
              // FireHandler hand = FireHandler();
              //hand.fireSignOut();
              Navigator.of(context).pushNamed('/');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: getCurrentWeather(),
            builder: (BuildContext context, snapshot) {
              if (!snapshot.hasData) {
                return const Icon(Icons.hourglass_top);
              }
              return _weatherInfoHeader(snapshot.data!);
            },
          ),
          wallpaperSection(),
          buttonMenu(context),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: const FloatingDrawerButton(),
      drawer: _drawer(context),
    );
  }
}
