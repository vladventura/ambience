import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:ambience/weatherEntry/weather_entry.dart';
import 'package:ambience/GUI/create.dart';

void main() => runApp(const ListApp());

String current = Directory.current.path;

//translates WeatherCondition enum to a string
// TODO: make a function that turns it back
Map translatedConditions = 
{
  WeatherCondition.clear:"Sunny",
  WeatherCondition.cloudy:"Cloudy",
  WeatherCondition.rain:"Rain",
  WeatherCondition.snow:"Thunder",
  WeatherCondition.thunderstorm:"Snowing"
};


class WallpaperObj {
  String filePath = "$current/lib/GUI/20210513_095523.jpg";
  String cond = "placeholder weather";
  String time = "placeholder time";

  int hour = 0;
  int minute = 0;

  //stores Weather entries of the same kind on different days
  List<WeatherEntry> entries;

  // constructor for an existing WeatherEntry(s)
  // list MUST be in order from sunday to saturday
  WallpaperObj([this.entries = const[]]){
    filePath = entries[0].wallpaperFilepath;
    cond = translatedConditions[entries[0].weatherCondition];

    hour = entries[0].startTime.hour;
    minute = entries[0].startTime.minute;

    time = hour.toString() + ":" + minute.toString();

    //initializing list in order fron sun to sat

    List<WeatherEntry> temp = [];
    for(int i = 0; i < 7; i++) {
      for(int j = 0; j < 7; j++){
        if (entries[i].dayOfWeek == DayOfWeek.values[j]){
          temp[i] = entries[i];
        }
      }
    }
    entries = temp; // assign sorted list to entries list

    // 7 days, sun to sat
    List<bool> days = [entries[0].dayOfWeek == DayOfWeek.sunday,
                      entries[1].dayOfWeek == DayOfWeek.monday,
                      entries[2].dayOfWeek == DayOfWeek.tuesday,
                      entries[3].dayOfWeek == DayOfWeek.wednesday,
                      entries[4].dayOfWeek == DayOfWeek.thursday,
                      entries[5].dayOfWeek == DayOfWeek.friday,
                      entries[6].dayOfWeek == DayOfWeek.saturday,];
  }
}

String getWallpaper(int index) {
  return "$current/lib/GUI/20210513_095523.jpg";
}

String getCond(int index) {
  return "placeholder weather";
}

String getTime(int index) {
  return "12:30";
}

const ButtonStyle controlStyle = ButtonStyle(
  padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
  backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
  side: MaterialStatePropertyAll<BorderSide>(
    BorderSide(color: Colors.black, width: 2)));

class EntryControls extends StatelessWidget { // controls to copy, edit, and delete a wallpaper

  Widget Controls = Container();

  EntryControls(WallpaperObj obj){ //takes a wallpaper obj reference to call it later

  Controls = Row(
    // displays the wallpaper's controls
    children: [
      IconButton(
        onPressed: null, //function to delete the wallpaper
        icon: Icon(Icons.delete),
        style: controlStyle,
        ),
      IconButton(
        onPressed: null, //function to copy the wallpaper, goes to create screen w/ data
        // creates new wallpaper when done
        icon: Icon(Icons.copy),
        style: controlStyle
      ),
      IconButton(
        onPressed: null, //function to edit the existing wallpaper, goes to create screen w/ data
        icon: Icon(Icons.edit),
        style: controlStyle,
      ),
    ],
  );
}

  Widget build(BuildContext context) {
    return Controls;
}

}

class WallpaperEntry extends StatelessWidget {

  String wallFile = "Null";

  String cond = "";

  String time = "";

  Widget wallPaperThumb = Container();
  Widget wallpaperCond = Container();
  Widget wallpaperControls = Container();

  WallpaperEntry(WallpaperObj obj) {
    wallFile = obj.filePath;
    cond = obj.cond;
    time = obj.time;

    wallPaperThumb = Container( // the wallpaper entry's thumbnail
      constraints: const BoxConstraints(maxHeight: 100, maxWidth: 200),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1)),
      child: Image.file(File(wallFile), fit: BoxFit.fitWidth),
    );

    wallpaperCond = Expanded(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloudy_snowing), // placeholder
            Container( alignment: Alignment.center,
              child: Text(getTime(0)) ),
          ],
      )
    );

    wallpaperControls = EntryControls(obj);

  }

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          wallPaperThumb,
          wallpaperCond,
          wallpaperControls,
      ],
    )
    );
  }
}

Widget listTitle(){
  return const Text("Saved Wallpapers", style: TextStyle(fontSize: 14));
}

Widget buttonMenu(BuildContext context){
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
    child: Row(
      children: [
        OutlinedButton(
          onPressed: () { Navigator.pop(context); }, //function here to switch back to main menu
          style: controlStyle,
          child: const Text("Back"),
        ),
        const Spacer(flex: 1),
        OutlinedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/Create');
          }, //function here to switch to create screen
          style: controlStyle,
          child: const Text("Create"),
        ),
      ],
    ),
  );
}

Widget wallPapersWindow() {
  return Expanded(
    child: Container (
      padding: const EdgeInsets.all(32),
      child: Container (
        constraints: const BoxConstraints(maxWidth: 1000,
                                    minHeight: 200, minWidth: 100),
        decoration: BoxDecoration (border: Border.all(color: Colors.black, width: 2)),
        child: Expanded(
          child: ListView(
            children: [ WallpaperEntry(WallpaperObj()), ],
          ),
        ),
      )
    )
  );
}

class ListApp extends StatelessWidget {
  const ListApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [listTitle(), wallPapersWindow(), buttonMenu(context)],
        ),
      ),
    );
  }
}
