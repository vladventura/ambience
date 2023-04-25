// ignore_for_file: constant_identifier_names

import 'package:ambience/constants.dart' as constants;
import 'package:ambience/firebase/fire_handler.dart';
import 'package:flutter/material.dart';
import 'package:ambience/storage/storage.dart';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:ambience/providers/location_provider.dart';

// added empty for when the user hasn't entered anything yet
enum WeatherCondition {
  Empty, // the NULL case
  Clear,
  Clouds,
  Rain,
  Snow,
  Thunderstorm,
  Drizzle,
  Mist,
  Smoke,
  Haze,
  Dust,
  Fog,
  Sand,
  Ash,
  Squall,
  Tornado
}

enum DayOfWeek {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday
}

class WeatherEntry {
  // values here will get overwritten by constructor
  TimeOfDay startTime = const TimeOfDay(hour: 21, minute: 05);
  DayOfWeek dayOfWeek = DayOfWeek.friday;
  String wallpaperFilepath = "";
  WeatherCondition weatherCondition = WeatherCondition.Clear;
  String idSchema = 'ambience_daemon_';
  String city = 'london';

  WeatherEntry(this.startTime, this.dayOfWeek, this.wallpaperFilepath,
      this.weatherCondition, this.city) {
    wallpaperFilepath = p.normalize(wallpaperFilepath);
    idSchema += DateTime.now().millisecondsSinceEpoch.toString();
  }

  // This is what the UI should call to add a new rule, eg (pulled from test code of main):
  // TimeOfDay time = const TimeOfDay(hour: 20, minute: 50);
  // DayOfWeek dow = DayOfWeek.friday;
  // WeatherCondition wc = WeatherCondition.Clear;
  // String testPaper = "pathtowallpaper.jpg";
  // String city = 'New York';
  // WeatherEntry mockObj = WeatherEntry(time, time, dow, testPaper, wc, city);
  // WeatherEntry.createRule(mockObj);
  // This function will add the entry to the json file
  // Prevents duplicates from being added.
  static Future<bool> createRule(WeatherEntry newEntry) async {
    Storage store = Storage();
    var jsonDecoded = await store.readAppDocJson(constants.jsonPath);
    // if the read fails then the file doesn't exist,
    //    Storage class function readAppDocJson should be changed to
    //    throw an error rather than return "failed", for now
    //    if it doesnt return a string ('failed') then it succeeded
    if (jsonDecoded is Map<String, dynamic>) {
      // the file exists so we will append the new WeatherEntry
      // first check to see if this is a duplicate rule:
      bool duplicate = false;
      jsonDecoded.forEach((key, value) {
        duplicate = newEntry.startTime.hour == value["startTimeHour"] &&
            newEntry.startTime.minute == value["startTimeMinute"] &&
            newEntry.dayOfWeek == value["dayOfWeek"] &&
            newEntry.weatherCondition == value["weatherCondition"];
      });
      if (duplicate) {
        return false;
      }
      jsonDecoded[newEntry.idSchema] = newEntry; // add new rule
      String rulesetToJson = jsonEncode(jsonDecoded);
      await store.writeAppDocFile(rulesetToJson, constants.jsonPath);
    } else {
      // the file doesn't exist, create it and add the new WeatherEntry
      Map<String, dynamic> newRuleset = {};
      newRuleset[newEntry.idSchema] = newEntry;
      String rulesetToJson = jsonEncode(newRuleset);
      await store.writeAppDocFile(rulesetToJson, constants.jsonPath);
    }
    //commented out to enable rapid local testing
    //FireHandler hand = FireHandler();
    //upload the new json and associated wallpapers
    //await hand.ruleJSONUpload();
    return true;
  }

  // deletes the rule matching key idSchema from the json
  static void deleteRule(String idSchema) async {
    Storage store = Storage();
    //commented out to enable rapid local testing
    //FireHandler hand = FireHandler();

    var jsonDecoded = await store.readAppDocJson(constants.jsonPath);
    if (jsonDecoded is Map<String, dynamic>) {
      // the file exists so we can delete this entry
      Map<String, dynamic> temp = jsonDecoded;
      //Delete wallpaper in firebase
      //await hand.deleteWallpaper(temp[idSchema]["wallpaperFilepath"]);

      temp.remove(idSchema);
      String rulesetToJson = jsonEncode(temp);
      await store.writeAppDocFile(rulesetToJson, constants.jsonPath);
      //upload the new json and associated wallpapers
      //await hand.ruleJSONUpload();
      return;
    }
    // the file doesn't exist, do nothing
  }

  // returns a map of idSchemas to WeatherEntry objects representing
  // all rules present in the json file indicated by constants.jsonPath above
  static Future<Map<String, WeatherEntry>> getRuleList() async {
    Map<String, WeatherEntry> ruleset = {};
    Storage store = Storage();
    var jsonDecoded = await store.readAppDocJson(constants.jsonPath);
    if (jsonDecoded is Map<String, dynamic>) {
      Map<String, dynamic> temp = jsonDecoded;
      temp.forEach((key, value) {
        ruleset[key] = WeatherEntry.fromJson(value);
      });
      return ruleset;
    } else {
      // file error
      return ruleset;
    }
  }

  static Future<WeatherEntry> getRule(String idSchema) async {
    Storage store = Storage();
    var jsonDecoded = await store.readAppDocJson(constants.jsonPath);
    if (jsonDecoded is Map<String, dynamic>) {
      // the file exists so we can delete this entry
      Map<String, dynamic> temp = jsonDecoded;
      return temp[idSchema];
    } else {
      //placeholder
      throw "file error";
    }
  }

  WeatherEntry.fromJson(Map<String, dynamic> json) {
    startTime = TimeOfDay(
        hour: (json['startTimeHour']), minute: (json['startTimeMinute']));
    dayOfWeek = DayOfWeek.values[(json['dayOfWeek'])];
    wallpaperFilepath = p.normalize(json['wallpaperFilepath']);
    weatherCondition = WeatherCondition.values[(json['weatherCondition'])];
    idSchema = json['idSchema'];
    city = json['city'];
  }

  static Future<void> deleteRuleList() async {
    Storage store = Storage();
    var jsonDecoded = await store.readAppDocJson(constants.jsonPath);
    if (jsonDecoded is Map<String, dynamic>) {
      Map<String, dynamic> temp = jsonDecoded;
      temp.forEach((key, value) {
        deleteRule(WeatherEntry.fromJson(value).idSchema);
      });
    } else {
      // file error
      return;
    }
  }

  Map<String, dynamic> toJson() => {
        'startTimeHour': startTime.hour,
        'startTimeMinute': startTime.minute,
        'dayOfWeek': dayOfWeek.index,
        'wallpaperFilepath': wallpaperFilepath,
        'weatherCondition': weatherCondition.index,
        'idSchema': idSchema,
        'city': city
      };
  bool compareWeather(String incomingWeather) {
    if (incomingWeather == weatherCondition.name) {
      return true;
    }
    return false;
  }

  static Future<bool> updateLocInfo(String cityID) async {
    Storage store = Storage();
    Map<String, dynamic> ruleMap =
        await store.readAppDocJson(constants.jsonPath);
    //if it's empty nothing needs to be updated
    //if it's not empty update all entries with the new location
    if (ruleMap.isNotEmpty) {
      for (dynamic entry in ruleMap.values) {
        entry["city"] = cityID;
      }
      String ruleMapToJSON = jsonEncode(ruleMap);
      await store.writeAppDocFile(ruleMapToJSON, constants.jsonPath);
    }
    return true;
  }
}
