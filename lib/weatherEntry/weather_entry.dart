import 'package:ambience/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:ambience/storage/storage.dart';
import 'dart:convert';

enum WeatherCondition { clear, cloudy, rain, snow, thunderstorm }

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
  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 59);
  DayOfWeek dayOfWeek = DayOfWeek.friday;
  String wallpaperFilepath = "";
  WeatherCondition weatherCondition = WeatherCondition.clear;
  String idSchema = 'ambience_daemon_';
  String city = 'london';

  WeatherEntry(
      TimeOfDay startTime,
      TimeOfDay endTime,
      DayOfWeek dayOfWeek,
      String wallpaperFilepath,
      WeatherCondition weatherCondition,
      String city) {
    this.startTime = startTime;
    this.endTime = endTime;
    this.weatherCondition = weatherCondition;
    this.dayOfWeek = dayOfWeek;
    this.wallpaperFilepath = wallpaperFilepath;
    this.idSchema +=
        DateTime.now().millisecondsSinceEpoch.toString(); // unique id
    this.city = city;
  }

  // This is what the UI should call to add a new rule, eg (pulled from test code of main):
  // TimeOfDay time = const TimeOfDay(hour: 20, minute: 50);
  // DayOfWeek dow = DayOfWeek.friday;
  // WeatherCondition wc = WeatherCondition.clear;
  // String testPaper = "pathtowallpaper.jpg";
  // String city = 'New York';
  // WeatherEntry mockObj = WeatherEntry(time, time, dow, testPaper, wc, city);
  // WeatherEntry.createRule(mockObj);
  // This function will add the entry to the json file
  static void createRule(WeatherEntry newEntry) async {
    Storage store = Storage();
    var jsonDecoded = await store.readAppDocJson(constants.jsonPath);
    // if the read fails then the file doesn't exist,
    //    Storage class function readAppDocJson should be changed to
    //    throw an error rather than return "failed", for now
    //    if it doesnt return a string ('failed') then it succeeded
    if (jsonDecoded is Map<String, dynamic>) {
      // the file exists so we will append the new WeatherEntry
      jsonDecoded[newEntry.idSchema] = newEntry; // add new rule
      String rulesetToJson = jsonEncode(jsonDecoded);
      store.writeAppDocFile(rulesetToJson, constants.jsonPath);
    } else {
      // the file doesn't exist, create it and add the new WeatherEntry
      Map<String, dynamic> newRuleset = {};
      newRuleset[newEntry.idSchema] = newEntry;
      String rulesetToJson = jsonEncode(newRuleset);
      store.writeAppDocFile(rulesetToJson, constants.jsonPath);
    }
  }

  // deletes the rule matching key idSchema from the json
  static void deleteRule(String idSchema) async {
    Storage store = Storage();
    var jsonDecoded = await store.readAppDocJson(constants.jsonPath);
    if (jsonDecoded is Map<String, dynamic>) {
      // the file exists so we can delete this entry
      Map<String, dynamic> temp = jsonDecoded;
      temp.remove(idSchema);
      String rulesetToJson = jsonEncode(temp);
      store.writeAppDocFile(rulesetToJson, constants.jsonPath);
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

  WeatherEntry.fromJson(Map<String, dynamic> json) {
    startTime = TimeOfDay(
        hour: int.parse(json['startTimeHour']),
        minute: int.parse(json['startTimeMinute']));
    endTime = TimeOfDay(
        hour: int.parse(json['endTimeHour']),
        minute: int.parse(json['endTimeMinute']));
    dayOfWeek = DayOfWeek.values[int.parse(json['dayOfWeek'])];
    wallpaperFilepath = json['wallpaperFilepath'];
    weatherCondition =
        WeatherCondition.values[int.parse(json['weatherCondition'])];
    idSchema = json['idSchema'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() => {
        'startTimeHour': startTime.hour,
        'startTimeMinute': startTime.minute,
        'endTimeHour': endTime.hour,
        'endTimeMinute': endTime.minute,
        'dayOfWeek': dayOfWeek.index,
        'wallpaperFilepath': wallpaperFilepath,
        'weatherCondition': weatherCondition.index,
        'idSchema': idSchema,
        'city': city
      };
}