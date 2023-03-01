import "dart:async";
import "package:file_picker/file_picker.dart";
import "dart:io" show Directory;

class FileNotFoundException implements Exception {}

class NoFileChosenException implements Exception {}

Future<String> getImagePathFromPicker() async {
  String currentWorkingDir = Directory.current.absolute.path;
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: "Pick a Wallpaper!",
    type: FileType.image,
  );
  Directory.current = currentWorkingDir;
  if (result == null) {
    throw NoFileChosenException();
  }
  PlatformFile file = result.files.single;
  if (file.path == null) {
    throw FileNotFoundException();
  }
  return file.path!;
}
