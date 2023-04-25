import 'package:ambience/models/location_model.dart';
import 'package:flutter/material.dart';

class LocationProvider with ChangeNotifier {
  LocationModel? _foundLocation;

  LocationModel? get location {
    return _foundLocation;
  }

  void setLocation(Map<String, dynamic> incoming) {
    _foundLocation = LocationModel.fromJson(incoming);
    notifyListeners();
  }
}
