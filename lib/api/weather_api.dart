import 'package:ambience/models/location_model.dart';
import 'package:ambience/storage/storage.dart';
import 'package:ambience/handlers/request_handler.dart';

//Takes cordinates from geolocate api and writes weather data JSON to file using
//storage class.
Future<dynamic> getWeatherForecast(LocationModel? input,
    {Handler handler = const RequestHandler()}) async {
  // List<dynamic> cords = latlon ?? await geolocate(input);
  // if (cords.isEmpty) {
  //   debugPrint("Geolocation failed");
  //   return false;
  // }
  dynamic weatherResponse = await handler.requestWeatherDataForecast(input?.id);
  return weatherResponse;
}

Future<dynamic> getWeatherForecastD(int input,
    {Handler handler = const RequestHandler()}) async {
  dynamic weatherResponse = await handler.requestWeatherDataForecast(input);
  return weatherResponse;
}

Future<bool> getAndWriteWeatherForecast(LocationModel? input) async {
  dynamic resp = await getWeatherForecast(input);
  if (resp == false) return false;
  Storage storage = Storage();
  await storage.writeAppDocFile(resp.body, storage.weatherDataPath);
  return true;
}

Future<bool> getAndWriteWeatherForecastD(int input) async {
  dynamic resp = await getWeatherForecastD(input);
  if (resp == false) return false;
  Storage storage = Storage();
  await storage.writeAppDocFile(resp.body, storage.weatherDataPath);
  return true;
}

Future<bool> getWeatherNowRequest(LocationModel? input) async {
  dynamic resp = await getWeatherNow(input);
  if (resp == false) return false;
  return true;
}

Future<dynamic> getWeatherNow(LocationModel? input,
    {Handler handler = const RequestHandler()}) async {
  //cords = 2 size array with lat and lon, index 0 and 1 respectively
  // List<dynamic> cords = latlon ?? await geolocate(input);
  // //if name couldn't be geolocated
  // if (cords.isEmpty) {
  //   throw "failed geolocation";
  // }

  dynamic weatherResponse = await handler.requestWeatherDataNow(input?.id);
  return weatherResponse.body;
}
