import "dart:io";
import "package:ambience/weatherEntry/weather_entry.dart";
import "package:flutter/material.dart";
import 'package:workmanager/workmanager.dart';


@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print(
        "Native called background task: $task"); //simpleTask will be emitted here.
        
    return Future.value(true);
  });
}

class Daemon {
  //schedules daemons with the current platform
  static void daemonSpawner(WeatherEntry ruleObj) async {
    String current = Directory.current.path;
    //replace spaces with underscore to keep mutli-word arguments together in commandline
    String name = ruleObj.idSchema.replaceAll(" ", "_");
    String city = ruleObj.city.replaceAll(" ", "_");
    TimeOfDay time = ruleObj.startTime;
    int dow = ruleObj.dayOfWeek.index;
    if (Platform.isWindows) {
      //Turn time in a 24 hour formatted string that is acceptable by task scheduler command
      String formatedTime =
          '${time.hour.toString().padLeft(2, '0')}:${time.hour.toString().padLeft(2, '0')}';
      //flag use to trigger different modes of the powershell script
      //run powershell script to schedule tasks(daemon)
      var proc = await Process.run('PowerShell.exe', [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        '$current\\winTaskSetter.ps1',
        name,
        city,
        formatedTime,
        '$dow'
      ]);

      debugPrint("winTaskSetter.ps1 standard output: ${proc.stdout}");
      debugPrint("winTaskSetter.ps1 standard error output: ${proc.stderr}");
    } else if (Platform.isLinux) {
      var proc = await Process.run('bash', [
        '-c',
        '$current/UbuntuCronScheduler.sh "$name" "$city" ${time.hour} ${time.minute} $dow'
      ]);
      debugPrint(
          "UbuntuCronScheduler.sh standard error output: ${proc.stderr}");
    } else if (Platform.isAndroid) {
      Workmanager().initialize(
          callbackDispatcher, // The top level function, aka callbackDispatcher
          isInDebugMode:
              true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
          );
      Workmanager().registerOneOffTask("task-identifier", "simpleTask");
    } else {
      debugPrint("Platform not supported");
    }
  }

  //removes daemons from the current platform
  static void daemonBanisher(String idSchema) async {
    String current = Directory.current.path;
    if (Platform.isWindows) {
      var proc = await Process.run('PowerShell.exe', [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        '$current\\winTaskRemover.ps1',
        idSchema
      ]);

      debugPrint("winTaskRemover.ps1 standard output: ${proc.stdout}");
      debugPrint("winTaskRemover.ps1 standard error output: ${proc.stderr}");
    } else if (Platform.isLinux) {
      var proc = await Process.run(
          'powershell.exe', ['$current/UbuntuCronRemover.sh "$idSchema"']);

      debugPrint("UbuntuCronRemover.sh standard output: ${proc.stdout}");
      debugPrint("UbuntuCronRemover.sh standard error output: ${proc.stderr}");
    } else if (Platform.isAndroid) {
      debugPrint("Android daemonBanisher not implemented yet");
    } else {
      debugPrint("Platform is not supported");
    }
  }
}
