// TODO: Add Function parameter to pass to the button widgets (so that they can pass the ID up to the list screen) - done
// add a text widget to show the days active for a given wallpaperEntry

import 'package:ambience/GUI/create.dart';
import 'package:ambience/constants.dart';
import 'package:ambience/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ambience/weatherEntry/weather_entry.dart';
import "package:ambience/GUI/wallpaperobj.dart";
import 'package:provider/provider.dart';

void main() => runApp(ListApp());

String current = Directory.current.path;

const ButtonStyle controlStyle = ButtonStyle(
    padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
    backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
    side: MaterialStatePropertyAll<BorderSide>(
        BorderSide(color: Colors.black, width: 2)));

class screenResult {
  bool result = false;

  screenResult(this.result);
}

class EntryControls extends StatelessWidget {
  // controls to copy, edit, and delete a wallpaper

  int ID =
      0; // ID to tell the list screen WHAT wallpaperEntry is being interacted with

  Widget Controls = Container();

  EntryControls(int id, Function funcFirst, Function funcSecond, {super.key}) {
    //takes a wallpaper obj reference to call it later

    ID = id;

    deletion() {
      funcFirst(ID);
    }

    editing() {
      funcSecond(ID);
    }

    Controls = Row(
      // displays the wallpaper's controls
      children: [
        IconButton(
          onPressed:
              deletion, // function to delete the wallpaperObj, deleting the rules associated with it
          icon: const Icon(Icons.delete),
          style: controlStyle,
        ),
        IconButton(
          onPressed:
              editing, //function to edit the existing wallpaper, goes to create screen w/ data
          icon: const Icon(Icons.edit),
          style: controlStyle,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Controls;
  }
}

class WallpaperEntry extends StatelessWidget {
  int ID = 0;

  WallpaperObj object = WallpaperObj(0);

  String wallFile = "Null";

  WeatherCondition cond = WeatherCondition.Empty;

  String time = "";

  String daysText = "";

  Widget wallPaperThumb = Container();
  Widget wallpaperCond = Container();
  Widget wallpaperControls = Container();
  Widget wallpaperDays = Container();

  WallpaperEntry(
      WallpaperObj obj, int id, Function funcFirst, Function funcSecond,
      {super.key}) {
    object = obj;
    wallFile = obj.filePath;
    cond = obj.cond;
    time = obj.time;

    ID = id; // list screen will determine the ID number

    wallPaperThumb = Container(
      // the wallpaper entry's thumbnail
      constraints: const BoxConstraints(maxHeight: 100, maxWidth: 200),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
      child: Image.file(File(wallFile), fit: BoxFit.fitWidth),
    );

    String daysText = (obj.days[0] ? "SA " : "") +
        (obj.days[1] ? "M " : "") +
        (obj.days[2] ? "T " : "") +
        (obj.days[3] ? "W " : "") +
        (obj.days[4] ? "TH " : "") +
        (obj.days[5] ? "F " : "") +
        (obj.days[6] ? "SU " : "");

    wallpaperDays = Text(daysText);

    wallpaperCond = Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(weathercondToIcon[cond]), // placeholder
          Container(alignment: Alignment.center, child: Text(time)),
          wallpaperDays,
        ],
      ),
    );

    wallpaperControls = EntryControls(ID, funcFirst, funcSecond);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            wallPaperThumb,
            wallpaperCond,
            wallpaperControls,
          ],
        ));
  }
}

Widget listTitle() {
  return const Text("Saved Wallpapers", style: TextStyle(fontSize: 14));
}

Widget buttonMenu(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
    child: Row(
      children: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          }, //function here to switch back to main menu
          style: controlStyle,
          child: const Text("Back"),
        ),
        const Spacer(flex: 1),
        Tooltip(
          message: createToolTip,
          child: OutlinedButton(
            onPressed: () {
              // might need to change the "0" to an actual cityid
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateApp(
                          contextWallpaper: WallpaperObj(0),
                          intention: 3,
                          location: "")));
            }, //function here to switch to create screen
            style: controlStyle,
            child: const Text("Create"),
          ),
        ),
      ],
    ),
  );
}

class wallPapersWindow extends StatefulWidget {
  List<WallpaperObj> objects = [];

  wallPapersWindow(this.objects, {super.key});

  @override
  State<StatefulWidget> createState() => wallPapersWindowState();
}

class wallPapersWindowState extends State<wallPapersWindow> {
  late Map<int, WallpaperObj> _objs;

  @override
  void initState() {
    super.initState();
    _objs = widget.objects.asMap();
  }

  void deleteWallpaper(int id) async {
    debugPrint("Delete called!");
    Map<int, WallpaperObj> temp = Map<int, WallpaperObj>.from(_objs);
    // Null guard
    if (temp[id] == null) return;
    for (WeatherEntry entry in temp[id]!.entries) {
      await WeatherEntry.deleteRule(entry.idSchema);
    }
    temp[id]!.entries.clear();
    temp.remove(id);
    setState(() {
      _objs = temp;
    });
  }

  void editWallpaper(int id) async {
    // deletes original,
    debugPrint("Edit called!");
    Map<int, WallpaperObj> temp = Map<int, WallpaperObj>.from(_objs);
    // Null guard
    if (temp[id] == null) return;

    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CreateApp(
                contextWallpaper: temp[id]!, intention: 3, location: "")));

    debugPrint(result.toString());

    if (result == true) {
      for (WeatherEntry entry in temp[id]!.entries) {
        await WeatherEntry.deleteRule(entry.idSchema);
      }
      temp[id]!.entries.clear();
      temp.remove(id);
      setState(() {
        _objs = temp;
      });
    }
  }

  @override
  Widget build(context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Container(
          constraints: const BoxConstraints(
              maxWidth: 1000, minHeight: 200, minWidth: 100),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
          child: ListView(
            children: _objs.entries
                .map((e) => WallpaperEntry(
                    e.value, e.key, deleteWallpaper, editWallpaper))
                .toList(),
          ),
        ),
      ),
    );
  }
}

// function that creates a list of WallpaperObjs.
// Searches list of created WeatherEntries and foundWeatherEntries them together
// into a list of WallpaperObjects.
Future<List<WallpaperObj>> listSavedWallpapers(BuildContext context) async {
  debugPrint("listSavedWallpapers called!");

  Map<String, WeatherEntry> rulesList = await WeatherEntry.getRuleList();

  if (rulesList.isEmpty) {
    return [];
  }

  List<WeatherEntry> entries = [];

  rulesList.forEach((key, value) {
    entries.add(value);
  });

  if (entries.isEmpty) {
    debugPrint("entries list is empty -listSavedWallpapers");
  }
  //list of list to store WeatherEntry that have same wallpaper, start time and weather condition
  List<List<WeatherEntry>> foundWeatherEntries = [];
  //second group to handle o
  List<List<WeatherEntry>> surplusfoundWeatherEntries = [];

  bool contains = false;
  if (entries.isNotEmpty) {
    foundWeatherEntries.add([entries.first]);
  }

    for (int i = 1; i < entries.length; i++) {
      bool added = false;
      for (int j = 0; j < foundWeatherEntries.length; j++) {
        //check if they are alike entries
        if (foundWeatherEntries[j][0].idSchema != entries[i].idSchema &&
            foundWeatherEntries[j].length < 7 &&
            foundWeatherEntries[j][0].startTime == entries[i].startTime &&
            foundWeatherEntries[j][0].wallpaperFilepath ==
                entries[i].wallpaperFilepath &&
            foundWeatherEntries[j][0].weatherCondition ==
                entries[i].weatherCondition) {
          foundWeatherEntries[j].add(entries[i]);
          added = true;
          break;
        }
      }
      //surplus group, to group an accessive amount of wallpapers
      if (!added) {
        bool addedToSurplus = false;
        for (int j = 0; j < surplusfoundWeatherEntries.length; j++) {
          if (surplusfoundWeatherEntries[j].length < 7 &&
              surplusfoundWeatherEntries[j][0].startTime ==
                  entries[i].startTime &&
              surplusfoundWeatherEntries[j][0].wallpaperFilepath ==
                  entries[i].wallpaperFilepath &&
              surplusfoundWeatherEntries[j][0].weatherCondition ==
                  entries[i].weatherCondition &&
              !surplusfoundWeatherEntries[j].contains(entries[i])) {
            surplusfoundWeatherEntries[j].add(entries[i]);
            addedToSurplus = true;
            break;
          }
        }
        if (!addedToSurplus) {
          surplusfoundWeatherEntries.add([entries[i]]);
        }
      }
    }
      //merge regular and surplus group
    foundWeatherEntries.addAll(surplusfoundWeatherEntries);
  

  List<WallpaperObj> temp = [];

  // second loop, creates a list of WallpaperObj based on how many unique entries there are
  for (int k = 0; k < foundWeatherEntries.length; k++) {
    // I know, time though
    temp.add(WallpaperObj(12 /*context.read<LocationProvider>().location!.id*/,
        foundWeatherEntries[k]));
  }

  return temp;
}

class ListApp extends StatefulWidget {
  ListApp({super.key});

  @override
  State<ListApp> createState() => ListAppState();
}

class ListAppState extends State<ListApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<WallpaperObj>>(
          future: listSavedWallpapers(context),
          builder: (BuildContext context,
              AsyncSnapshot<List<WallpaperObj>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Icon(Icons.hourglass_top),
              );
            } else {
              final List<WallpaperObj>? objects = snapshot.data;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  listTitle(),
                  wallPapersWindow(objects!),
                  buttonMenu(context)
                ],
              );
            }
          }),
    );
  }
}
