import 'package:flutter/material.dart';
import 'package:ambience/storage/storage.dart';

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
  // dummy filler values here will get overwritten by constructor
  // todo: unique identifier schema
  // todo: return map of json decoded "rules"
  TimeOfDay startTime = const TimeOfDay(hour: 21, minute: 05);
  TimeOfDay endTime = const TimeOfDay(hour: 23, minute: 59);
  DayOfWeek dayOfWeek = DayOfWeek.friday;
  String wallpaperFilepath = "";
  WeatherCondition weatherCondition = WeatherCondition.clear;
  String idSchema = 'Ambience_daemon';
  String city = 'london';

  WeatherEntry(TimeOfDay startTime, TimeOfDay endTime, String weather, DayOfWeek dayOfWeek,
      String wallpaperFilepath, WeatherCondition weatherCondition, String idSchema, String city);

  // This is what the UI should call to add a new rule, eg:
  // createRule(new WeatherEntry(TimeofDay(hour: 10, minute: 30),
  //            TimeofDay(hour: 15, minute: 0), WeatherConditions.clear,
  //            "./pathtofile.png"))
  // This function will add the entry to the json file
  static void createRule(WeatherEntry newEntry) async {
    Storage store = Storage();
    String fileContents = await store.readAppDocJson('dummy.json');
    // if the read fails then the file doesn't exist
    if (fileContents != 'failed') {
      // the file exists so we will append the new WeatherEntry
    } else {
      // the file doesn't exist, create it and add the new WeatherEntry
    }
  }
}
