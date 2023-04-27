import 'dart:async';
import 'dart:io';
import 'package:ambience/GUI/create.dart';
import 'package:ambience/models/weather_model.dart';
import 'package:ambience/GUI/location_request.dart';
import 'package:ambience/providers/location_provider.dart';
import 'package:ambience/providers/wallpaper_obj_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ambience/weatherEntry/weather_entry.dart';
import 'package:flutter/material.dart';
import "package:ambience/daemon/daemon.dart";
import 'package:ambience/firebase/fire_handler.dart';
import "package:ambience/GUI/list.dart";
import "package:ambience/GUI/login.dart";
import "package:ambience/GUI/main screen.dart";
import 'package:provider/provider.dart';

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
            ChangeNotifierProvider(
              create: (_) => WallpaperObjProvider(),
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
      await Daemon.bootWork();
    } else {
      String idSchema = args[1];
      var ruleObj = await WeatherEntry.getRule(idSchema);
      WeatherModel weatherData = await Daemon.getWeatherDataForecast(ruleObj);
      await Daemon.weatherCheck(ruleObj, weatherData);
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
    LocationProvider lp = context.read<LocationProvider>();
    WallpaperObjProvider wop = context.read<WallpaperObjProvider>();
    await lp.loadLocation();
    await wop.loadWallpaperObjs();
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
        '/List': (context) => const ListApp(),
        '/LocationRequest': (context) => const LocationRequest(),
        '/Create': (context) => const CreateApp(),
      },
    );
  }
}
