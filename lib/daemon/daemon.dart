import "dart:io";
import "package:ambience/constants.dart";
import "package:ambience/models/weather_model.dart";
import "package:ambience/storage/storage.dart";
import "package:ambience/weatherEntry/weather_entry.dart";
import "package:flutter/material.dart";
import 'package:workmanager/workmanager.dart';
import 'package:ambience/handlers/wallpaper_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
/*
void callbackDispatcher() {
  //determine time offset for android, move to own function later

  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "ambience_daemon":
        print("Ambience daemon triggered!");
        String city = inputData?['city'];
        String targetWeather = inputData?['targetWeather'];
        String input = inputData?['wallpaper'];
        if (input != 'null') {
          await WallpaperHandler.setWallpaper(input);
        }
        break;
    }

    return Future.value(true);
  });
}
*/

//Visual feedback for Android testing
void wallpaperChangeTest(int id, Map params) async {
  debugPrint("change wallpaper running!");
  if (params['wallpaper'] != 'null') {
    await WallpaperHandler.setWallpaper(params['wallpaper']);
  }
}

class Daemon {
  //Boot daemon function to read all ruleobjs to check if any have been missed.
  static void bootWork() async {
    Map<String, WeatherEntry> ruleMap = await WeatherEntry.getRuleList();
    //get map from map of maps
    List<dynamic> entryList = ruleMap.values.toList();
    for (int i = 0; i < entryList.length; i++) {
      weatherCheck(entryList[i]);
    }
  }

  //calculate task offset for Android Work Mananger.
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

  //A daemon that checks all rules on boots
  static void daemonBoot() async {
    String current = Directory.current.path;
    String daemonMode = 'boot';
    if (Platform.isWindows) {
      var proc = await Process.run('PowerShell.exe', [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        '$current\\winTaskSetter.ps1',
        daemonMode,
        bootDaemonID,
      ]);
      debugPrint("winTaskSetter.ps1 standard output: ${proc.stdout}");
      debugPrint("winTaskSetter.ps1 standard error output: ${proc.stderr}");
    } else if (Platform.isLinux) {
      var proc = await Process.run('bash', [
        '-c',
        '$current/UbuntuCronScheduler.sh "$daemonMode" "$bootDaemonID"'
      ]);
      debugPrint(
          "UbuntuCronScheduler.sh standard error output: ${proc.stderr}");
    } else if (Platform.isAndroid) {
      debugPrint("Android boot daemon is not implemented yet!");
    }
  }

  //schedules daemons with the current platform
  static void daemonSpawner(WeatherEntry ruleObj,
      [String wallpaperpath = "null"]) async {
    String current = Directory.current.path;
    //replace spaces with underscore to keep mutli-word arguments together in commandline
    String id = ruleObj.idSchema.replaceAll(" ", "_");
    TimeOfDay ruleTime = ruleObj.startTime;
    int dow = ruleObj.dayOfWeek.index;
    //daemon mode is always normal for daemonspawner
    const String daemonMode = 'n';
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
        daemonMode,
        id,
        formatedTime,
        '$dow'
      ]);

      debugPrint("winTaskSetter.ps1 standard output: ${proc.stdout}");
      debugPrint("winTaskSetter.ps1 standard error output: ${proc.stderr}");
    } else if (Platform.isLinux) {
      var proc = await Process.run('bash', [
        '-c',
        '$current/UbuntuCronScheduler.sh "$daemonMode" "$id" ${ruleTime.hour} ${ruleTime.minute} $dow'
      ]);
      debugPrint(
          "UbuntuCronScheduler.sh standard error output: ${proc.stderr}");
    } else if (Platform.isAndroid) {
      debugPrint("In android case");
      await AndroidAlarmManager.initialize();
      DateTime minutefuture = DateTime.now();
      minutefuture = minutefuture.add(const Duration(minutes: 1));

      await AndroidAlarmManager.periodic(
          const Duration(minutes: 3), 0, wallpaperChangeTest,
          startAt: minutefuture,
          rescheduleOnReboot: true,
          params: {"wallpaper": wallpaperpath});

/* Android work manager code[currently replaced by AndroidAlarmManager]
      Workmanager().initialize(
          callbackDispatcher, // The top level function, aka callbackDispatcher
          isInDebugMode:
              true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
          );

      //android tasks are timer base, so calculate offset from now and ruletime
      Duration offset = calcTimeOffset(ruleTime, dow);
      //for testing only!!!!!
      offset = const Duration(minutes: 1);
      if (offset == Duration.zero) {
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
            "targetWeather": ruleObj.weatherCondition.name,
            'wallpaper': wallpaperpath
          });
  */
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
      AndroidAlarmManager.cancel(0);
    } else {
      debugPrint("Platform is not supported");
    }
  }

  //checks for desired weather condition and changes wallpaper if it is.
  static void weatherCheck(WeatherEntry ruleObj) async {
    //might want to pull the weather parsing, and finding most current as it's own function or addition to some other handler.
    Storage store = Storage();
    var weatherJson = await (store.readAppDocJson(weatherDataPath));
    //get the list of maps of weather data from the JSON
    List<dynamic> respDecode = weatherJson['list'];
    //Take the map from each list element and parse using Weathermodel
    List<WeatherModel> allWeatherData =
        respDecode.map((e) => WeatherModel.fromJson(e)).toList();
    //to-do, add backup to parse through offline data and locate up to date data.
    //if current weather condition matches desired weather condition, change wallpaper
    for (int i = 0; i < allWeatherData.length; i++) {
      bool match = ruleObj.compareWeather(allWeatherData[i].weathers[0].name);
      if (match) {
        WallpaperHandler.setWallpaper(ruleObj.wallpaperFilepath);
      }
    }
  }
}
