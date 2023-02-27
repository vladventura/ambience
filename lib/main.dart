import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io' show Directory, File, Platform;
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:ambience/native/generated_bindings.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

final dylibPath =
    path.join(Directory.current.absolute.path, 'set_wallpaper.so');
final nl = NativeLibrary(ffi.DynamicLibrary.open(dylibPath));

Future<String> normalizeExistsPath(String input) async {
  String normalized = path.normalize(input);
  if (Platform.isWindows && !normalized.contains("C:")) {
    normalized = "C:\\$normalized";
  }
  if (await File(normalized).exists()) {
    return normalized;
  }
  return "";
}

Future<void> setWallpaperWindows(String input) async {
  if (input.isEmpty) return;
  String pathToFile = await normalizeExistsPath(input);
  ffi.Pointer<ffi.Char> charP = pathToFile.toNativeUtf8().cast<ffi.Char>();
  nl.change_wallpaper(charP);
  malloc.free(charP);
}

void main() {
  debugPrint(Directory.current.absolute.path);
  int result = nl.set_wallpaper(10, 20);
  debugPrint(result.toString());
  runApp(const MyApp());
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Pick a Wallpaper!",
      type: FileType.image,
    );
    if (result == null) return;
    PlatformFile file = result.files.single;
    setState(() {
      _input = file.path!;
    });
  }

  Future<void> _setWallpaper() async {
    if (Platform.isWindows) {
      setWallpaperWindows(_input);
    }
  }

  void _changeWallpaper() async {
    await _setWallpaper();
    debugPrint(_input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text("Open File"),
            ),
            if (_input.isNotEmpty) Text("Path to file is $_input"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _changeWallpaper,
        tooltip: 'Set Wallpaper',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
