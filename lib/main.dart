import 'package:ambience/handlers/file_handler.dart';
import 'package:ambience/handlers/wallpaper_handler.dart';
import 'package:flutter/material.dart';
//install http.dart via 'flutter pub add http'
import 'package:http/http.dart' as http;
import 'dart:convert';
//install via flutter pub add path_provider
//may need to also enable install loose files on windows developer settings
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

geolocate(var apiKey, String? input) async {
  Map coderMap;
  var cityName = input;
  //use to limit number of results in geocoder api call
  //1 means it only takes the top result
  var limit = 1;

  //geocoder url format
  //http://api.openweathermap.org/geo/1.0/direct?q={city name},{state code},{country code}&limit={limit}&appid={API key}
  //country code = ISO 3166 codes, state code is for US only, limit is # of results returned

  var geocodeUrl = Uri.parse(
      'http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=$limit&appid=$apiKey');
  //api call to geocoder
  var geocoderReply = await http.get(geocodeUrl);

  //1 size list created by json.decode with map inside if valid
  var retList = (jsonDecode(geocoderReply.body));
  //list is empty if given city name could not be resolved
  if (retList.isEmpty) {
    return ['failed'];
  } else {
    //extract map from list
    coderMap = retList[0];
  }
  return [coderMap['lat'], coderMap['lon']];
}

getWeather(String? input) async {
  //to be replaced with a way of hiding api key
  const apiKey = '91c86752769af03ca919b23664114cda';
  //cords = 2 size array with lat and lon, index 0 and 1 respectively
  var cords = await geolocate(apiKey, input);
  //if name couldn't be geolocated
  if (cords[0] == 'failed') {
    debugPrint("Geolocation failed");
    return false;
  }
  //api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API key}
  var weatherUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=${cords[0]}&lon=${cords[1]}&appid=$apiKey');

  //API call to openweather, sends back a json.
  var weatherReply = await http.get(weatherUrl);
  var storage = Storage();
  //.body attribute contains json, write to given file
  await storage.writeAppDocFile(weatherReply.body, 'weatherData.txt');
  //succeeded

  return true;
}

void weather(String? input) async {
  //not fully functional
  //get weather data
  if (await (getWeather(input)) == false) {
    debugPrint("Failed to get Weatherdata!");
  }
  //else successfuly gotten weather data
  var storage = Storage();
  //Reads from give file in AppDoc/Ambience dir and reteurns a decoded JSON as a Dart object
  var weatherData = await storage.readAppDocJson('weatherData.txt');
  //sample of parsing weather data
  //note it is a mix of lists and maps. Hence key and index accesing.
  debugPrint(
      "Found weather for ${weatherData['city']['name']} in ${weatherData['city']['country']}."
      " The weather: ${(weatherData['list'][0])['weather'][0]['description']}.");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _input = "";

  void _pickFile() async {
    // An alternative approach can be the following
    /* 
    String pathToFile = await getImagePathFromPicker();
    if (pathToFile.isNotEmpty) {
      setState(() {
        _input = pathToFile;
      });
    }
    */
    // And we get rid of exceptions
    String pathToFile = "";
    try {
      pathToFile = await getImagePathFromPicker();
    } on NoFileChosenException {
      debugPrint("No files chosen");
    } on FileNotFoundException {
      debugPrint("No path was found for the given file");
    } finally {
      setState(() {
        _input = pathToFile;
      });
    }
  }

  void _setWallpaper() async => await WallpaperHandler.setWallpaper(_input);

  @override
  Widget build(BuildContext context) {
    String? cityInput;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //weather api text field
            // ignore: prefer_const_constructors
            TextField(
              // ignore: prefer_const_constructors
              decoration: InputDecoration(
                // ignore: prefer_const_constructors
                border: OutlineInputBorder(),
                hintText: 'Enter city name to get weather for',
              ),
              onChanged: (text) {
                cityInput = text;
              },
            ),
            ElevatedButton(
                onPressed: () => weather(cityInput),
                child: const Text("Get weather")),
            //open file
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text("Open File"),
            ),
            if (_input.isNotEmpty) Text("Path to file is $_input"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _setWallpaper,
        tooltip: 'Set Wallpaper',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Storage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> get _localDirectoryPath async {
    final path = await _localPath;
    Directory temp = Directory("$path\\Ambience");

    //if doesn't exist
    if (!(await temp.exists())) {
      await temp.create(recursive: true).catchError((e) {
        debugPrint("error with creating Ambience folder");
        //for now return the base path on error, but may be subject to change
        return Directory(path);
      });
    }
    //temp exists, return temp
    return temp.path;
  }

  Future<File> writeAppDocFile(var content, String pathaddon) async {
    final path = await _localDirectoryPath;
    File temp = File("$path\\$pathaddon");
    //existence check
    if (!(await temp.exists())) {
      //create file and any non-existing parents
      await (temp.create(recursive: true)).catchError((e) {
        debugPrint("error with creating path: $path\\$pathaddon");
        //for now return the base path on error, but may be subject to change
        return temp;
      });
    }
    // Write the file
    return (await temp.writeAsString(content));
  }

  Future<dynamic> readAppDocJson(String path) async {
    try {
      final file = await _localDirectoryPath;
      File readTarget = File('$file\\$path');
      // Read the file
      final contents = await readTarget.readAsString();
      return jsonDecode(contents);
    } catch (e) {
      debugPrint("error with reading JSON file");
      // If encountering an error, return 0
      return 'failed';
    }
  }
}
