import "dart:async";
import 'dart:convert';
import 'package:http/http.dart' as http;
//TODO: to be replaced with a way of hiding api key
const String apiKey = '91c86752769af03ca919b23664114cda';
abstract class Handler {
  Future<dynamic> requestGeolocationData(String? cityName) async {}
  Future<dynamic> requestWeatherData(
      String? input, List<dynamic> cords) async {}
}

class RequestHandler implements Handler {
  const RequestHandler();
  
  //use to limit number of results in geocoder api call
  //1 means it only takes the top result
  static const int _limit = 1;

  @override
  Future<dynamic> requestGeolocationData(String? cityName) async {

    //geocoder url format
    //http://api.openweathermap.org/geo/1.0/direct?q={city name},{state code},{country code}&limit={limit}&appid={API key}
    //country code = ISO 3166 codes, state code is for US only, limit is # of results returned
    Uri geocodeUri = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=$_limit&appid=$apiKey');
    //api call to geocoder
    http.Response geocoderResponse = await http.get(geocodeUri);
    //1 size list created by json.decode with map inside if valid
    dynamic returnList = (jsonDecode(geocoderResponse.body));
    return returnList;
  }


  @override
  Future<dynamic> requestWeatherData(String? input, List<dynamic> cords) async {
    //api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API key}
    Uri weatherUri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${cords[0]}&lon=${cords[1]}&appid=$apiKey');
    //API call to openweather, sends back a json.
    http.Response weatherResponse = await http.get(weatherUri);
    return weatherResponse;
  }
}
