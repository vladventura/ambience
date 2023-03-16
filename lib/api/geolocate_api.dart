//install http.dart via 'flutter pub add http'
import 'package:ambience/handlers/request_handler.dart';

//currently takes api key & city name and returns lat & lon
//but in future taking zip code / country code(ISO standard) may be more accurate
Future<List<dynamic>> geolocate(String? input,
    {Handler handler = const RequestHandler()}) async {
  Map coderMap;

  //list is empty if given city name could not be resolved
  dynamic retList = await handler.requestGeolocationData(input);
  if (retList.isEmpty) {
    return [];
  } else {
    //extract map from list
    coderMap = retList[0];
  }
  return [coderMap['lat'], coderMap['lon']];
}
