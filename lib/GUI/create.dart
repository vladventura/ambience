// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, sort_child_properties_last, unused_import, sized_box_for_whitespace

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

void main() => runApp(const CreateApp());

String current = Directory.current.path;

class WeatherDropMenu extends StatefulWidget {
  const WeatherDropMenu({super.key});

 @override
  State<WeatherDropMenu> createState() => _WeatherDropMenuState();
}

class _WeatherDropMenuState extends State<WeatherDropMenu> {
      
  List<IconData> weathers = <IconData>[
    Icons.sunny, 
    Icons.cloud, 
    Icons.shower, 
    Icons.thunderstorm, 
    Icons.snowing, 
  ];

  IconData weatherVal = Icons.hourglass_bottom;

  @override
  Widget build(BuildContext context) {
    return Container( // needs a "stateful widget" to work properly and change states
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(right: 24),
            child: DropdownButton<IconData>(
              icon: Icon(weatherVal), //placeholder icon value for now
              iconSize: 64,
              onChanged: (IconData? newVal) {
                setState(() {
                  weatherVal = newVal!;
                });
              }, // update current weather value
              items: weathers.map<DropdownMenuItem<IconData>>((IconData value) {
                return DropdownMenuItem<IconData>(
                  value: value,
                  child: Icon(value),
                );
              }
              ).toList(),
            )
          );
  }
}


class CreateApp extends StatelessWidget {
  const CreateApp({super.key});

  @override
  Widget build(BuildContext context) {

      final ButtonStyle dayToggleButton = OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.black, width: 1),
        fixedSize: Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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

    Widget dayButtonsSection = Container(
      padding: EdgeInsets.all(16),

      child: Row(

        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Spacer(flex: 12),

          OutlinedButton(onPressed: null, //place function call within toggle button function
          child: const Text("Sun", style: TextStyle(fontSize: 11)),
          style: dayToggleButton,
          ),
          
          Spacer(flex: 1),

          OutlinedButton(onPressed: null,
          child: const Text("Mon", style: TextStyle(fontSize: 11)),
          style: dayToggleButton,
          ),

          Spacer(flex: 1),

          OutlinedButton(onPressed: null, 
          child: const Text("Tue", style: TextStyle(fontSize: 11)),
          style: dayToggleButton,
          ),

          Spacer(flex: 1),

          OutlinedButton(onPressed: null, 
          child: const Text("Wed", style: TextStyle(fontSize: 11)),
          style: dayToggleButton,
          ),

          Spacer(flex: 1),

          OutlinedButton(onPressed: null, 
          child: const Text("Thu", style: TextStyle(fontSize: 11)),
          style: dayToggleButton,
          ),

          Spacer(flex: 1),

          OutlinedButton(onPressed: null, 
          child: const Text("Fri", style: TextStyle(fontSize: 11)),
          style: dayToggleButton,
          ),

          Spacer(flex: 1),

          OutlinedButton(onPressed: null, 
          child: const Text("Sat", style: TextStyle(fontSize: 11)),
          style: dayToggleButton,
          ),

          Spacer(flex: 12),

        ],
      ),

    );

    Widget timeAndWeather = Container(
      padding: EdgeInsets.all(16),

      child: Row(
        
        mainAxisAlignment: MainAxisAlignment.center,

        children: [

            Spacer(flex: 9),

            Container( // Time Input Box
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
                child: Expanded(
                  child: Row( 
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        child: TextField(onChanged: null , textAlign: TextAlign.right, // convert to time values, invalid times should be reset.
                        maxLength: 2,
                        decoration: InputDecoration(
                          labelText: "Hour",
                        ),), 
                      ),

                      const Text(":"),

                      Container(
                        width: 40,
                        child: TextField(onChanged: null , textAlign: TextAlign.left, // convert to time values, invalid times should be reset.
                        maxLength: 2,
                        decoration: InputDecoration(
                          labelText: "Min",
                        ),), 
                      ),
                    ] 
                  ),
                )
              ),

            Spacer(flex: 1),

            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),

              child: OutlinedButton(onPressed: null, // switches from A.M. to P.M. and vice versa on click
                child: const Text("A.M.", style: TextStyle(fontSize: 11)),
                style: dayToggleButton,
              ),
            ),

            Spacer(flex: 6),

            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),

              child: WeatherDropMenu(),
            
            ),

            Spacer(flex: 9),

        ],
        
      ),

    );

    Widget buttonMenu = Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),    
      child: Row(
        children: [
          OutlinedButton(onPressed: () {

                    Navigator.pop(context);

                    },  //function here to switch back to main menu
                    child: const Text("Back"),
                    style: ButtonStyle(
                      padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
                      backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                      side: MaterialStatePropertyAll<BorderSide>(BorderSide(color: Colors.black, width: 2),),
                    ),
                    ),
          Spacer(),
          OutlinedButton(onPressed: null, //function here to switch to create screen
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
            dayButtonsSection,
            timeAndWeather,
            wallpaperSection,
            buttonMenu,
          ],
        ),
        ),
      );
  }
}