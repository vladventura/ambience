// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, sort_child_properties_last, unused_import, sized_box_for_whitespace


// TO DO: 
//  make data persistent past setstate() calls
//  probably gonna have to change WallpaperObj to accept WallpaperEntry data
// make day buttons do stuff, 'cause they currently don't
// Scrap the copy option - done
// add time conversions - done
// ENSURE THAT JSON FILE ALWAYS EXISTS


import 'dart:async';
import 'dart:math';

import 'package:ambience/api/weather.dart';
import 'package:ambience/weatherEntry/weather_entry.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import "package:ambience/GUI/list.dart";
import "package:ambience/GUI/wallpaperobj.dart";
import "package:ambience/handlers/file_handler.dart";

void main() => runApp(CreateApp(contextWallpaper: WallpaperObj.newObj("G:/Dedicated memes folder/Image memes/b65040ee-199c-4c36-a2b2-15b1e950b3a5.png", 
                      WeatherCondition.Clouds, 14, 30, [false, true, false, true, false, true, false], []), intention: 1, location: ""));


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
  WeatherDropMenu({super.key});

  List<IconData> weathers = <IconData>[
    Icons.sunny, 
    Icons.cloud,
    Icons.water_drop,
    Icons.thunderstorm, 
    Icons.cloudy_snowing, 
  ];

  IconData weatherVal = Icons.ads_click;

  // returns a translated value for the current weather condition
  WeatherCondition getCondition() { 
    return iconToWeatherCond[weatherVal];
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

class _WallpaperChooser extends State<WallpaperChooser> {

  Widget img = Container();

  @override
  void initState() {
    super.initState();
    img = checkWallpaper(widget.currentFile);
  }

  @override
  Widget build(BuildContext context) {

    img = checkWallpaper(widget.currentFile);

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


class AmPmToggle extends StatefulWidget {
  AmPmToggle({super.key, this.amPm = true});

  bool amPm = true; // true = AM, false = PM

  bool getAmPm() {return amPm;}

 @override
  State<AmPmToggle> createState() => _AmPmToggle();
}

class _AmPmToggle extends State<AmPmToggle> {

  Text txt = Text("");

  @override
  void initState() {
    super.initState();
    if(widget.amPm){ txt = Text("A.M.", style: TextStyle(fontSize: 11)); }
    else { txt = Text("P.M.", style: TextStyle(fontSize: 11)); }
  }

  @override
  Widget build(BuildContext context){

    return Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),

              child: OutlinedButton(onPressed: (){
                if(widget.amPm == true){
                  setState(() {
                    txt = Text("P.M.", style: TextStyle(fontSize: 11));
                    widget.amPm = false;
                  });
                }
                else if(widget.amPm == false){
                  setState(() {
                    txt = Text("A.M.", style: TextStyle(fontSize: 11));
                    widget.amPm = true;
                  });
                }
              }, // switches from A.M. to P.M. and vice versa on click
                child: txt,
                style: dayToggleButton,
          ));
  }
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

  List<bool> daysActive = [false,false,false,false,false,false,false]; 

  List<bool> getDays(){
    return daysActive;
  }

  DayButtons({super.key, required this.daysActive});

 @override
  State<DayButtons> createState() => DayButtonsState();
}

class DayButtonsState extends State<DayButtons>{

  List<bool> selectedDays = [false,false,false,false,false,false,false];

  List<Widget> dayNames = <Widget>[
    Text("Sun", style: TextStyle(fontSize: 11)),
    Text("Mon", style: TextStyle(fontSize: 11)),
    Text("Tue", style: TextStyle(fontSize: 11)),
    Text("Wed", style: TextStyle(fontSize: 11)),
    Text("Thu", style: TextStyle(fontSize: 11)),
    Text("Fri", style: TextStyle(fontSize: 11)),
    Text("Sat", style: TextStyle(fontSize: 11))
  ];

  // checks if button is toggled or not
  // if the day is already currently selected, then the day is toggled off and removed from the list
  // if the day is not selected yet, the day is toggled on, and is added to the list
  void updateDays(int index){ 
    if(selectedDays[index]){
      selectedDays[index] = false;
    } else {
      selectedDays[index] = true;
    }

    widget.daysActive = selectedDays;
  }

  @override
  Widget build(BuildContext context){

    selectedDays = widget.daysActive;

    return ToggleButtons(
      direction: Axis.horizontal,
      onPressed: (int index) { 
        updateDays(index);
        setState(() {});
      },
      selectedBorderColor: Color.fromARGB(255, 0, 75, 205),
      selectedColor: Color.fromARGB(255, 41, 187, 255),
      children: dayNames,
      isSelected: selectedDays,
    );
  }
}

class CreateApp extends StatefulWidget {
  CreateApp({super.key, required this.contextWallpaper, required this.intention, required this.location});

  WallpaperObj contextWallpaper;

  // 1 = create new wallpaper, 
  // 2 = copy from existing wallpaper, 
  // 3 = edit existing wallpaper
  final int intention; 

  final String location;

 @override
  State<CreateApp> createState() => _CreateApp();
}

class _CreateApp extends State<CreateApp> {

  bool isNumeric(String s) {
    return int.tryParse(s) != null;
  }
  
  int toNumber(String s) {
    return int.tryParse(s)!;
  } 

  int toMilitary(int h, bool ap)
  {
    if(ap) { return h; } // AM

    else{ // PM 
      if(h + 12 == 24) {return 0;} //military is 00 to 23
      else { return h+12; }
    }

  }

  // gonna need to change this 
  bool checkFields(String hour, String minute, String file, WeatherCondition cond, List<bool> days) { // confirm all fields are filled
      if(isNumeric(hour) && int.parse(hour) <= 12 && int.parse(hour) > 0){}
      else{return false;}

      if(isNumeric(minute) && int.parse(minute) <= 59){}
      else{return false;}

      if(days.every((element) => element == false)){return false;}

      if(cond != WeatherCondition.Empty){}
      else{return false;}

      if(file != "" && File(file).existsSync()){}
      else {return false;}

      return true;
  }

  WeatherDropMenu weatherDrops = WeatherDropMenu();

  WallpaperChooser fileChooser = WallpaperChooser(currentFile: "");

  DayButtons dayToggles = DayButtons(daysActive: []); // will probably give initial values here or something

  String chosenFile = "";

  IconData chosenCond = Icons.ads_click; //the value for clear is invalid, which is later checked for

  String chosenMinute = "";

  String chosenHour = "";

  AmPmToggle AMPM = AmPmToggle();


  bool _visibleErr = false;
  int errType = 0;

  @override
  void initState()
  {
    super.initState();
    dayToggles = DayButtons(daysActive: widget.contextWallpaper.days);
    chosenCond = weathercondToIcon[widget.contextWallpaper.cond];
    weatherDrops.weatherVal = weathercondToIcon[widget.contextWallpaper.cond];
    
    fileChooser.currentFile = widget.contextWallpaper.filePath;
    fileChooser.setCurrentFile(widget.contextWallpaper.filePath);

    chosenFile = widget.contextWallpaper.filePath;

    if(widget.contextWallpaper.hour > 12)
    {
      if(widget.contextWallpaper.hour == 24) {
        chosenHour = 0.toString();
        AMPM.amPm = true;
      }
      else {
        AMPM.amPm = false; 
        chosenHour = (widget.contextWallpaper.hour - 12).toString(); 
      }
    } else {
      AMPM.amPm = true;
      chosenHour = widget.contextWallpaper.hour.toString();
    }
    chosenMinute = widget.contextWallpaper.minute.toString();
  }

  //function that performs the final action before closing the create page
  //decides what to do based on the intention variable
  Future<bool> confirmCreation(int intend, WallpaperObj origObj, WallpaperObj newObj) async {

    // return true if created successfully
    // return false if new wallpaper is a duplicate

    // don't check for duplicate filepaths, only conditions can cause conflicts

    // call WeatherEntry.createrule
    // if false, return failure, because a duplicate has been found

    // pop screen with a pair<true, wallpaperObj> value, indicating success
    // false would be <false, NULL>

    List<String> tempSchemas = []; // in case you need to abort and undo the new rules

    for(int i = 0; i < newObj.entries.length; i++){

      await WeatherEntry.createRule(newObj.entries[i]);

      bool success = true; //only for the time being, delete once createRule becomes boolean

      if(success){ tempSchemas.add(newObj.entries[i].idSchema);}
      
      else {
        tempSchemas.forEach((element) { WeatherEntry.deleteRule(element); });

        return false;
      }

    }

    return true;
}

  @override
  Widget build(BuildContext context) {

    fileChooser = WallpaperChooser(currentFile: widget.contextWallpaper.filePath);

    TextEditingController hourController = TextEditingController(text: chosenHour);
    TextEditingController minuteController = TextEditingController(text: chosenMinute);

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
                          counterText: "",
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
                          counterText: "",
                          labelText: "Min",
                        ),), 
                      ),
                    ]
                  ),
                )
              ),
            Spacer(flex: 1),

            AMPM,

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

                    Navigator.pop(context, false);

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

                        WallpaperObj newObj = WallpaperObj.newObj(fileChooser.getCurrentFile(), weatherDrops.getCondition(), 
                                                                  toMilitary(toNumber(hourController.text), AMPM.getAmPm()), 
                                                                  toNumber(minuteController.text), dayToggles.getDays());
                        

                        bool success = await confirmCreation(widget.intention, widget.contextWallpaper, newObj);

                        if(success){ // add fields to newWallpaperObj
                          Navigator.pop(context); // return to previous menu
                        }
                        else {
                          setState( (){
                        errType = 2;
                        _visibleErr = true;});
                        } 
                      }
                    else {
                        setState( (){ // test this later, when an error occurs the daytoggles reset to all false and still pass checkfields somehow.
                        dayToggles.daysActive = [false,false,false,false,false,false,false];
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
            dayToggles,
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