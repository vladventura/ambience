import "dart:async";
import "package:file_picker/file_picker.dart";
import "dart:io";
import 'package:ambience/dataGeneration/data_gen.dart';

class FileNotFoundException implements Exception {}

class NoFileChosenException implements Exception {}

Future<void> savePathFilePicker(String filename) async {
  // Pick a directory to save the file
  String here = Directory.current.path;
  final result = await FilePicker.platform.getDirectoryPath();
  if (result != null) {
    File file = await File('$result/$filename.pdf').create();
    File pdf = File('$here/dataGen.pdf');
    if (!(await pdf.exists())) {
      weatherDataPlot("boston");
    }
    final List<int> pdfContent = await pdf.readAsBytes();
    await file.writeAsBytes(pdfContent);
  }
}
