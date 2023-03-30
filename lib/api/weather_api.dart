import 'package:ambience/storage/storage.dart';
import 'geolocate_api.dart';
import 'package:flutter/foundation.dart';
import 'package:ambience/handlers/request_handler.dart';
/* Uncomment these for using the weather model */
// import 'dart:convert';
// import 'package:ambience/models/weather_model.dart';

//Takes cordinates from geolocate api and writes weather data JSON to file using
//storage class.
Future<dynamic> getWeather(String? input,
    {List<dynamic>? latlon, Handler handler = const RequestHandler()}) async {
  //cords = 2 size array with lat and lon, index 0 and 1 respectively
  List<dynamic> cords = latlon ?? await geolocate(input);
  //if name couldn't be geolocated
  if (cords.isEmpty) {
    debugPrint("Geolocation failed");
    return false;
  }
  dynamic weatherResponse = await handler.requestWeatherData(input, cords);
  /* WeatherModel: Usage: Uncomment the // escaped lines to use the model right away */
  /* From the json data we get from OpenWeather, we can take the list of weather info as a
  list of dynamic */
  // List<dynamic> respDecode = jsonDecode(weatherResponse.body)['list'];
  /* Then, for each one of the maps inside this list (each one of the weather data snippets), we
  can take them all and parse them from a Map<String, dynamic> (what's inside the list).
  You can think of it as javascript's Array.map(). */
  // List<WeatherModel> allWeatherData = respDecode.map((e) => WeatherModel.fromJson(e)).toList();
  /* Finally, we can reference any of these weather data as we would with an element of any
  array/list. */
  // WeatherModel weatherData = allWeatherData[0];
  // debugPrint(weatherData.windInfo.speed.toString());
  //succeeded
  return weatherResponse;
}

Future<bool> getAndWriteWeather(String? input) async {
  dynamic resp = await getWeather(input);
  if (resp == false) return false;
  Storage storage = Storage();
  await storage.writeAppDocFile(resp.body, storage.weatherDataPath);
  return true;
}
