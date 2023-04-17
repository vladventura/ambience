// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, sort_child_properties_last, unused_import

// TO DO:
//  Add location gear button
//  Add logout button

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
  if(File(currentFile).existsSync()) {
    return Expanded(
              child: Image.file(
                File(currentFile),
                fit: BoxFit.fitHeight,), // placeholder, retrieve wallpaper image here
            );
  } else {
    return Container(
            child: const Text("\t No wallpaper currently displayed \t"),
          );
  }
}

String checkTime() {
  
  String current = ""; //function to retrieve time goes here
  
  return current;
}

// function to send new location data to backend,
// is called when location drop menu is changed.
void setLocation(String location) { // may not be string, just a placeholder for now

  // send location data to backend here

}

String getLocation(){ // retrieve the current location here
  String location = "placeholder location";
  
  return location;
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    Widget weatherSection = Container(
      padding: const EdgeInsets.all(32),
      child: 
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                const Icon(Icons.sunny, size: 80, color: Colors.amber), // placeholder, attach function to icon to change based on weather
                Text (checkTime(), // (TimeOfDay(hour: 12, minute: 02) !!! SCHEDULE TO UPDATE TIME EVERY MINUTE THROUGH A FUNCTION CALL !!!
                  style: TextStyle(fontWeight: FontWeight.bold),), // placeholder, attach function to retrieve time
                const Text("Boston, MA"), // placeholder, drop menu goes here
            ],
          ),
          ],
        )
    );
    
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
          OutlinedButton(onPressed: null, //function to close program
                    child: const Text("Quit"),
                    style: ButtonStyle(
                      padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
                      backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                      side: MaterialStatePropertyAll<BorderSide>(BorderSide(color: Colors.black, width: 2),),  
                    ),
                    ),
          Spacer(),
          OutlinedButton(onPressed: () { //function here to switch to list screen
                    Navigator.pushNamed(context, '/List');
                    },  
                    child: const Text("List"),
                    style: ButtonStyle(
                      padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
                      backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                      side: MaterialStatePropertyAll<BorderSide>(BorderSide(color: Colors.black, width: 2),),
                    ),
                    ),
          Spacer(),
          OutlinedButton(onPressed: () {

                    Navigator.push(context, 
                      MaterialPageRoute(builder: (context) => CreateApp(contextWallpaper: WallpaperObj(), intention: 1, location: getLocation())));

                    }, //function here to switch to create screen
                    child: const Text("Create"),
                    style: ButtonStyle(
                      padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
                      backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                      side: MaterialStatePropertyAll<BorderSide>(BorderSide(color: Colors.black, width: 2),),  
                    ),
                    ),
        ],
      ),
    );
    

    return MaterialApp(
      home: Scaffold(
        body:Column(
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