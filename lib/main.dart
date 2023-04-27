import 'dart:async';
import 'dart:io';
import 'package:ambience/models/weather_model.dart';
import 'package:ambience/GUI/location_request.dart';
import 'package:ambience/providers/location_provider.dart';
import 'package:ambience/storage/storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ambience/handlers/file_handler.dart';
import 'package:ambience/handlers/wallpaper_handler.dart';
import 'package:ambience/weatherEntry/weather_entry.dart';
import 'package:flutter/material.dart';
import 'package:ambience/api/weather.dart';
import "package:ambience/daemon/daemon.dart";
import 'package:ambience/firebase/fire_handler.dart';
import "package:ambience/GUI/create.dart";
import "package:ambience/GUI/list.dart";
import "package:ambience/GUI/login.dart";
import "package:ambience/GUI/main screen.dart";
import 'package:provider/provider.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:convert';
import "package:ambience/constants.dart" as constants;

void main(List<String> args) async {
  await dotenv.load();
  FireHandler.initialize();

  if (args.isEmpty) {
    runZonedGuarded(() {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => LocationProvider(),
            ),
          ],
          child: const MyApp(),
        ),
      );
    }, (error, stack) {
      print('Unhandled error: $error');
      print(stack);
    });
  } else {
    if (args[0] == 'boot') {
      await Daemon.bootWork();
    } else {
      String idSchema = args[1];
      var ruleObj = await WeatherEntry.getRule(idSchema);
      String wallpath = ruleObj.wallpaperFilepath;
      WeatherModel weatherData = await Daemon.getWeatherDataForecast(ruleObj);
      await WallpaperHandler.setWallpaper(wallpath);
      //await Daemon.weatherCheck(ruleObj, weatherData);
      // explicit exit, else Windows task scheduler will never know the task ended
      exit(0);
    }
    // explicit exit, else Windows task scheduler will never know the task ended
    exit(0);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async {
    await context.read<LocationProvider>().loadLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginApp(),
          '/Home': (context) => const MainApp(),
          '/List': (context) => ListApp(),
          '/LocationRequest': (context) => const LocationRequest(),
        });
  }
}
