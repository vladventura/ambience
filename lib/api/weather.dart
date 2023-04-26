import 'package:ambience/models/location_model.dart';
import 'weather_api.dart';
import 'package:flutter/foundation.dart';
import 'package:ambience/storage/storage.dart';
import 'dart:developer';
import 'dart:convert';

//Reads weather data JSON from file.
Future<void> weatherForecast(LocationModel? input) async {
  //get weather data
  if (await (getAndWriteWeatherForecast(input)) == false) {
    debugPrint("Failed to get Weatherdata!");
    return;
  }
  //else successfuly gotten weather data
  var storage = Storage();
  //Reads from give file in AppDoc/Ambience dir and reteurns a decoded JSON as a Dart object
  var weatherData = await storage.readAppDocJson(storage.weatherDataPath);
  //sample of parsing weather data
  //note it is a mix of lists and maps. Hence key and index accesing.
  inspect(weatherData);
}

Future<Map<String, dynamic>> weatherNow(LocationModel? input) async {
  //get weather data
  try {
    if (input == null) {
      throw "location is null";
    }
    var nowWeather = await (getWeatherNow(input));
    return jsonDecode(nowWeather);
  } catch (e) {
    debugPrint(e.toString());
    Map<String, dynamic> empty = <String, dynamic>{};
    return empty;
  }
}
