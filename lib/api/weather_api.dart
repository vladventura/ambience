import 'package:ambience/storage/storage.dart';
import 'geolocate_api.dart';
import 'package:flutter/foundation.dart';
//install http.dart via 'flutter pub add http'
import 'package:http/http.dart' as http;

//Takes cordinates from geolocate api and writes weather data JSON to file using
//storage class.
getWeather(String? input) async {
  //to be replaced with a way of hiding api key
  const apiKey = '91c86752769af03ca919b23664114cda';
  //cords = 2 size array with lat and lon, index 0 and 1 respectively
  var cords = await geolocate(apiKey, input);
  //if name couldn't be geolocated
  if (cords[0] == 'failed') {
    debugPrint("Geolocation failed");
    return false;
  }
  //api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API key}
  var weatherUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=${cords[0]}&lon=${cords[1]}&appid=$apiKey');

  //API call to openweather, sends back a json.
  var weatherReply = await http.get(weatherUrl);
  var storage = Storage();
  //.body attribute contains json, write to given file
  await storage.writeAppDocFile(weatherReply.body, 'weatherData.txt');
  //succeeded

  return true;
}
