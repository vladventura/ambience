import "dart:io";
import "package:flutter/foundation.dart";

class Daemon {
  //time format: xx:xxam or xx:xxpm e.g. 10:01am or 10:01pm.
  //Note: can do just do xx<am or pm> e.g. 10am
  static void init(String? cityName, String time) async {
    if (cityName == null) {
      return;
    }
    if (Platform.isWindows) {
      String current = Directory.current.path;
      var proc = await Process.run('powershell.exe',
          [' $current\\winTaskSetter.ps1 $cityName $time']);
      debugPrint("proc results: ${proc.stderr}");
    } else {
      debugPrint(
          "Other platform implementions are not included in this prototype atm");
    }
  }
}
