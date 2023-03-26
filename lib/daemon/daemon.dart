import "dart:io";
import "package:ambience/weatherEntry/weather_entry.dart";
import "package:flutter/material.dart";

class Daemon {
  static void daemonSpawner(WeatherEntry ruleObj) async {
    String current = Directory.current.path;
    String name = ruleObj.idSchema;
    String city = ruleObj.city;
    TimeOfDay time = ruleObj.startTime;
    int dow = ruleObj.dayOfWeek.index;
    if (Platform.isWindows) {
      //Turn time in a 24 hour formatted string that is acceptable by task scheduler command
      String formatedTime =
          '${time.hour.toString().padLeft(2, '0')}:${time.hour.toString().padLeft(2, '0')}';
      
      //run powershell script to schedule tasks(daemon)
      var proc = await Process.run('powershell.exe', [
        '$current\\winTaskSetter.ps1 "$name" "$city" "$formatedTime" "$dow"'
      ]);

      debugPrint("winTaskSetter.ps1 standard output: ${proc.stdout}");
      debugPrint("winTaskSetter.ps1 standard error output: ${proc.stderr}");
    } else if (Platform.isLinux) {
        var proc = await Process.run('bash', [
        '-c',
        '$current/UbuntuCronScheduler.sh "$name" "$city" ${time.hour} ${time.minute} $dow'
      ]);
         debugPrint("UbuntuCronScheduler.sh standard error output: ${proc.stderr}");
    } else if (Platform.isAndroid) {
      debugPrint("Android daemonSpawner not implemented yet");
    } else {
      debugPrint("Platform not supported");
    }
  }
}
