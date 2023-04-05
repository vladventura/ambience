// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, sort_child_properties_last, unused_import, sized_box_for_whitespace

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

void main() => runApp(const ListApp());

String current = Directory.current.path;

class WallpaperObj {
  String filePath = "$current/lib/GUI/20210513_095523.jpg";
  String cond = "placeholder weather";
  String time = "placeholder time";

  WallpaperObj(){
    String filePath = "$current/lib/GUI/20210513_095523.jpg";
    String cond = "placeholder weather";
    String time = "placeholder time";
  }
} // PLACEHOLDER FOR ACTUAL WALLPAPER OBJ SO FLUTTER WILL STOP COMPLAINING

String getWallpaper(int index) {
  return "$current/lib/GUI/20210513_095523.jpg";
}

String getCond(int index) {
  return "placeholder weather";
}

String getTime(int index) {
  return "placeholder time";
}

// List<Widget> wallpapers;

class EntryControls extends StatelessWidget { // controls to copy, edit, and delete a wallpaper

  Widget Controls = Container();

  EntryControls(WallpaperObj obj){ //takes a wallpaper obj reference to call it later

  Controls = Container(
      child: Row(
    // displays the wallpaper's controls
    children: [
      IconButton(
        onPressed: null, //function here to switch back to main menu
        icon: Icon(Icons.delete),
        style: ButtonStyle(
          padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
          backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
          side: MaterialStatePropertyAll<BorderSide>(
            BorderSide(color: Colors.black, width: 2),
          ),
        ),
      ),
      IconButton(
        onPressed: null, //function here to switch back to main menu
        icon: Icon(Icons.copy),
        style: ButtonStyle(
          padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
          backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
          side: MaterialStatePropertyAll<BorderSide>(
            BorderSide(color: Colors.black, width: 2),
          ),
        ),
      ),
      IconButton(
        onPressed: null, //function here to switch back to main menu
        icon: Icon(Icons.edit),
        style: ButtonStyle(
          padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
          backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
          side: MaterialStatePropertyAll<BorderSide>(
            BorderSide(color: Colors.black, width: 2),
          ),
        ),
      ),
    ],
  ));
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
      constraints: BoxConstraints(maxHeight: 100, maxWidth: 200),
      decoration: BoxDecoration(
      border: Border.all(color: Colors.black, width: 1),
      ),
      child: Image.file(File(wallFile), fit: BoxFit.fitWidth,),
    );

    wallpaperCond = Expanded(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_dining), // placeholder
              Container( alignment: Alignment.center,
                child: Text(getTime(0)) ),
            ],
          )
    );

    wallpaperControls = EntryControls(obj);

  }
 
  Widget build(BuildContext context) {
    return Container(
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

class ListApp extends StatelessWidget {
  const ListApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget listTitle = Container(
      child: Text("Saved Wallpapers", style: TextStyle(fontSize: 14)),
    );

    Widget wallPapersWindow = Expanded(
      child: Container (
        padding: EdgeInsets.all(32),
        child: Container (
          constraints: BoxConstraints(maxHeight: 1000, maxWidth: 1000,
                                      minHeight: 200, minWidth: 100),
            decoration:
            BoxDecoration (border: Border.all(color: Colors.black, width: 2)),
          child: Expanded(
            child: ListView(
              children: [
              WallpaperEntry(WallpaperObj()),
          ],
          ),
          ),
        )
      )
    );

    Widget buttonMenu = Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            }, //function here to switch back to main menu
            child: const Text("Back"),
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
              Navigator.pushNamed(context, '/Create');
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
          children: [listTitle, wallPapersWindow, buttonMenu],
        ),
      ),
    );
  }
}
