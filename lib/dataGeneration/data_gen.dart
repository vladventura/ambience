import 'dart:io';
import 'package:ambience/api/weather.dart';
import 'package:flutter/foundation.dart';
import 'package:ambience/api/weather_api.dart';
import 'package:ambience/models/weather_model.dart';
import 'dart:convert';

void weatherDataPlot(String input) async {
  var response = await getWeather(input);
  List<dynamic> respDecode = jsonDecode(response.body)['list'];
  List<WeatherModel> allWeatherData =
      respDecode.map((e) => WeatherModel.fromJson(e)).toList();
  //temp format file
  Map<String, int> weatherList = <String, int>{};
  String tempStr;
  for (int i = 0; i < allWeatherData.length; i++) {
    tempStr = allWeatherData[i].weathers[0].name;

    if (weatherList.containsKey(tempStr)) {
      weatherList[tempStr] = (weatherList[tempStr] ?? 0) + 1;
    } else {
      //add entry with key = tempStr, value=1
      weatherList[tempStr] = 1;
    }
  }
  String formattedArgs = weatherList.entries.map((entry) => '${entry.key}:${entry.value}').join(' ');


  //python script to make a plot. key:value e.g. snow:5, 5 days were snow
  var proc = Process.runSync('powershell.exe', ['python.exe amb_plot_gen.py $input $formattedArgs']);
  debugPrint("proc stderr: ${proc.stderr}");
}
