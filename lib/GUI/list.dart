// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, sort_child_properties_last, unused_import, sized_box_for_whitespace

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

void main() => runApp(const ListApp());

String current = Directory.current.path;

class WallpaperObj {} // PLACEHOLDER FOR ACTUAL WALLPAPER OBJ SO FLUTTER WILL STOP COMPLAINING

String getWallpaper(int index){

  return "$current/lib/GUI/20210513_095523.jpg";
}

String getCond(int index){

  return "placeholder weather";
}

String getTime(int index){

  return "placeholder time";
}



// List<Widget> wallpapers;


class ListApp extends StatelessWidget {
  const ListApp({super.key});

  @override
  Widget build(BuildContext context) {

    Widget listTitle = Container(
      child: Text("Saved Wallpapers", 
                  style: TextStyle(fontSize: 14)),
    );



    Widget wallPaperThumb = Expanded(
    
    child: Container( // displays the wallpaper's thumbnail

      decoration: BoxDecoration(
      border: Border.all(color: Colors.black, width: 2),
      ),
        
      child: Image.file(File(getWallpaper(0)),
            fit: BoxFit.fitHeight),
      )
      
    );

    Widget wallpaperCond = Expanded(
    
      child: Container( // displays the wallpaper's conditions
    
        decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        ),

        child: Row( 
          children: [
            Icon(Icons.local_dining), // placeholder
            Text(getTime(0)),
          ],
        )

      )

    );


    Widget wallPaperControls = Container(
      
      child: Row( // displays the wallpaper's controls
        children: [
          IconButton(onPressed: null,  //function here to switch back to main menu
                      icon: Icon(Icons.delete),
                      style: ButtonStyle(
                        padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
                        backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                        side: MaterialStatePropertyAll<BorderSide>(BorderSide(color: Colors.black, width: 2),),
                      ),
                      ),

          IconButton(onPressed: null,  //function here to switch back to main menu
                      icon: Icon(Icons.copy),
                      style: ButtonStyle(
                        padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
                        backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                        side: MaterialStatePropertyAll<BorderSide>(BorderSide(color: Colors.black, width: 2),),
                      ),
                      ),

          IconButton(onPressed: null,  //function here to switch back to main menu
                      icon: Icon(Icons.edit),
                      style: ButtonStyle(
                        padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
                        backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                        side: MaterialStatePropertyAll<BorderSide>(BorderSide(color: Colors.black, width: 2),),
                      ),
                      ),
        ],
      )
    );

    Widget wallpaperEntry = Expanded(

      child: Row(
        children: [
          wallPaperThumb,
          wallpaperCond,
          wallPaperControls,
        ],
      )
    );


    Widget wallPaperList = Expanded(
      child: ListView(
        children: [
          wallpaperEntry,
        ],
      ),
    );

    Widget wallPapersWindow = Expanded(

      child: Container(
        
        decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2)),

        child: wallPaperList,
      )
    );


    Widget buttonMenu = Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),    
      child: Row(
        children: [
          OutlinedButton(onPressed: () {
                      Navigator.pop(context);
                    },  //function here to switch back to main menu
                    child: const Text("Back"),
                    style: ButtonStyle(
                      padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
                      backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                      side: MaterialStatePropertyAll<BorderSide>(BorderSide(color: Colors.black, width: 2),),
                    ),
                    ),
          Spacer(),
          OutlinedButton(onPressed: () {

                    Navigator.pushNamed(context, '/Create');

                    }, //function here to switch to create screen
                    child: const Text("Create"),
                    style: ButtonStyle(
                      padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(32)),
                      backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                      side: MaterialStatePropertyAll<BorderSide>(BorderSide(color: Colors.black, width: 2),),  
                    ),
                    ),
        ],
      ),
    );


    return MaterialApp(
      home: Scaffold(
        body:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            listTitle,
            wallPapersWindow,
            buttonMenu
          ],
        ),
        ),
      );
  }
}