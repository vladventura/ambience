import 'weather_api.dart';
import 'package:flutter/foundation.dart';
import 'package:ambience/storage/storage.dart';
//Reads weather data JSON from file.
//Note this is a bit if a proof of concept function
//Data needs to be prased to be utitlize, right now there is only an example of doing so
void weather(String? input) async {
  //not fully functional
  //get weather data
  if (await (getWeather(input)) == false) {
    debugPrint("Failed to get Weatherdata!");
  }
  //else successfuly gotten weather data
  var storage = Storage();
  //Reads from give file in AppDoc/Ambience dir and reteurns a decoded JSON as a Dart object
  var weatherData = await storage.readAppDocJson('weatherData.txt');
  //sample of parsing weather data
  //note it is a mix of lists and maps. Hence key and index accesing.
  debugPrint(
      "Found weather for ${weatherData['city']['name']} in ${weatherData['city']['country']}."
      " The weather: ${(weatherData['list'][0])['weather'][0]['description']}.");
}
