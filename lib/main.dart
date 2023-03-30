import 'package:ambience/handlers/file_handler.dart';
import 'package:flutter/material.dart';
import 'package:ambience/dataGeneration/data_gen.dart';

Future main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ambience Plot Generator',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Ambience Plot Generator'),
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
  String? cityInput;
  String? fileInput;
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
            //open file

            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter city(defaults to Boston)"),
              onChanged: (text) {
                cityInput = text;
              },
            ),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText:
                      "Enter filename for export(exports to pdf), defaults to "
                      "plottedData"
                      ""),
              onChanged: (fileNameInput) {
                fileInput = fileNameInput;
              },
            ),
            ElevatedButton(
              onPressed: () => exportFile(fileInput),
              child: const Text("Export File"),
            ),
            ElevatedButton(
              //defaults to boston
              onPressed: () => weatherDataPlot(cityInput ?? "boston"),
              child: const Text("Plot city weather data"),
            ),
          ],
        ),
      ),
    );
  }
}

void exportFile(String? exportName) async {
  //defaults to plottedData, if null
  await savePathFilePicker(exportName ?? "plottedData");
}
