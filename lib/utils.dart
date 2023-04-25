import "dart:io";
import "package:path/path.dart" as path;
import "package:path_provider/path_provider.dart";

class Utils {
  static Future<bool> createIfNotExists(String path) async {
    Directory documentsDir = await getApplicationDocumentsDirectory();

    return false;
  }
}