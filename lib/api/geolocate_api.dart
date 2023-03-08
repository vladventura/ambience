//install http.dart via 'flutter pub add http'
import 'package:http/http.dart' as http;
import 'dart:convert';

//currently takes api key & city name and returns lat & lon
//but in future taking zip code / country code(ISO standard) may be more accurate
geolocate(var apiKey, String? input) async {
  Map coderMap;
  var cityName = input;
  //use to limit number of results in geocoder api call
  //1 means it only takes the top result
  var limit = 1;

  //geocoder url format
  //http://api.openweathermap.org/geo/1.0/direct?q={city name},{state code},{country code}&limit={limit}&appid={API key}
  //country code = ISO 3166 codes, state code is for US only, limit is # of results returned

  var geocodeUrl = Uri.parse(
      'http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=$limit&appid=$apiKey');
  //api call to geocoder
  var geocoderReply = await http.get(geocodeUrl);

  //1 size list created by json.decode with map inside if valid
  var retList = (jsonDecode(geocoderReply.body));
  //list is empty if given city name could not be resolved
  if (retList.isEmpty) {
    return ['failed'];
  } else {
    //extract map from list
    coderMap = retList[0];
  }
  return [coderMap['lat'], coderMap['lon']];
}

