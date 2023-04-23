import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ambience/weatherEntry/weather_entry.dart';
import "package:ambience/GUI/wallpaperobj.dart";

void main() => runApp(const ListApp());

String current = Directory.current.path;

String getWallpaper(int index) { // may not be final
  return "$current/lib/GUI/20210513_095523.jpg";
}

String getCond(int index) { // may not be final
  return "placeholder weather";
}

String getTime(int index) { // may not be final
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
        onPressed: null, // function to delete the wallpaperObj, deleting the rules associated with it
        icon: Icon(Icons.delete),
        style: controlStyle,
        ),
      IconButton(
        onPressed: null, // function to copy the wallpaperObj, goes to create screen w/ data from wallpaperObj
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

  // function that creates a list of WallpaperObjs.
  // Searches list of created WeatherEntries and groups them together
  // into a list of WallpaperObjects.

/*

  List<WallpaperObj> savedWallpapers(){

    Map<String, WeatherEntry> rulesList = WeatherEntry.getRuleList() as Map<String, WeatherEntry>;

    

  }

*/



  String wallFile = "Null";

  WeatherCondition cond = WeatherCondition.Empty;

  String time = "";

  Widget wallPaperThumb = Container();
  Widget wallpaperCond = Container();
  Widget wallpaperControls = Container();


  //constructor placeholder to just test list screen
  WallpaperEntry(WallpaperObj obj) {
    wallFile = obj.filePath;
    cond = obj.cond;
    time = obj.time;

    wallPaperThumb = Container( // the wallpaper entry's thumbnail
      constraints: const BoxConstraints(maxHeight: 100, maxWidth: 200),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1)),
      child: Image.file(File(getWallpaper(1)), fit: BoxFit.fitWidth),
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
