//install via flutter pub add path_provider and enable installion from
//loose files on windows developer settings
import 'package:ambience/constants.dart' as constants;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
//install via flutter pub add path
import 'package:path/path.dart' as p;

//storage uses path_provider for platform indepedent presistent data
class Storage {
  String weatherDataPath = constants.weatherDataPath;
  String logFilePath = constants.logFilePath;
  String configPath = constants.configPath;
  String appDataDirName = constants.appDataDirName;
  Directory? documentsDir;

  //path_provider gets a directory for presistent data
  Future<String> get _localPath async {
    // I couldn't help it
    documentsDir ??= await getApplicationDocumentsDirectory();
    return documentsDir!.path;
  }

  //Creat Ambience folder if it doesn't exist already,
  //else return the path of said folder
  Future<String> get _localDirectoryPath async {
    final path = await _localPath;
    Directory temp = Directory("$path/$appDataDirName");

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
  Future<File> writeAppDocFile(var content, String pathaddon,
      [String mode = 'n']) async {
    final path = await _localDirectoryPath;
    File temp = File(p.normalize("$path/$pathaddon"));
    //existence check
    if (!(await temp.exists())) {
      //create file and any non-existing parents
      await (temp.create(recursive: true)).catchError((e) {
        debugPrint("error with creating path: ${temp.path}");
        //for now return the base path on error, but may be subject to change
        return temp;
      });
    }
    //append mode.
    if (mode == 'a') {
      return (await temp.writeAsString(content, mode: FileMode.append));
    }
    // Write the file, normally
    return (await temp.writeAsString(content));
  }

  Future<File> writeAppDocFileBytes(List<int> bytes, String pathaddon,
      [String mode = 'n']) async {
    final path = await _localDirectoryPath;
    File temp = File(p.normalize("$path/$pathaddon"));
    //existence check
    if (!(await temp.exists())) {
      //create file and any non-existing parents
      await (temp.create(recursive: true)).catchError((e) {
        debugPrint("error with creating path: ${temp.path}");
        //for now return the base path on error, but may be subject to change
        return temp;
      });
    }
    //append mode.
    if (mode == 'a') {
      return (await temp.writeAsBytes(bytes, mode: FileMode.append));
    }
    // Write the file, normally
    return (await temp.writeAsBytes(bytes));
  }
  //read json from file and converts it to Dart object and returns said object
  Future<dynamic> readAppDocJson(String path) async {
    try {
      final file = await _localDirectoryPath;
      File readTarget = File(p.normalize('$file/$path'));
      // Read the file
      final contents = await readTarget.readAsString();
      return jsonDecode(contents);
    } catch (e) {
      debugPrint("error with reading JSON file, relative path given: $path");
      // If encountering an error
      return 'failed';
    }
  }
  Future<String> provideAppDirectory(String addon)async{
    final path = await _localDirectoryPath;
    String directory = (p.normalize("$path/$addon"));
    return directory;
  }
}
