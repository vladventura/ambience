import "dart:io";
import "package:ambience/constants.dart" as constants;
import "package:ambience/models/weather_model.dart";
import "package:ambience/storage/storage.dart";
import "package:ambience/weatherEntry/weather_entry.dart";
import "package:flutter/material.dart";
import 'package:ambience/handlers/wallpaper_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:ambience/api/weather_api.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+

class Daemon {
  //Boot daemon function to read all ruleobjs to check if any have been missed.
  static Future<void> bootWork() async {
    Map<String, WeatherEntry> ruleMap = await WeatherEntry.getRuleList();
    //get map from map of maps
    List<dynamic> entryList = ruleMap.values.toList();
    //get weather data(assume location is shared across all rules)
    WeatherModel weatherData = await getWeatherDataForecast(entryList[0]);
    for (int i = 0; i < entryList.length; i++) {
      await weatherCheck(entryList[i], weatherData);
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
  static Future<void> daemonBoot() async {
    String current = Directory.current.path;
    String daemonMode = 'boot';
    if (Platform.isWindows) {
      File checkExist = File("$current\\winTaskSetter.ps1");
      //check if script exists
      if (!(await checkExist.exists())) {
        throw ("winTaskSetter.ps1 does not exist");
      }
      var proc = await Process.run('PowerShell.exe', [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        '$current\\winTaskSetter.ps1',
        daemonMode,
        constants.bootDaemonID,
      ]);
      debugPrint("winTaskSetter.ps1 standard output: ${proc.stdout}");
      debugPrint("winTaskSetter.ps1 standard error output: ${proc.stderr}");

      if (proc.exitCode == 0) {
        throw "winTaskSetter.ps1 did not execute successfully";
      }
    } else if (Platform.isLinux) {
      File checkExist = File("$current/UbuntuCronScheduler.sh");
      //check if script exists
      if (!(await checkExist.exists())) {
        throw "UbuntuCronScheduler.sh does not exist";
      }
      var proc = await Process.run('bash', [
        '-c',
        '$current/UbuntuCronScheduler.sh "$daemonMode" "${constants.bootDaemonID}"'
      ]);
      debugPrint(
          "UbuntuCronScheduler.sh standard error output: ${proc.stderr}");
      if (proc.exitCode == 0) {
        throw ("UbuntuCronScheduler.sh did not execute successfully");
      }
    } else if (Platform.isAndroid) {
      debugPrint("Android boot daemon is not implemented yet!");
    }
  }

  //schedules daemons with the current platform
  static Future<void> daemonSpawner(WeatherEntry ruleObj) async {
    String current = Directory.current.path;
    //replace spaces with underscore to keep mutli-word arguments together in commandline
    String id = ruleObj.idSchema.replaceAll(" ", "_");
    TimeOfDay ruleTime = ruleObj.startTime;
    int dow = ruleObj.dayOfWeek.index;
    //daemon mode is always normal for daemonspawner
    if (Platform.isWindows) {
      File checkExist = File("$current\\winTaskSetter.ps1");
      if (!(await checkExist.exists())) {
        throw ("winTaskSetter.ps1 at ${checkExist.path}");
      }
      //Turn time in a 24 hour formatted string that is acceptable by task scheduler command
      String formatedTime =
          '${ruleTime.hour.toString().padLeft(2, '0')}:${ruleTime.minute.toString().padLeft(2, '0')}';
      //flag use to trigger different modes of the powershell script
      //run powershell script to schedule tasks(daemon)
      var proc = await Process.run('PowerShell.exe', [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        '$current\\winTaskSetter.ps1',
        constants.normDaemonMode,
        id,
        formatedTime,
        '$dow'
      ]);

      debugPrint("winTaskSetter.ps1 standard output: ${proc.stdout}");
      debugPrint("winTaskSetter.ps1 standard error output: ${proc.stderr}");
      
    } else if (Platform.isLinux) {
      File checkExist = File("$current/UbuntuCronScheduler.sh");
      //check if script exists
      if (!(await checkExist.exists())) {
        throw "UbuntuCronScheduler.sh does not exist";
      }
      var proc = await Process.run('bash', [
        '-c',
        '$current/UbuntuCronScheduler.sh "${constants.normDaemonMode}" "$id" ${ruleTime.hour} ${ruleTime.minute} $dow'
      ]);
      debugPrint(
          "UbuntuCronScheduler.sh standard error output: ${proc.stderr}");

      if (proc.exitCode != 0) {
        throw "UbuntuCronScheduler.sh did not execute successfully";
      }
    } else if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
      Duration offset = calcTimeOffset(ruleTime, dow);
      DateTime start = DateTime.now();
      start.add(offset);
      //alarm manager uses 32 bit ints(will accept 64 bit int, but crashs if bit length is > 32), dart uses 64 bit
      //Take arbitery amount of last digits of idschema, which uses
      //seconds since epoc, last digits because those are the most likely to be different
      String last8 = id.substring(id.length - 8);
      int last8Int = int.parse(last8);
      await AndroidAlarmManager.periodic(
          const Duration(days: 7), last8Int, androidWeatherCheck,
          startAt: start,
          rescheduleOnReboot: true,
          allowWhileIdle: true,
          params: {"ruleobj": ruleObj});
    } else {
      debugPrint("Platform not supported");
    }
  }

  //removes daemons from the current platform
  static Future<void> daemonBanisher(String idSchema) async {
    String current = Directory.current.path;
    if (Platform.isWindows) {
      File checkExist = File("$current\\winTaskRemover.ps1");
      //check if script exists
      if (!(await checkExist.exists())) {
        throw "winTaskRemover.ps1 does not exist";
      }
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
      File checkExist = File("$current/UbuntuCronRemover.sh");
      //check if script exists
      if (!(await checkExist.exists())) {
        throw "UbuntuCronRemover.sh does not exist";
      }
      var proc = await Process.run(
          'powershell.exe', ['$current/UbuntuCronRemover.sh "$idSchema"']);

      debugPrint("UbuntuCronRemover.sh standard output: ${proc.stdout}");
      debugPrint("UbuntuCronRemover.sh standard error output: ${proc.stderr}");
      if (proc.exitCode == 0) {
        throw "UbuntuCronRemover.sh does not execute successfully";
      }
    } else if (Platform.isAndroid) {
      String last8 = idSchema.substring(idSchema.length - 8);
      int last8Int = int.parse(last8);
      AndroidAlarmManager.cancel(last8Int);
    } else {
      debugPrint("Platform is not supported");
    }
  }

  //checks for desired weather condition and changes wallpaper if it is.
  static Future<void> weatherCheck(
      WeatherEntry ruleObj, WeatherModel weatherData) async {
    //check if wallpaper change is needed
    bool match = ruleObj.compareWeather(weatherData.weathers[0].name);
    if (match) {
      WallpaperHandler.setWallpaper(ruleObj.wallpaperFilepath);
    }
  }

  //function wrapper for Android, acts as callback function for Android Alarm Manager Plus(AAMP)
  //takes int,map because that's the format AAMP expects
  static void androidWeatherCheck(int id, Map params) async {
    String key = "ruleobj";
    if (params.containsKey(key)) {
      WeatherEntry ruleobj = params[key];
      WeatherModel weatherData = await getWeatherDataForecast(ruleobj);
      await weatherCheck(ruleobj, weatherData);
    } else {
      debugPrint(
          "Android daemon couldn't find ruleobj in androidWeatherCheck!");
    }
  }

  static Future<WeatherModel> getWeatherDataForecast(
      WeatherEntry ruleObj) async {
    //get current time, so data fetch time doesn't effect finding the most up to date weather data
    var nowTime = DateTime.now();
    //if cannot access weather api
    if ((await getAndWriteWeatherForecastD(ruleObj.cityId)) == false) {
      debugPrint(
          "Cannot access online weather data, checking offline weather data. -Daemon.weathercheck");
    }
    Storage store = Storage();
    //get offline data
    var weatherJson = await (store.readAppDocJson(constants.weatherDataPath));
    if (weatherJson == 'failed') {
      debugPrint("Cannot read weatherData.JSON,exiting -Daemon.weathercheck");
      //at this point the daemon cannot do it's job
      throw "Cannot access online or offline weatherData";
    }
    //get the list of maps of weather data from the JSON
    List<dynamic> respDecode = weatherJson['list'];
    //Take the map from each list element and parse using Weathermodel
    List<WeatherModel> allWeatherData =
        respDecode.map((e) => WeatherModel.fromJson(e)).toList();
    int i;
    //find most up to date weather data
    for (i = 0; i < allWeatherData.length; i++) {
      var timeStamp = DateTime.parse(allWeatherData[i].datetimeText).toLocal();
      //stop once, most up to date weather is found
      if (!(nowTime.isAfter(timeStamp))) {
        break;
      }
    }
    //edge case out of bounds prevention
    if (i == allWeatherData.length) {
      i = i - 1;
    }
    //return the
    return allWeatherData[i];
  }
}
