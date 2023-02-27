import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io' show Directory, File, Platform;
import 'package:ffi/ffi.dart';
import 'package:ambience/native/generated_bindings.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final dylibPath =
    path.join(Directory.current.absolute.path, 'set_wallpaper.so');
final nl = NativeLibrary(ffi.DynamicLibrary.open(dylibPath));

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
  int _wallpaperResult = 0;
  String _input = "";

  Future<String> normalizePath(String input) async {
    String normalized = path.normalize(input);
    if (Platform.isWindows && !normalized.contains("C:")) {
      normalized = "C:\\$normalized";
    }
    if (await File(normalized).exists()) {
      return normalized;
    }
    return "";
  }

  Future<void> _setWallpaper() async {
    String pathToFile = await normalizePath(_input);
    if (pathToFile.isEmpty) return;
    ffi.Pointer<ffi.Char> charP = pathToFile.toNativeUtf8().cast<ffi.Char>();
    int res = nl.change_wallpaper(charP);
    malloc.free(charP);

    setState(() {
      _wallpaperResult = res;
    });
  }

  void setInput(String s) {
    setState(() {
      _input = s;
    });
  }

  void onSubmit() async {
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
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_wallpaperResult',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextField(
              onChanged: (value) => setInput(value),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onSubmit,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
