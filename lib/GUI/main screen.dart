// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, sort_child_properties_last, unused_import

import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:io';

void main() => runApp(const MainApp());

String current = Directory.current.path;

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
                const Text ("2:17 P.M.", // (TimeOfDay(hour: 12, minute: 02) !!! SCHEDULE TO UPDATE TIME EVERY MINUTE THROUGH A FUNCTION CALL !!!
                          style: TextStyle(fontWeight: FontWeight.bold),), // placeholder, attach function to retrieve time
                const Text("Boston, MA"), // placeholder, retrieve location via function
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
              
              Expanded(
                child: Image.file(
                File("$current/lib/GUI/20210513_095523.jpg"),
                fit: BoxFit.fitHeight,), // placeholder, retrieve wallpaper image here
              ),
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

                    Navigator.pushNamed(context, '/Create');

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