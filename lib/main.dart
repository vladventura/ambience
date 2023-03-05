import 'package:ambience/handlers/file_handler.dart';
import 'package:ambience/handlers/wallpaper_handler.dart';
import 'package:flutter/material.dart';
//install http.dart via 'flutter pub add http'
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

geolocate(var apiKey, String? input) async {
  var cityName = input;
  //use to limit number of matching results in geocoder api call
  var limit = 1;

  //geocoder url format
  //http://api.openweathermap.org/geo/1.0/direct?q={city name},{state code},{country code}&limit={limit}&appid={API key}
  //country code = ISO 3166 codes, state code is for US only, limit is # of top results returned

  var geocodeUrl = Uri.parse(
      'http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=$limit&appid=$apiKey');
  //api call to geocoder
  var geocoderReply = await http.get(geocodeUrl);
  //Extracting map from 1 size list created by json.decode
  var coderMap = (jsonDecode(geocoderReply.body))[0];

  return [coderMap['lat'], coderMap['lon']];
}

_getWeather(String? input) async {
  //to be replaced with a way of hiding api key
  const apiKey = '91c86752769af03ca919b23664114cda';

  //cords = 2 size array with lat and lon, index 0 and 1 respectively
  var cords = await geolocate(apiKey, input);
  var weatherUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=${cords[0]}&lon=${cords[1]}&appid=$apiKey');

  //API call to openweather, sends back a json.
  var weatherReply = await http.get(weatherUrl);
  //Note, decoding open weather returns a map directly instead of a list
  // ignore: unused_local_variable
  var weatherBody = (jsonDecode(weatherReply.body));
  // ignore: avoid_print
  print("Found weather for ${weatherBody['name']}");
  //to-do parse weather data.
}

void storeWeather(String? input) {
  //not fully functional, getweather still needs to parse the weatherdata
  _getWeather(input);
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
                onPressed: () => storeWeather(cityInput),
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
