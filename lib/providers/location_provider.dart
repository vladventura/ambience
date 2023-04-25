import 'package:ambience/models/location_model.dart';
import 'package:ambience/utils.dart';
import 'package:flutter/material.dart';
import "package:ambience/weatherEntry/weather_entry.dart";

class LocationProvider with ChangeNotifier {
  LocationModel? _foundLocation;

  Future<void> loadLocation() async {
    _foundLocation = await Utils.loadFromLocationFile();
  }

  LocationModel? get location {
    return _foundLocation;
  }

  void setLocation(Map<String, dynamic> incoming) async {
    _foundLocation = LocationModel.fromJson(incoming);
    if (_foundLocation != null) {
      //override null safety, since we comfirmed it is not null and cast to string
      //use this when cityID code infrastructure is setup
      String cityID = "${_foundLocation!.id}";
      //use this when cityID code infrastructure is setup
      //await WeatherEntry.updateLocInfo(cityID);
      
      //Using null assertion since confirmed to be non-null at this point
      //remove this once city ID system is in place, this for legacy support.
      await WeatherEntry.updateLocInfo(_foundLocation!.name);
    }
    notifyListeners();
  }
}
