//install via flutter pub add path_provider and enable installion from loose files on windows developer settings
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

//storage uses path_provider for platform indepedent presistent data
class Storage {
  String weatherDataPath = 'weatherData.json';
  String logFilePath = 'log.txt';
  String configPath = 'config.txt';
  //path_provider gets a directory for presistent data
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  //Creat Ambience folder if it doesn't exist already, else return the path of said folder
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

  //write 'contents' to give 'pathaddon' within the Ambience folder
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

  //read json from file and converts it to Dart object and returns said object
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
