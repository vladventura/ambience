// log-in screen for fire branch functionality to work

// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'dart:io';

void main() => runApp(const LoginApp());

String current = Directory.current.path;

class LoginMsg extends StatefulWidget {
  const LoginMsg({super.key});

 @override
  State<LoginMsg> createState() => _LoginMsg();
}

  bool visibleLog = false;

  bool visibleSign = false;

  TextEditingController nameController = TextEditingController();

  TextEditingController passController = TextEditingController();

class _LoginMsg extends State<LoginMsg> {

  Text loginFail = Text("Failed to log in: \n Username or Password is incorrect.",
                   style: TextStyle(color: Colors.red, 
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    textAlign: TextAlign.center,);

  Text signupFail = Text("Failed to sign up: \n Username is already taken.",
                   style: TextStyle(color: Colors.red, 
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    textAlign: TextAlign.center,);

  @override
  Widget build(BuildContext context) {
    return Container( // needs a "stateful widget" to work properly and change states
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(right: 24),
            child: Column(
              children: [
                Visibility(
                visible: visibleLog,
                child: loginFail),

                Visibility(
                visible: visibleSign,
                child: signupFail),
              ],
            ),
                
          );
  }
}

class LoginApp extends StatefulWidget {
  const LoginApp({super.key});

 @override
  State<LoginApp> createState() => _LoginApp();
}

class _LoginApp extends State<LoginApp> {

  @override
  Widget build(BuildContext context) {

    void Login(String usrname, String passwrd) {

      bool success = false; /* BOOLEAN FUNCTION PART GOES HERE */

      if(success) {
        Navigator.pushNamed(context, '/Home');
      }
      else {
        visibleLog = true;
        visibleSign = false;
      }

    }

    void Signup(String usrname, String passwrd) {

      bool success = false; /* BOOLEAN FUNCTION PART GOES HERE */

      if(success) {
        Navigator.pushNamed(context, '/Home');
      }
      else {
        visibleSign = true;
        visibleLog = false;
      }

    }


    Widget loginHeader = Container(
      child: const Text("Log in:"),
    );
    

    // ignore: unused_local_variable
    Widget loginFields = Container (

      alignment: Alignment.center,

      padding: EdgeInsets.all(48),

      child: Column(
      
      children: [

      Container(
        padding: EdgeInsets.all(12),
        width: 500,

        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),),
        
          child: TextField(onChanged: null ,
              controller: nameController,
              textAlign: TextAlign.left,
              maxLength: 100,
              decoration: InputDecoration(
              labelText: "Username",
              labelStyle: TextStyle(fontSize: 20)
            ),), 
      ),

      Padding(padding: EdgeInsets.only(top: 32)),

      Container(
        padding: EdgeInsets.all(12),
        width: 300,

        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),),
        
        child: TextField(onChanged: null, 
            controller: passController,
            textAlign: TextAlign.left,
            maxLength: 50,
            decoration: InputDecoration(
            labelText: "Password",
            labelStyle: TextStyle(fontSize: 20)
            ),),
      )
      ],
    )
    );

    Widget loginSignin = Column(

      children: [
        OutlinedButton(onPressed: (){Login(nameController.text, passController.text);},
                    child: const Text("Log In"),
                    style: ButtonStyle(
                      padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(20)),
                      backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                      side: MaterialStatePropertyAll<BorderSide>(BorderSide(color: Colors.black, width: 2),),  
                    ),
                    ),
        
        Padding(padding: EdgeInsets.all(12)),

        OutlinedButton(onPressed: (){Signup(nameController.text, passController.text);},
                    child: const Text("Sign Up"),
                    style: ButtonStyle(
                      padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(20)),
                      backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
                      side: MaterialStatePropertyAll<BorderSide>(BorderSide(color: Colors.black, width: 2),),  
                    ),
                    ),

        Padding(padding: EdgeInsets.all(12)),
      ],
    );



    return MaterialApp(
      home: Scaffold(
        body:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loginHeader,
            Padding(padding: EdgeInsets.only(top: 8)),
            loginFields,
            loginSignin,
            LoginMsg(),
          ],
        ),
        ),
      );
  }
}