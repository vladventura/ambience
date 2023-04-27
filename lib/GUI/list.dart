// TODO: Add Function parameter to pass to the button widgets (so that they can pass the ID up to the list screen) - done
// add a text widget to show the days active for a given wallpaperEntry

import 'package:ambience/GUI/create.dart';
import 'package:ambience/constants.dart';
import 'package:ambience/providers/wallpaper_obj_provider.dart';
import 'package:ambience/utils.dart';
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
              WallpaperObjProvider wop = context.read<WallpaperObjProvider>();
              wop.setCurrentEditWallpaper(WallpaperObj(0));
              Navigator.of(context).pushNamed('/Create').then((value) {
                debugPrint(value.toString());
                context.read<WallpaperObjProvider>().reloadWallpaperObjList();
              });
            }, //function here to switch to create screen
            style: controlStyle,
            child: const Text("Create"),
          ),
        ),
      ],
    ),
  );
}

class WallPapersWindow extends StatefulWidget {
  const WallPapersWindow({super.key});

  @override
  State<StatefulWidget> createState() => WallPapersWindowState();
}

class WallPapersWindowState extends State<WallPapersWindow> {
  void deleteWallpaper(int id) {
    WallpaperObjProvider wop = context.read<WallpaperObjProvider>();
    if (wop.wallpaperObjects == null) return;

    context.read<WallpaperObjProvider>().removeEntry(id);
  }

  void editWallpaper(int id) {
    // deletes original,
    WallpaperObjProvider wop = context.read<WallpaperObjProvider>();
    if (wop.wallpaperObjects == null) return;

    // Null guard
    Map<int, WallpaperObj> temp =
        Map<int, WallpaperObj>.from(wop.wallpaperObjects!.asMap());
    if (temp[id] == null) return;

    wop.setCurrentEditWallpaper(temp[id]!);
    Navigator.of(context).pushNamed('/Create').then((result) {
      if (result == true) {
        wop.removeRules(id);
      }
    });
  }

  @override
  Widget build(context) {
    return Consumer<WallpaperObjProvider>(
      builder: (context, value, child) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Container(
              constraints: const BoxConstraints(
                  maxWidth: 1000, minHeight: 200, minWidth: 100),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: ListView(
                children: value.wallpaperObjects!
                    .asMap()
                    .entries
                    .map(
                      (e) => WallpaperEntry(
                          e.value, e.key, deleteWallpaper, editWallpaper),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ListApp extends StatefulWidget {
  const ListApp({super.key});

  @override
  State<ListApp> createState() => ListAppState();
}

class ListAppState extends State<ListApp> {
  Widget _content(List<WallpaperObj>? objs) {
    if (objs == null) {
      return const Center(
        child: Icon(Icons.hourglass_top),
      );
    }
    debugPrint("Called content");
    debugPrint(objs.toString());
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        listTitle(),
        const WallPapersWindow(),
        buttonMenu(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WallpaperObjProvider>(
        builder: (context, value, child) {
          return _content(value.wallpaperObjects);
        },
      ),
    );
  }
}
