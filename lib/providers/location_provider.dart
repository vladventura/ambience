import 'package:ambience/firebase/fire_handler.dart';
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
      
      await Utils.saveToLocationFile(_foundLocation!);
      await WeatherEntry.updateLocInfo(cityID);
      //fire handler commented out for rapid offline testing.
      //fire handler auth instance
      FireHandler hand = FireHandler();
      //upload this new location data to the cloud
      await hand.uploadLocJSON();
    }
    notifyListeners();
  }
}
