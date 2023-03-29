import 'weather_api.dart';
import 'package:flutter/foundation.dart';
import 'package:ambience/storage/storage.dart';
import 'dart:developer';

//Reads weather data JSON from file.
//Note this is a bit if a proof of concept function
//Data needs to be prased to be utitlize, right now there is only an example of doing so
Future<void> weather(String? input) async {
  //not fully functional
  //get weather data
  if (await (getAndWriteWeather(input)) == false) {
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
  debugPrint(
      "Found weather for ${weatherData['city']['name']} in ${weatherData['city']['country']}."
      " The weather: ${(weatherData['list'][0])['weather'][0]['description']}.");
}
