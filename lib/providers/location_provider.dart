import 'package:ambience/models/location_model.dart';
import 'package:flutter/material.dart';
import "package:ambience/weatherEntry/weather_entry.dart";

class LocationProvider with ChangeNotifier {
  LocationModel? _foundLocation;

  LocationModel? get location {
    return _foundLocation;
  }

  void setLocation(Map<String, dynamic> incoming) async{
    _foundLocation = LocationModel.fromJson(incoming);
    if (_foundLocation != null) {
      //override null safety, since we comfirmed it is not null and cast to string
      String cityID = "${_foundLocation!.id}";
      //updates the entries in the json to have the new location information.
      await WeatherEntry.updateLocInfo(cityID);
    }
    notifyListeners();
  }
}
