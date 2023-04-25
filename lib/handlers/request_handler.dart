import "dart:async";
import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:flutter_dotenv/flutter_dotenv.dart";

abstract class Handler {
  Future<dynamic> requestGeolocationData(String? cityName) async {}
  Future<dynamic> requestWeatherDataForecast(
      String? input, List<dynamic> cords) async {}
  Future<dynamic> requestWeatherDataNow(
      String? input, List<dynamic> cords) async {}
}

class RequestHandler implements Handler {
  const RequestHandler();
  //TODO: to be replaced with a way of hiding api key
  static final String _apiKey = dotenv.get("OpenweatherAPI");
  //use to limit number of results in geocoder api call
  //1 means it only takes the top result
  static const int _limit = 1;

  @override
  Future<dynamic> requestGeolocationData(String? cityName) async {
    //geocoder url format
    //http://api.openweathermap.org/geo/1.0/direct?q={city name},{state code},{country code}&limit={limit}&appid={API key}
    //country code = ISO 3166 codes, state code is for US only, limit is # of results returned
    Uri geocodeUri = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=$_limit&appid=$_apiKey');
    //api call to geocoder
    http.Response geocoderResponse = await http.get(geocodeUri);
    //1 size list created by json.decode with map inside if valid
    dynamic returnList = (jsonDecode(geocoderResponse.body));
    return returnList;
  }

  String get apiKey => _apiKey;

  @override
  Future<dynamic> requestWeatherDataForecast(
      String? input, List<dynamic> cords) async {
    //api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API key}
    Uri weatherUri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${cords[0]}&lon=${cords[1]}&appid=$_apiKey');
    //API call to openweather, sends back a json.
    http.Response weatherResponse = await http.get(weatherUri);
    return weatherResponse;
  }

  @override
  Future<dynamic> requestWeatherDataNow(String? input, List<dynamic> cords) async {
    //api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API key}
    Uri weatherUri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${cords[0]}&lon=${cords[1]}&appid=$_apiKey');
    //API call to openweather, sends back a json.
    http.Response weatherResponse = await http.get(weatherUri);
    return weatherResponse;
  }
}
