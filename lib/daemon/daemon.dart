import "dart:io";
import "package:flutter/foundation.dart";

class Daemon {
  //time format: xx:xxam or xx:xxpm e.g. 10:01am or 10:01pm.
  //Note: can do just do xx<am or pm> e.g. 10am
  static void init(String? cityName, String time) async {

    String current = Directory.current.path;
    if (cityName == null) {
      return;
    }
    if (Platform.isWindows) {
      var proc = await Process.run(
          'powershell.exe', [' $current\\winTaskSetter.ps1 "$cityName" $time']);
      debugPrint("process standard error output: ${proc.stderr}");
    }
    //notice: Requires Linux command 'xvfb' to be installed function
    else if (Platform.isLinux) {
      var proc = await Process.run('bash', ['-c', '$current/UbuntuCronScheduler.sh "$cityName"']);
      debugPrint("process standard error output: ${proc.stderr}");
    } else {
      debugPrint(
          "Other platform implementions are not included in this prototype atm");
    }
  }
}
