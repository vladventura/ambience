// TODO: Add Function parameter to pass to the button widgets (so that they can pass the ID up to the list screen) - done
// add a text widget to show the days active for a given wallpaperEntry


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

  EntryControls(int id, Function func, {super.key}){ //takes a wallpaper obj reference to call it later

  ID = id;

  VoidCallback action = () { func(ID); };

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

class WallpaperEntry extends StatelessWidget {

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

  WallpaperEntry(WallpaperObj obj, int id, Function func, {super.key}) {
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

  @override
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

class wallPapersWindow extends StatefulWidget{
    List<WallpaperObj> objects = [];

    List<WallpaperEntry> wallEntries = [];

    wallPapersWindow(List<WallpaperObj> objs, {super.key});

  @override
  State<StatefulWidget> createState() => wallPapersWindowState();

}

class wallPapersWindowState extends State<wallPapersWindow>{

  List<WallpaperObj> stateObjects = [];

  List<WallpaperEntry> stateWallEntries = [];

  void deleteWallpaper(int id){
    print("delete called!");
        for(int a = 0; a < stateWallEntries.length; a++){
      if(stateWallEntries[a].ID == id){

        stateWallEntries[a].deleteContents();
        stateWallEntries.remove(stateWallEntries[a]);
      
      }
      setState(() async {
        List<WallpaperObj> tempObjs = await listSavedWallpapers();

        for(int i = 0; i < tempObjs.length; i++){
          stateWallEntries.add(WallpaperEntry(tempObjs[i], i, deleteWallpaper));
        }
      });
    }
  }

  void getAsyncSaved() async {
    stateObjects = await listSavedWallpapers();
  }

  @override
  void initState() {
    super.initState();

    getAsyncSaved();

    for(int i = 0; i < stateObjects.length; i++){
      stateWallEntries.add(WallpaperEntry(stateObjects[i], i, deleteWallpaper));
    }
  }

  @override
  Widget build(context) {
    return Expanded(
    child: Container (
      padding: const EdgeInsets.all(32),
      child: Container (
        constraints: const BoxConstraints(maxWidth: 1000,
                                    minHeight: 200, minWidth: 100),
        decoration: BoxDecoration (border: Border.all(color: Colors.black, width: 2)),
        child: Expanded(
          child: ListView(
            children: widget.wallEntries
          ),
        ),
      )
    )
  );
  } 
}

// function that creates a list of WallpaperObjs.
// Searches list of created WeatherEntries and groups them together
// into a list of WallpaperObjects.
Future<List<WallpaperObj>> listSavedWallpapers() async {

  print("listSavedWallpapers called!");

  Map<String, WeatherEntry> rulesList = await WeatherEntry.getRuleList();

  if(rulesList.isEmpty)
  {
    return [];
  }

  List<WeatherEntry> entries = [];

  rulesList.forEach((key, value) {
    entries.add(value);
  });

  if(entries.isEmpty)
  {
    print("bruh this entries list is empty");
  }


  List<List<WeatherEntry>> foundWeatherEntries = [];

  // first loop, finds every different WeatherEntry
  for(int i = 0; i < entries.length; i++){

    if(foundWeatherEntries.isNotEmpty){
      for(int j = 0; j < foundWeatherEntries.length; j++){
        
        //if there is a Weathercondition is the same, add it to one of the lists
        if(foundWeatherEntries[j][0].city == entries[i].city
        && foundWeatherEntries[j][0].startTime == entries[i].startTime
        && foundWeatherEntries[j][0].wallpaperFilepath == entries[i].wallpaperFilepath
        && foundWeatherEntries[j][0].weatherCondition == entries[i].weatherCondition)
        {
          foundWeatherEntries[j].add(entries[i]);
          print("same entry found");
        }

        // otherwise it is an entirely new entry, and a new list must be added
        else{
          foundWeatherEntries.add([entries[i]]);
          print("unique entry found");
        }
      }
    }
    else{
      foundWeatherEntries.add([entries[i]]);
    }
      
  }

  if(foundWeatherEntries.isEmpty)
  {
    print("bruh the foundWeatherEntries is empty");
  }


  List<WallpaperObj> temp = [];

  // second loop, creates a list of WallpaperObj based on how many unique entries there are
  for(int k = 0; k < foundWeatherEntries.length; k++){
    temp.add(WallpaperObj(foundWeatherEntries[k]));
  }

  if(temp.isEmpty)
  {
    print("why the FUCK is temp empty??");
  }


  return temp;

}

class ListApp extends StatefulWidget{
  ListApp({super.key});

  @override
  State<ListApp> createState() => ListAppState();
}

class ListAppState extends State<ListApp> {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder<List<WallpaperObj>>(
          future: listSavedWallpapers(),
            builder: (BuildContext context, AsyncSnapshot<List<WallpaperObj>> snapshot) {
              if(!snapshot.hasData){
                return Center(child: Icon(Icons.hourglass_top),);
              }
              else{

                final List<WallpaperObj>? objects = snapshot.data;

                return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [listTitle(), wallPapersWindow(objects!), buttonMenu(context)]);
              }
            }
          ),            
        )         
      );
  }
}
