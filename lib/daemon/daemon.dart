import "dart:io";
import "package:ambience/weatherEntry/weather_entry.dart";
import "package:flutter/material.dart";
import 'package:workmanager/workmanager.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  //determine time offset for android, move to own function later

  Workmanager().executeTask((task, inputData) {
    switch (task) {
      case "ambience_daemon":
        print("Ambience daemon triggered!");
        String city = inputData?['city'];
        String targetWeather = inputData?['targetWeather'];

        break;
    }

    return Future.value(true);
  });
}

class Daemon {
  //schedules daemons with the current platform
  static void daemonSpawner(WeatherEntry ruleObj) async {
    String current = Directory.current.path;
    //replace spaces with underscore to keep mutli-word arguments together in commandline
    String id = ruleObj.idSchema.replaceAll(" ", "_");
    String city = ruleObj.city.replaceAll(" ", "_");
    TimeOfDay ruleTime = ruleObj.startTime;
    int dow = ruleObj.dayOfWeek.index;
    if (Platform.isWindows) {
      //Turn time in a 24 hour formatted string that is acceptable by task scheduler command
      String formatedTime =
          '${ruleTime.hour.toString().padLeft(2, '0')}:${ruleTime.hour.toString().padLeft(2, '0')}';
      //flag use to trigger different modes of the powershell script
      //run powershell script to schedule tasks(daemon)
      var proc = await Process.run('PowerShell.exe', [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        '$current\\winTaskSetter.ps1',
        id,
        city,
        formatedTime,
        '$dow'
      ]);

      debugPrint("winTaskSetter.ps1 standard output: ${proc.stdout}");
      debugPrint("winTaskSetter.ps1 standard error output: ${proc.stderr}");
    } else if (Platform.isLinux) {
      var proc = await Process.run('bash', [
        '-c',
        '$current/UbuntuCronScheduler.sh "$id" "$city" ${ruleTime.hour} ${ruleTime.minute} $dow'
      ]);
      debugPrint(
          "UbuntuCronScheduler.sh standard error output: ${proc.stderr}");
    } else if (Platform.isAndroid) {
      debugPrint("In android case");
      Workmanager().initialize(
          callbackDispatcher, // The top level function, aka callbackDispatcher
          isInDebugMode:
              true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
          );

      //android tasks are timer base, so calculate offset from now and ruletime
      Duration offset = calcTimeOffset(ruleTime, dow);
      if (offset == Duration.zero) {
        debugPrint("In android case");

        //if offset is 0, register this task, for this time, every week.
        Workmanager().registerPeriodicTask(id, "ambience_daemon",
            frequency: const Duration(days: 7),
            inputData: {
              "city": city,
              "targetWeather": ruleObj.weatherCondition.name
            });
      }
      //else it's a one offtask
      Workmanager().registerOneOffTask(id, "ambience_daemon",
          initialDelay: offset,
          inputData: {
            "city": city,
            "targetWeather": ruleObj.weatherCondition.name
          });
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

  static Duration calcTimeOffset(TimeOfDay ruleTime, int dow) {
    Duration durationBetween = Duration(
        minutes: ruleTime.minute - TimeOfDay.now().minute,
        hours: ruleTime.hour - TimeOfDay.now().hour);

    int currentDayofWeek = DateTime.now().weekday;
    //adjust to weather_entry enum format
    if (currentDayofWeek == 7) {
      currentDayofWeek = 0;
    }
    int daysBetween = dow - currentDayofWeek;
    //if negative, then the day has already passed, schedule for next week
    if (daysBetween < 0) {
      daysBetween += 7;
    }
    int offset = daysBetween * 24 * 60 + durationBetween.inMinutes;
    //if offset is negative, schedule to next week(This is another edge case of next week)
    if (offset < 0) {
      offset += 7 * 24 * 60;
    }
    return Duration(minutes: offset);
  }
}
