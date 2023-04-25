import 'dart:async';
import 'dart:io';
import 'package:ambience/models/weather_model.dart';
import 'package:ambience/GUI/location_request.dart';
import 'package:ambience/providers/location_provider.dart';
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
import 'package:ambience/api/weather.dart';

void main(List<String> args) async {
  await dotenv.load();
  FireHandler.initialize();
  FireHandler test = FireHandler();
  //if not args passed, GUI MODE
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
      print(error);
      print(stack);
    });
  }
  //if there are command line args, GUI-Less mode
  else {
    //boot daemon case
    if (args[0] == 'boot') {
      Daemon.bootWork();
    } else {
      String idSchema = args[1];
      var ruleObj = await WeatherEntry.getRule(idSchema);
      WeatherModel weatherData = await Daemon.getWeatherData(ruleObj);
      Daemon.weatherCheck(ruleObj, weatherData);
    }
    //explict exit, else Windows task scheduler will never know the task ended
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
