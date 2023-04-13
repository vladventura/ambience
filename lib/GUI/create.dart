// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, sort_child_properties_last, unused_import, sized_box_for_whitespace

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import "package:ambience/GUI/list.dart";
import "package:ambience/handlers/file_handler.dart";

void main() => runApp(CreateApp(
      contextWallpaper: WallpaperObj(),
      intention: 1,
    ));

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

  WallpaperChooser({Key? key, required this.chosen}) : super(key: key);

  @override
  State<WallpaperChooser> createState() => _WallpaperChooser();
}

class AmPmToggle extends StatefulWidget {
  const AmPmToggle({super.key});

  @override
  State<AmPmToggle> createState() => _AmPmToggle();
}

String setWeatherCond(IconData cond) {
  //converts icon's data to a string
  return cond.toString();
}

Future<String> chooseFile() async {
  try {
    var filepath = await getImagePathFromPicker();
    return filepath;
  } on NoFileChosenException {
    return "";
  } on FileNotFoundException {
    return "";
  } catch (e) {
    return "";
  }
}

Widget checkWallpaper(String str) {

  if(File(str).existsSync()) {
    return Expanded(
      child: Image.file(
        File(str),
        fit: BoxFit.fitHeight,), // placeholder, retrieve wallpaper image here
    );
  } else {
    return Container(
            alignment: Alignment.center,
            child:Expanded(
            child: const Text("\t No wallpaper currently displayed \t"),
            )
          );
  }
}


class _WeatherDropMenuState extends State<WeatherDropMenu> {
  List<IconData> weathers = <IconData>[
    Icons.sunny,
    Icons.cloud,
    Icons.water_drop,
    Icons.thunderstorm,
    Icons.cloudy_snowing,
  ];

  IconData weatherVal = Icons.hourglass_bottom;

  @override
  Widget build(BuildContext context) {
    return Container(
        // needs a "stateful widget" to work properly and change states
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
          }).toList(),
        ));
  }
}

class _WallpaperChooser extends State<WallpaperChooser> {

  @override
  Widget build(BuildContext context) {
    Widget img = checkWallpaper(widget.chosen.filePath);

    return Expanded(
      child: InkWell(
        onTap: () async {
          // updates the wallpaper to be the newly selected image
          widget.chosen.filePath = await chooseFile();
          imageCache.clear();
          imageCache.clearLiveImages();
          checkWallpaper(widget.chosen.filePath);
          setState(() {});
        },
        child: Container(
            child: img,
        )),
    );
  }
}

class _AmPmToggle extends State<AmPmToggle> {
  bool amPm = true; // true = AM, false = PM

  Text txt = Text("A.M.", style: TextStyle(fontSize: 11));

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: OutlinedButton(
          onPressed: () {
            if (amPm == true) {
              setState(() {
                txt = Text("P.M.", style: TextStyle(fontSize: 11));
                amPm = false;
              });
            } else if (amPm == false) {
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

class CreateMsg extends StatelessWidget {
  final bool visibleErr;

  String errMsg = "";

  int type = 0;

  CreateMsg({
    super.key,
    required this.visibleErr,
    required this.type});

  // change to accept custom error messages from firebase

  Text _createFail(int type) {

    if (type == 1) {
      errMsg = "Warning: Please fill all of the fields correctly";
    } else if (type == 2) {
      errMsg = "Warning: Wallpaper's conditions conflict with an existing wallpaper";
    } else {
      errMsg = "Warning: Incorrect information entered";
    }

    return Text(
      errMsg,
      style: TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      // needs a "stateful widget" to work properly and change states
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        children: [ // change to have only one error message, as there's gonna be a whole lotta messages
          Visibility(
            visible: visibleErr,
            child: _createFail(type), // this will be updated as the error message changes
          ),
        ],
      ),
    );
  }
}

class CreateApp extends StatefulWidget {
  CreateApp({super.key, required this.contextWallpaper, required this.intention});

  final WallpaperObj contextWallpaper;

  // 1 = create new wallpaper,
  // 2 = copy from existing wallpaper,
  // 3 = edit existing wallpaper
  final int intention;

 @override
  State<CreateApp> createState() => _CreateApp();
}

class _CreateApp extends State<CreateApp> {

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }

    return int.tryParse(s) != null;
  }

  return int.tryParse(s) != null;
  } 

  bool checkFields(String hour, String minute, String file, String cond) { // confirm all fields are filled
    if(isNumeric(hour) && int.parse(hour) <= 12 && int.parse(hour) > 00 // confirm format, 1 to 12 hours 
      && isNumeric(minute) && minute.length == 2 && int.parse(minute) <= 59 // confirm 00 format, 00 to 59 minutes
      && cond != ""
      && file != "") {     
        return true;
    }
    else {
      return false;
    }
  }

  String chosenFile = "";

  String chosenCond = "";

  String chosenMinute = "";

  String chosenHour = "";


  //function that performs the final action before closing the create page
  //decides what to do based on the intention variable
  bool confirmCreation(int intend, WallpaperObj origObj, WallpaperObj newObj){

    // return true if created successfully
    // return false if new wallpaper is a duplicate

    switch(intend) {
      case 1:
        // use newObj, create new wallpaper entry(s) with it

        return true; // temp bool

        break;

      case 2:

        // use newObj, create new wallpaper entry(s) with it,
        // keep original wallpaper entry(s) intact.

        return true; // temp bool

        break;

      case 3:
        // delete origObj's wallpaper entries,
        // create new wallpaper entries with newObj,

        return true; // temp bool

        break;

      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {

    bool _visibleErr = false;
    int errType = 0;

    TextEditingController hourController =
        TextEditingController(text: chosenHour);
    TextEditingController minuteController =
        TextEditingController(text: chosenMinute);

    if(widget.intention > 1){
      chosenFile = widget.contextWallpaper.filePath;

      chosenCond = widget.contextWallpaper.cond;

      chosenHour = widget.contextWallpaper.time;
      chosenMinute = widget.contextWallpaper.time;
    }

    Widget wallpaperSection = Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.only(left: 32)),
              WallpaperChooser(chosen: widget.contextWallpaper),
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
          OutlinedButton(
            onPressed: null, //place function call within toggle button function
            child: const Text("Sun", style: TextStyle(fontSize: 11)),
            style: dayToggleButton,
          ),
          Spacer(flex: 1),
          OutlinedButton(
            onPressed: null,
            child: const Text("Mon", style: TextStyle(fontSize: 11)),
            style: dayToggleButton,
          ),
          Spacer(flex: 1),
          OutlinedButton(
            onPressed: null,
            child: const Text("Tue", style: TextStyle(fontSize: 11)),
            style: dayToggleButton,
          ),
          Spacer(flex: 1),
          OutlinedButton(
            onPressed: null,
            child: const Text("Wed", style: TextStyle(fontSize: 11)),
            style: dayToggleButton,
          ),
          Spacer(flex: 1),
          OutlinedButton(
            onPressed: null,
            child: const Text("Thu", style: TextStyle(fontSize: 11)),
            style: dayToggleButton,
          ),
          Spacer(flex: 1),
          OutlinedButton(
            onPressed: null,
            child: const Text("Fri", style: TextStyle(fontSize: 11)),
            style: dayToggleButton,
          ),
          Spacer(flex: 1),
          OutlinedButton(
            onPressed: null,
            child: const Text("Sat", style: TextStyle(fontSize: 11)),
            style: dayToggleButton,
          ),
          Spacer(flex: 12),
        ],
      ),
    );

    Widget timeAndWeather = Container(
      padding: EdgeInsets.all(16),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Spacer(flex: 9),
        Container(
            // Time Input Box
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Expanded(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  // Hour text
                  width: 40,
                  child: TextFormField(
                    onChanged: null,
                    textAlign: TextAlign
                        .right, // convert to time values, invalid times should be reset.
                    maxLength: 2,
                    controller: hourController,
                    decoration: InputDecoration(
                      labelText: "Hour",
                    ),
                  ),
                ),
                const Text(":"),
                Container(
                  // Minute text
                  width: 40,
                  child: TextFormField(
                    onChanged: null,
                    textAlign: TextAlign
                        .left, // convert to time values, invalid times should be reset.
                    maxLength: 2,
                    controller: minuteController,
                    decoration: InputDecoration(
                      labelText: "Min",
                    ),
                  ),
                ),
              ]),
            )),
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
      ]),
    );

    Container buttonMenu() {
    return Container(
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
          OutlinedButton(onPressed: () {
                    if(checkFields(hourController.text, minuteController.text, chosenFile, chosenCond)){
                        if(confirmCreation(widget.intention, widget.contextWallpaper, WallpaperObj())){ // add fields to newWallpaperObj
                          Navigator.pop(context); // return to previous menu
                        }
                        else {
                          setState( (){
                        errType = 2;
                        _visibleErr = true;});
                        } 
                      }
                    else { setState( (){
                        errType = 1;
                        _visibleErr = true;}
                        );
                      }
                    },
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
    }

    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            dayButtonsSection,
            timeAndWeather,
            wallpaperSection,
            buttonMenu(),
            CreateMsg(
            visibleErr: _visibleErr,
            type: errType,
            )
          ],
        ),
      ),
    );
  }

}
