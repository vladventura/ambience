// TODO: Add Function parameter to pass to the button widgets (so that they can pass the ID up to the list screen)

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ambience/weatherEntry/weather_entry.dart';
import "package:ambience/GUI/wallpaperobj.dart";

void main() => runApp(ListApp());

String current = Directory.current.path;

const ButtonStyle controlStyle = ButtonStyle(
  padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
  backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
  side: MaterialStatePropertyAll<BorderSide>(
    BorderSide(color: Colors.black, width: 2)));

class EntryControls extends StatelessWidget { // controls to copy, edit, and delete a wallpaper

  int ID = 0; // ID to tell the list screen WHAT wallpaperEntry is being interacted with

  Widget Controls = Container();

  EntryControls(int id, Function func){ //takes a wallpaper obj reference to call it later

  ID = id;

  VoidCallback action = () {func(id);};

  Controls = Row(
    // displays the wallpaper's controls
    children: [
      IconButton(
        onPressed: action, // function to delete the wallpaperObj, deleting the rules associated with it
        icon: Icon(Icons.delete),
        style: controlStyle,
        ),
      IconButton(
        onPressed: action, //function to edit the existing wallpaper, goes to create screen w/ data
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

class 
WallpaperEntry extends StatelessWidget {

  int ID = 0;

  WallpaperObj object = WallpaperObj();

  String wallFile = "Null";

  WeatherCondition cond = WeatherCondition.Empty;

  String time = "";

  Widget wallPaperThumb = Container();
  Widget wallpaperCond = Container();
  Widget wallpaperControls = Container();

  void deleteContents(){
    
    for(int l = 0; l < object.entries.length; l++){
      WeatherEntry.deleteRule(object.entries[l].idSchema);
    }
    
    object.entries.clear();

    return;
  }

  //constructor placeholder to just test list screen
  WallpaperEntry(WallpaperObj obj, int id, Function func) {
    object = obj;
    wallFile = obj.filePath;
    cond = obj.cond;
    time = obj.time;

    ID = id; // list screen will determine the ID number

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
            Icon(weathercondToIcon[cond]), // placeholder
            Container( alignment: Alignment.center,
              child: Text(time) ),
          ],
      )
    );

    wallpaperControls = EntryControls(ID, func);
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

  // function that creates a list of WallpaperObjs.
  // Searches list of created WeatherEntries and groups them together
  // into a list of WallpaperObjects.
  Future<List<WallpaperObj>> listSavedWallpapers() async {

    Map<String, WeatherEntry> rulesList = WeatherEntry.getRuleList() as Map<String, WeatherEntry>;

    List<WeatherEntry> entries = [];

    rulesList.forEach((key, value) {
      entries.add(value);
    });

    List<List<WeatherEntry>> foundWeatherEntries = [];

    // first loop, finds every different WeatherEntry
    for(int i = 0; i < entries.length; i++){
      
      for(int j = 0; j < foundWeatherEntries.length; j++){
        
        //if there is a Weathercondition is the same, add it to one of the lists
        if(foundWeatherEntries[j][0].city == entries[i].city
        && foundWeatherEntries[j][0].startTime == entries[i].startTime
        && foundWeatherEntries[j][0].wallpaperFilepath == entries[i].wallpaperFilepath
        && foundWeatherEntries[j][0].weatherCondition == entries[i].weatherCondition)
        {
          foundWeatherEntries[j].add(entries[i]);
        }

        // otherwise it is an entirely new entry, and a new list must be added
        else{
          foundWeatherEntries.add([entries[i]]);
        }
      }
    }

    List<WallpaperObj> temp = [];

    // second loop, creates a list of WallpaperObj based on how many unique entries there are
    for(int k = 0; k < foundWeatherEntries.length; k++){
      temp.add(WallpaperObj(foundWeatherEntries[k]));
    }

    return temp;

  }

  List<WallpaperObj> objects = [];

  List<WallpaperEntry> wallEntries = [];

  wallPapersWindow() async {
    objects = await listSavedWallpapers();
  }

  Function deleteWallpaper(int id){

   return (int id){
        for(int a = 0; a < wallEntries.length; a++){
      if(wallEntries[a].ID == id){

        wallEntries[a].deleteContents();
        wallEntries.remove(wallEntries[a]);
      
      }
    }
   };
  }

  for(int i = 0; i < objects.length; i++){
    wallEntries.add(WallpaperEntry(objects[i], i, deleteWallpaper));
  }

  return Expanded(
    child: Container (
      padding: const EdgeInsets.all(32),
      child: Container (
        constraints: const BoxConstraints(maxWidth: 1000,
                                    minHeight: 200, minWidth: 100),
        decoration: BoxDecoration (border: Border.all(color: Colors.black, width: 2)),
        child: Expanded(
          child: ListView(
            children: wallEntries
          ),
        ),
      )
    )
  );
}

class ListApp extends StatefulWidget{
  ListApp({super.key});

  @override
  State<ListApp> createState() => ListAppState();
}

class ListAppState extends State<ListApp> {

  @override
  Widget build(BuildContext context) {

    Widget window = wallPapersWindow(); // miiiiiight need to check if there are no rules in the json first

    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [listTitle(), window, buttonMenu(context)],
        ),
      ),
    );
  }
}
