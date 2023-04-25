import "dart:convert";
import "dart:io";
import "package:ambience/models/location_model.dart";
import "package:flutter/material.dart";
import "package:path/path.dart" as p;
import 'package:ambience/constants.dart' as constants;
import "package:path_provider/path_provider.dart";

class Utils {
  static Future<void> saveToLocationFile(LocationModel incoming) async {
    Directory dirToAmb = await createAmbienceIfNotExists();
    File locationFile = File(p.join(dirToAmb.path, constants.locationFilename));

    await locationFile.writeAsString(jsonEncode(incoming.toJson()));
  }

  static Future<LocationModel?> loadFromLocationFile() async {
    Directory dirToAmb = await createAmbienceIfNotExists();
    File locationFile = File(p.join(dirToAmb.path, constants.locationFilename));

    if (!await locationFile.exists() || await locationFile.length() == 0) {
      return null;
    }

    LocationModel model =
        LocationModel.fromJson(jsonDecode(await locationFile.readAsString()));
    return model;
  }

  static Future<Directory> createAmbienceIfNotExists() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String pathToAmbience = p.join(documentsDir.path, constants.appDataDirName);
    Directory dirToAmb = Directory(pathToAmbience);
    if (!await dirToAmb.exists()) {
      await dirToAmb.create(recursive: true).catchError((e) {
        debugPrint("Failed to create Ambience folder");
        return dirToAmb;
      });
    }
    return dirToAmb;
  }
}
