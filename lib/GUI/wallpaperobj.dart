import 'package:flutter/material.dart';
import 'package:ambience/weatherEntry/weather_entry.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

//WallpaperObj acts as a wrapper for WeatherEntries, by representing once instance
// of a WeatherEntry across multiple days.
//
// This is used by the front end to retrieve strings, and interact with WeatherEntries
// as groups rather than individually.

String current = Directory.current.path;

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

Map iconToWeatherCond = {
  Icons.sunny:WeatherCondition.Clear,
  Icons.cloud:WeatherCondition.Clouds,
  Icons.water_drop:WeatherCondition.Rain,
  Icons.thunderstorm:WeatherCondition.Thunderstorm,
  Icons.cloudy_snowing:WeatherCondition.Snow,
  Icons.ads_click:WeatherCondition.Empty
  };

Map weathercondToIcon = {
  WeatherCondition.Clear:Icons.sunny,
  WeatherCondition.Clouds:Icons.cloud,
  WeatherCondition.Rain:Icons.water_drop,
  WeatherCondition.Thunderstorm:Icons.thunderstorm,
  WeatherCondition.Snow:Icons.cloudy_snowing,
  WeatherCondition.Empty:Icons.ads_click
  };

class WallpaperObj {
  String filePath = "$current/lib/GUI/20210513_095523.jpg";
  WeatherCondition cond = WeatherCondition.Clear;
  String time = "placeholder time";
  String city = "placeholder city";

  int hour = 0;
  int minute = 0;

  //stores Weather entries of the same kind on different days
  List<WeatherEntry> entries;
  
  List<bool> days = [false, false, false, false, false, false, false];
  // constructor for an existing WeatherEntry(s)
  // list MUST be in order from sunday to saturday
  WallpaperObj([this.entries = const[]]){

    if(entries.isNotEmpty)
    {
      filePath = entries[0].wallpaperFilepath;
      cond = entries[0].weatherCondition;

      hour = entries[0].startTime.hour;
      minute = entries[0].startTime.minute;

      time = hour.toString() + ":" + minute.toString();

      city = entries[0].city;

    //initializing list in order fron sun to sat

    List<WeatherEntry> temp = [];
    for(int i = 0; i < 7; i++) {
      for(int j = 0; j < 7; j++){
        if (entries[i].dayOfWeek == DayOfWeek.values[j]){
          temp[i] = entries[i];
        }
      }
    }
    entries = temp; // assign sorted list to entries list

    // 7 days, sun to sat
    days = [entries[0].dayOfWeek == DayOfWeek.sunday,
            entries[1].dayOfWeek == DayOfWeek.monday,
            entries[2].dayOfWeek == DayOfWeek.tuesday,
            entries[3].dayOfWeek == DayOfWeek.wednesday,
            entries[4].dayOfWeek == DayOfWeek.thursday,
            entries[5].dayOfWeek == DayOfWeek.friday,
            entries[6].dayOfWeek == DayOfWeek.saturday,];
    } 

    else { // if there is no WeatherEntry passed
      filePath = "";
      cond = WeatherCondition.Empty;
      hour = 0;
      minute = 0;
      time = hour.toString() + ":" + minute.toString();

      days = [false, false, false, false, false, false, false];
    }
  }

  WallpaperObj.newObj(this.filePath, this.cond,
                      this.hour, this.minute,
                      this.days, [this.entries = const[]]){

      filePath = "";
      cond = WeatherCondition.Empty;
      hour = 0;
      minute = 0;
      time = hour.toString() + ":" + minute.toString();

      entries = createEntries(filePath, cond, hour, minute, days, city);

      days = [false, false, false, false, false, false, false];
  }

  //private function to create entries out of data received
  List<WeatherEntry> createEntries(String file, WeatherCondition cond, 
                                  int hour, int minute, List<bool> days, String city)
  {

    List<WeatherEntry> temp = [];

    for(int i = 0; i < days.length; i++)
    {
      if(days[i]){ // if there is a Weatherentry for the ith day of the week

        TimeOfDay tempTime = TimeOfDay(hour: hour, minute: minute);

        temp.add(WeatherEntry(tempTime, DayOfWeek.values[i], file, cond, city));
      }
    }

    return temp;

  }


}