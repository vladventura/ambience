// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, sort_child_properties_last, unused_import, sized_box_for_whitespace


// TO DO: 
//  make data persistent past setstate() calls
//  probably gonna have to change WallpaperObj to accept WallpaperEntry data
// make day buttons do stuff, 'cause they currently don't


import 'dart:math';

import 'package:ambience/api/weather.dart';
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

const List<String> Days =
[
  "Sunday",
  "Monday",
  "Tuesday",
 "Wednesday",
  "Thursday",
  "Friday",
  "Saturday"
];

// end of globals


class WeatherDropMenu extends StatefulWidget {
  WeatherDropMenu({super.key});

  List<IconData> weathers = <IconData>[
    Icons.sunny, 
    Icons.cloud,
    Icons.water_drop,
    Icons.thunderstorm, 
    Icons.cloudy_snowing, 
  ];

   //for translating the icondata to a more...readable value
  Map translatedWeathers = {
    Icons.sunny:"Sunny",
    Icons.cloud:"Cloudy",
    Icons.water_drop:"Rain",
    Icons.thunderstorm:"Thunder",
    Icons.cloudy_snowing:"Snowing"};

  IconData weatherVal = Icons.hourglass_bottom;

  // returns a translated value for the current weather condition
  String getCondition() { 
    return translatedWeathers[weatherVal];
  }


 @override
  State<WeatherDropMenu> createState() => _WeatherDropMenuState();
}

class WallpaperChooser extends StatefulWidget {

  String currentFile = "";

  WallpaperChooser({ Key? key, required this.currentFile}): super(key: key);

  String getCurrentFile(){ return currentFile; }
  void setCurrentFile(String s){ currentFile = s; }

  @override
  State<WallpaperChooser> createState() => _WallpaperChooser();
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

  @override
  Widget build(BuildContext context) {
    return Container( // needs a "stateful widget" to work properly and change states
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(right: 24),
            child: DropdownButton<IconData>(
              icon: Icon(widget.weatherVal), //placeholder icon value for now
              iconSize: 64,
              onChanged: (IconData? newVal) {
                setState(() {
                  widget.weatherVal = newVal!;
                });
              }, // update current weather value
              items: widget.weathers.map<DropdownMenuItem<IconData>>((IconData value) {
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

    Widget img = checkWallpaper(widget.currentFile);

    return Expanded(
      child: InkWell(
        onTap: () async {
          // updates the wallpaper to be the newly selected image
          widget.currentFile = await chooseFile();
          imageCache.clear();
          imageCache.clearLiveImages();
          checkWallpaper(widget.currentFile);
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

class DayButtons extends StatefulWidget{
  
  List<String> daysActive = []; 

  List<String> getDays(){
    return daysActive;
  }

  DayButtons({super.key, required this.daysActive});

 @override
  State<DayButtons> createState() => DayButtonsState();
}

class DayButtonsState extends State<DayButtons>{

  List<Widget> dayNames = <Widget>[
    Text("Sun", style: TextStyle(fontSize: 11)),
    Text("Mon", style: TextStyle(fontSize: 11)),
    Text("Tue", style: TextStyle(fontSize: 11)),
    Text("Wed", style: TextStyle(fontSize: 11)),
    Text("Thu", style: TextStyle(fontSize: 11)),
    Text("Fri", style: TextStyle(fontSize: 11)),
    Text("Sat", style: TextStyle(fontSize: 11))
  ];

  //TO DO: Give this an initial value when the user has an intention of 2 or 3
  // and of course save it to the daysActive list if applicable
  final List<bool> _selectedDays = <bool>[false,false,false,false,false,false,false];


  // checks if button is toggled or not
  // if the day is already currently selected, then the day is toggled off and removed from the list
  // if the day is not selected yet, the day is toggled on, and is added to the list
  void updateDays(int index){ 
    if(_selectedDays[index]){
      widget.daysActive.remove(Days[index]);
    } else {
      widget.daysActive.add(Days[index]);
    }
    for(int i = 0; i < Days.length; i++)
    {
      _selectedDays[i] = widget.daysActive.contains(Days[i]);
    }
  }

  @override
  Widget build(BuildContext context){

    return ToggleButtons(
      direction: Axis.horizontal,
      onPressed: (int index) { 
        updateDays(index);
        setState(() {});
      },
      selectedBorderColor: Color.fromARGB(255, 0, 75, 205),
      selectedColor: Color.fromARGB(255, 41, 187, 255),
      children: dayNames,
      isSelected: _selectedDays,
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
  if(s == null) {
    print("was not numeric\n");
    return false;
  }

  return int.tryParse(s) != null;
  } 

  bool checkFields(String hour, String minute, String file, String cond, List<String> days) { // confirm all fields are filled
      if(isNumeric(hour) && int.parse(hour) <= 12 && int.parse(hour) > 0){}
      else{print("didn't pass field check for hour\n"); return false;}

      if(isNumeric(minute) && minute.length == 2 && int.parse(minute) <= 59){}
      else{print("didn't pass field check for minute\n"); return false;}

      if(days.isEmpty){return false;}

      print("condition is: \n");
      print(cond);
      if(cond != ""){}
      else{print("didn't pass field check for condition\n"); return false;}

      if(file != ""){}
      else{print("didn't pass field check for file\n"); return false;}

      return true;
  }

  WeatherDropMenu weatherDrops = WeatherDropMenu();

  WallpaperChooser fileChooser = WallpaperChooser(currentFile: "");

  DayButtons dayToggles = DayButtons(daysActive: []); // will probably give initial values here or something

  String chosenFile = "";

  String chosenCond = "";

  String chosenMinute = "";

  String chosenHour = "";


  bool _visibleErr = false;
  int errType = 0;

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

    fileChooser = WallpaperChooser(currentFile: widget.contextWallpaper.filePath);

    TextEditingController hourController = TextEditingController(text: chosenHour);
    TextEditingController minuteController = TextEditingController(text: chosenMinute);

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
              fileChooser,
              Padding(padding: EdgeInsets.only(right: 32)),
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

              child: weatherDrops,
            
            ),

            Spacer(flex: 9),
      ]
      ),
    );

    Container buttonMenu() {
    return Container(
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
          OutlinedButton(onPressed: () {
                    if(checkFields(hourController.text, minuteController.text, fileChooser.getCurrentFile(), weatherDrops.getCondition(), dayToggles.getDays())){
                        if(confirmCreation(widget.intention, widget.contextWallpaper, WallpaperObj())){ // add fields to newWallpaperObj

                          print(hourController.text);
                          print(minuteController.text);

                          print(fileChooser.getCurrentFile());

                          print(weatherDrops.getCondition());

                          print(dayToggles.getDays());

                          Navigator.pop(context); // return to previous menu
                        }
                        else {
                          setState( (){
                        errType = 2;
                        _visibleErr = true;});
                        } 
                      }
                    else {
                        setState( (){
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
            dayToggles, // not initialized juuuuust yet
            timeAndWeather,
            wallpaperSection,
            CreateMsg(
            visibleErr: _visibleErr,
            type: errType,
            ),
            buttonMenu(),
          ],
        ),
        ),
      );
  }

}