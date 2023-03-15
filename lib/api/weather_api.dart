import 'package:ambience/storage/storage.dart';
import 'geolocate_api.dart';
import 'package:flutter/foundation.dart';
import 'package:ambience/handlers/request_handler.dart';

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
