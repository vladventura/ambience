// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, sort_child_properties_last, unused_import, sized_box_for_whitespace

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import "package:ambience/GUI/list.dart";
import "package:ambience/handlers/file_handler.dart";

void main() => runApp(CreateApp(contextWallpaper: WallpaperObj(), intention: 1,));


// Global variables

String current = Directory.current.path;

final ButtonStyle dayToggleButton = OutlinedButton.styleFrom(
  backgroundColor: Colors.white,
  side: BorderSide(color: Colors.black, width: 1),
  fixedSize: Size(48, 48),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
);

// end of globals


class WeatherDropMenu extends StatefulWidget {
  const WeatherDropMenu({super.key});

 @override
  State<WeatherDropMenu> createState() => _WeatherDropMenuState();
}

class WallpaperChooser extends StatefulWidget {
  WallpaperObj chosen;

  WallpaperChooser({ Key? key, required this.chosen}): super(key: key);

  @override
  State<WallpaperChooser> createState() => _WallpaperChooser();
}

//function that performs the final action before closing the create page
//decides what to do based on the intention variable
void confirmCreation(int intend, WallpaperObj origObj, WallpaperObj newObj){
  switch(intend) {
    case 1:

    break;

    case 2: 

    break;

    case 3:

    break;
  }
}

class AmPmToggle extends StatefulWidget {
  const AmPmToggle({super.key});

 @override
  State<AmPmToggle> createState() => _AmPmToggle();
}

String setWeatherCond(IconData cond) { //converts icon's data to a string
  return cond.toString(); 
}

Future<String> chooseFile() async {
  try {
    var filepath = await getImagePathFromPicker();
    return filepath;
  } on NoFileChosenException{
    return "";
  } on FileNotFoundException{
    return "";
  } catch(e){
    return "";
  }
}

class _WeatherDropMenuState extends State<WeatherDropMenu> {
      
  List<IconData> weathers = <IconData>[
    Icons.sunny, 
    Icons.cloud,
    Icons.shower,
    Icons.thunderstorm, 
    Icons.cloudy_snowing, 
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

class _WallpaperChooser extends State<WallpaperChooser> {

  @override
  Widget build(BuildContext context) {

    Widget img = Image.file(
        File(widget.chosen.filePath),
        fit: BoxFit.fitHeight,);

    return Expanded(
    child: IconButton( // placeholder, retrieve wallpaper image here
      icon: img,
        onPressed: () async { // updates the wallpaper to be the newly selected image
        widget.chosen.filePath = await chooseFile();
        imageCache.clear();
        imageCache.clearLiveImages();
        img = Image.file(
        File(widget.chosen.filePath),
        fit: BoxFit.fitHeight,);
        setState(() {});
      }, //open file explorer here
    ),
  );
  }
}

class _AmPmToggle extends State<AmPmToggle> {


  bool amPm = true; // true = AM, false = PM

  Text txt = Text("A.M.", style: TextStyle(fontSize: 11));

  @override
  Widget build(BuildContext context){

    return Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),

              child: OutlinedButton(onPressed: (){
                if(amPm == true){
                  setState(() {
                    txt = Text("P.M.", style: TextStyle(fontSize: 11));
                    amPm = false;
                  });
                }
                else if(amPm == false){
                  setState(() {
                    txt = Text("A.M.", style: TextStyle(fontSize: 11));
                    amPm = true;
                  });
                }
              }, // switches from A.M. to P.M. and vice versa on click
                child: txt,
                style: dayToggleButton,
          ));
  }

}


class CreateApp extends StatelessWidget {
  CreateApp({super.key, required this.contextWallpaper, required this.intention});

  final WallpaperObj contextWallpaper;

  // 1 = create new wallpaper, 
  // 2 = copy from existing wallpaper, 
  // 3 = edit existing wallpaper
  final int intention; 

  final TextEditingController hourController = TextEditingController();
  final TextEditingController minuteController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    String chosenFile = "";

    String chosenCond = "";

    String chosenMinute = "";

    String chosenHour = "";

    void updateHour(String str) {
      chosenHour = str;
    }

    if(intention > 1){
      chosenFile = contextWallpaper.filePath;

      chosenCond = contextWallpaper.cond;

      chosenHour = contextWallpaper.time;
      chosenMinute = contextWallpaper.time;
    }

    Widget wallpaperSection = Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.only(left: 32)),
              WallpaperChooser(chosen: contextWallpaper),
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
                      Container( // Hour text
                        width: 40,
                        child: TextFormField(onChanged: null,
                        textAlign: TextAlign.right, // convert to time values, invalid times should be reset.
                        maxLength: 2,
                        controller: hourController,
                        initialValue: chosenHour,
                        decoration: InputDecoration(
                          labelText: "Hour",
                        ),), 
                      ),

                      const Text(":"),

                      Container( // Minute text
                        width: 40,
                        child: TextFormField(onChanged: null , 
                        textAlign: TextAlign.left, // convert to time values, invalid times should be reset.
                        maxLength: 2,
                        controller: minuteController,
                        initialValue: chosenMinute,
                        decoration: InputDecoration(
                          labelText: "Min",
                        ),), 
                      ),
                    ]
                  ),
                )
              ),
            Spacer(flex: 1),

            AmPmToggle(),

            Spacer(flex: 6),

            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),

              child: WeatherDropMenu(),
            
            ),

            Spacer(flex: 9),
      ]
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
          OutlinedButton(onPressed: confirmCreation(intention, contextWallpaper, WallpaperObj()),
                    child: const Text("Confirm"),
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