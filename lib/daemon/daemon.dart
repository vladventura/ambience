import "dart:io";
import "package:flutter/foundation.dart";
// flutter pub add workmanager
import 'package:workmanager/workmanager.dart';

//required for Flutter 3.1+
@pragma('vm:entry-point')
//must be top level or static function
void callbackDispatchter() {
  Workmanager().executeTask((taskName, inputData) {
    if (taskName == 'subtask') {
      debugPrint("Debug: Subtask!");
      return Future.value(true);
    }
    final now = DateTime.now();
    final xAdded = now.add(const Duration(minutes: 1));
    final difference = xAdded.difference(now);
    //min perodic task time is 15 minutes, else do a delayed one off
    debugPrint("Debug: Time now: $now");
    debugPrint("Debug: Time xAdded: $xAdded");
    debugPrint("Debug: Time difference: $difference");

    if (difference.inMinutes < 15) {
      debugPrint("Debug: Print Under 15 minutes, try to update task");
      Workmanager().registerOneOffTask("subtask", "subtask",
          initialDelay: const Duration(minutes: 1));
    }

    debugPrint('Debug: Task executed: $taskName, $now');
    debugPrint('Debug: Input data: $inputData');
    return Future.value(true);
  });
}

class Daemon {
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
        ' $current\\winTaskSetter.ps1 "$cityName" ${splitTime[0]}:${splitTime[1]}${splitTime[2]}'
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
}
