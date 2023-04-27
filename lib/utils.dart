import "dart:convert";
import "dart:io";
import "package:ambience/GUI/wallpaperobj.dart";
import "package:ambience/models/location_model.dart";
import "package:ambience/weatherEntry/weather_entry.dart";
import "package:flutter/material.dart";
import "package:path/path.dart" as p;
import 'package:ambience/constants.dart' as constants;
import "package:path_provider/path_provider.dart";

class Utils {
  static Future<void> saveToLocationFile(LocationModel incoming) async {
    Directory dirToAmb = await createAmbienceIfNotExists();
    File locationFile = File(p.join(dirToAmb.path, constants.locationFilename));

    await locationFile.writeAsString(jsonEncode(incoming.toJson()));
  }

  static Future<LocationModel?> loadFromLocationFile() async {
    Directory dirToAmb = await createAmbienceIfNotExists();
    File locationFile = File(p.join(dirToAmb.path, constants.locationFilename));

    if (!await locationFile.exists() || await locationFile.length() == 0) {
      return null;
    }

    LocationModel model =
        LocationModel.fromJson(jsonDecode(await locationFile.readAsString()));
    return model;
  }

  static Future<Directory> createAmbienceIfNotExists() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String pathToAmbience = p.join(documentsDir.path, constants.appDataDirName);
    Directory dirToAmb = Directory(pathToAmbience);
    if (!await dirToAmb.exists()) {
      await dirToAmb.create(recursive: true).catchError((e) {
        debugPrint("Failed to create Ambience folder");
        return dirToAmb;
      });
    }
    return dirToAmb;
  }

  // function that creates a list of WallpaperObjs.
// Searches list of created WeatherEntries and groups them together
// into a list of WallpaperObjects.
  static Future<List<WallpaperObj>> listSavedWallpapers() async {
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
    bool contains = false;
    if (entries.isNotEmpty) {
      foundWeatherEntries.add([entries.first]);
    }
    // first loop, finds every different WeatherEntry
    for (int i = 0; i < entries.length; i++) {
      for (int j = 0; j < foundWeatherEntries.length; j++) {
        if (foundWeatherEntries[j][0].idSchema != entries[i].idSchema) {
          if ((foundWeatherEntries[j][0].startTime == entries[i].startTime) &&
              (foundWeatherEntries[j][0].wallpaperFilepath ==
                  entries[i].wallpaperFilepath) &&
              (foundWeatherEntries[j][0].weatherCondition ==
                  entries[i].weatherCondition)) {
            foundWeatherEntries.forEach((element) {
              if (element.contains(entries[i])) {
                contains = true;
              }
            });
            if (contains == false) {
              foundWeatherEntries[j].add(entries[i]);
            }
            contains = false;
          } //if it's already in the list continue
          else if (foundWeatherEntries[j][0].idSchema == entries[i].idSchema) {
            continue;
          }
          //else could be a new entry, check if it already exists in list.
          else {
            foundWeatherEntries.forEach((element) {
              if (element.contains(entries[i])) {
                contains = true;
              }
            });
            if (!contains) {
              foundWeatherEntries.add([entries[i]]);
            }
            contains = false;
          }
        }
      }
    }

    List<WallpaperObj> temp = [];

    // second loop, creates a list of WallpaperObj based on how many unique entries there are
    for (int k = 0; k < foundWeatherEntries.length; k++) {
      // I know, time though
      temp.add(WallpaperObj(
          12 /*context.read<LocationProvider>().location!.id*/,
          foundWeatherEntries[k]));
    }

    return temp;
  }
}
