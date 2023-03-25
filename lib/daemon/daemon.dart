import "dart:io";
import "package:ambience/weatherEntry/weather_entry.dart";
import "package:flutter/material.dart";

class Daemon {
  static void daemonSpawner(WeatherEntry ruleObj) async {
    String current = Directory.current.path;
    if (Platform.isWindows) {
      debugPrint("daemonSpawner detected Windows platform");
      String name = ruleObj.idSchema;
      String city = ruleObj.city;
      TimeOfDay time = ruleObj.startTime;
      String formatedTime =
          '${time.hour.toString().padLeft(2, '0')}:${time.hour.toString().padLeft(2, '0')}';
      int dow = ruleObj.dayOfWeek.index;
      debugPrint(" name:$name city:$city formatedTime:$formatedTime dow:$dow");

      //run powershell script to schedule tasks(daemon)
      var proc = await Process.run('powershell.exe', [
        '$current\\winTaskSetter.ps1 "$name" "$city" "$formatedTime" "$dow"'
      ]);

      debugPrint("winTaskSetter.ps1 standard output: ${proc.stdout}");
      debugPrint("winTaskSetter.ps1 standard error output: ${proc.stderr}");
    } else if (Platform.isLinux) {
      debugPrint("Linux daemonSpawner not implemented yet");
    } else if (Platform.isAndroid) {
      debugPrint("Android daemonSpawner not implemented yet");
    } else {
      debugPrint("Platform not supported");
    }
  }
/*Old proof of concept code here for reference for now
  //time format: xx:xxam or xx:xxpm e.g. 10:01am or 10:01pm.
  //Note: can do just do xx<am or pm> e.g. 10am
  static void init(String? cityName, String time) async {
    //parse time arugment(hh, mm, am/pm)
    List<String> splitTime = time.split(':');
    String current = Directory.current.path;
    if (cityName == null) {
      return;
    }
    if (Platform.isWindows) {
      var proc = await Process.run('powershell.exe', [
        ' $current\\winTaskSetter.ps1 "ambienceDaemon" "$cityName" ${splitTime[0]}:${splitTime[1]}${splitTime[2]}'
      ]);
      debugPrint("process standard error output: ${proc.stderr}");
    }
    //notice: Requires Linux command 'xvfb' to be installed function
    else if (Platform.isLinux) {
      if (splitTime[2] == 'am') {
        //format midnight for cron job
        if (int.parse(splitTime[0]) == 12) {
          splitTime[0] = "0";
        }
      }
      //else pm, and not noon edgecase
      else if (splitTime[0] != '12') {
        //convert to 24 hour format
        int temp = int.parse(splitTime[0]) + 12;
        splitTime[0] = temp.toString();
      }
      var proc = await Process.run('bash', [
        '-c',
        '$current/UbuntuCronScheduler.sh "$cityName" ${splitTime[0]} ${splitTime[1]}'
      ]);
      debugPrint("process standard error output: ${proc.stderr}");
    } else if (Platform.isAndroid) {
      //test stub only rn
    } else {
      debugPrint(
          "Other platform implementions are not included in this prototype atm");
    }
  }
*/
}
