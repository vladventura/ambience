import 'package:ambience/GUI/wallpaperobj.dart';
import 'package:ambience/utils.dart';
import 'package:ambience/weatherEntry/weather_entry.dart';
import 'package:flutter/material.dart';

class WallpaperObjProvider with ChangeNotifier {
  List<WallpaperObj>? _wallpaperObjects;
  WallpaperObj? currentEditWallpaper;

  Future<void> loadWallpaperObjs() async {
    _wallpaperObjects = await Utils.listSavedWallpapers();
  }

  List<WallpaperObj>? get wallpaperObjects {
    debugPrint("get => wallpaperObjects");
    debugPrint(_wallpaperObjects.toString());
    return _wallpaperObjects;
  }

  void reloadWallpaperObjList() async {
    _wallpaperObjects = await Utils.listSavedWallpapers();
    debugPrint("Listeners notified");
    notifyListeners();
  }

  void setWallpaperObjs(Map<int, WallpaperObj> input) {
    _wallpaperObjects = input.values.toList();
    notifyListeners();
  }

  void removeEntry(int id) async {
    debugPrint("Delete called!");
    Map<int, WallpaperObj> temp =
        Map<int, WallpaperObj>.from(_wallpaperObjects!.asMap());
    // Null guard
    if (temp[id] == null) return;
    for (WeatherEntry entry in temp[id]!.entries) {
      await WeatherEntry.deleteRule(entry.idSchema);
    }
    temp[id]!.entries.clear();
    temp.remove(id);
    _wallpaperObjects = await Utils.listSavedWallpapers();
    notifyListeners();
  }

  void removeRules(int id) async {
    Map<int, WallpaperObj> t =
        Map<int, WallpaperObj>.from(_wallpaperObjects!.asMap());
    for (WeatherEntry entry in t[id]!.entries) {
      await WeatherEntry.deleteRule(entry.idSchema);
    }
    t[id]!.entries.clear();
    t.remove(id);
    _wallpaperObjects = await Utils.listSavedWallpapers();
    notifyListeners();
  }

  void setCurrentEditWallpaper(WallpaperObj wp) {
    currentEditWallpaper = wp;
    notifyListeners();
  }
}
