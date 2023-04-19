// log-in screen for fire branch functionality to work
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ambience/Firebase/fire_handler.dart';

String current = Directory.current.path;

// ignore: must_be_immutable
class LoginMsg extends StatelessWidget {
  final bool visibleLog;

  String errMsg = "";

  LoginMsg({super.key, required this.visibleLog, required this.errMsg});

  // change to accept custom error messages from firebase

  Text _loginFail(String msg) {
    return Text(
      msg,
      style: TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // needs a "stateful widget" to work properly and change states
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        children: [
          // change to have only one error message, as there's gonna be a whole lotta messages
          Visibility(
            visible: visibleLog,
            child: _loginFail(
                errMsg), // this will be updated as the error message changes
          ),
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
  bool _visibleLog = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _obscureFlag = true;
  String errMsg = "";
  FireHandler hand = FireHandler();
  void _login(String usrname, String passwrd) async {
    bool success = false; /* BOOLEAN FUNCTION PART GOES HERE */
    try {
      success = await hand.fireSignIn(usrname, passwrd);
    } catch (e) {
      errMsg = e.toString(); // set error message
    }
    if (success) {
      _visibleLog = false;
      Navigator.pushNamed(context, '/Home');
    } else {
      setState(() {
        _visibleLog = true;
      });
    }
  }

  void _signup(String usrname, String passwrd) async {
    //always true for testing
    bool success = true; /* BOOLEAN FUNCTION PART GOES HERE */
    /*
    try {
      success = await hand.fireSignUp(usrname, passwrd);
    } catch (e) {
      errMsg = e.toString(); // set error message
    }
    */
    if (success) {
      _visibleLog = false;
      Navigator.pushNamed(context, '/Home');
    } else {
      setState(() {
        _visibleLog = true;
      });
    }
  }

  Text _loginHeader() {
    return const Text("Log in:");
  }

  Container _usernameInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      width: 500,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: TextField(
        onChanged: null,
        controller: _nameController,
        textAlign: TextAlign.left,
        maxLength: 100,
        decoration: const InputDecoration(
          labelText: "Email",
          labelStyle: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Container _passwordInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      width: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: TextField(
        onChanged: null,
        controller: _passController,
        obscureText: _obscureFlag,
        textAlign: TextAlign.left,
        maxLength: 50,
        decoration: InputDecoration(
          labelText: "Password",
          labelStyle: const TextStyle(fontSize: 20),
          suffixIcon: IconButton(
            // ignore: dead_code
            icon: Icon(_obscureFlag ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _obscureFlag = !_obscureFlag;
              });
            },
          ),
        ),
      ),
    );
  }

  Container _loginFields() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          _usernameInput(),
          const Padding(padding: EdgeInsets.only(top: 32)),
          _passwordInput(),
        ],
      ),
    );
  }

  OutlinedButton _loginButton() {
    return OutlinedButton(
      onPressed: () {
        _login(_nameController.text, _passController.text);
        errMsg = ""; // update error message here
        setState(() {});
      },
      style: const ButtonStyle(
        padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(20)),
        backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
        side: MaterialStatePropertyAll<BorderSide>(
          BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: const Text("Log In"),
    );
  }

  OutlinedButton _signupButton() {
    return OutlinedButton(
      onPressed: () {
        _signup(_nameController.text, _passController.text);
        errMsg = ""; // update error message here
        setState(() {});
      },
      style: const ButtonStyle(
        padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.all(20)),
        backgroundColor: MaterialStatePropertyAll<Color>(Colors.white),
        side: MaterialStatePropertyAll<BorderSide>(
          BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: const Text("Sign Up"),
    );
  }

  Column _loginSignin() {
    return Column(
      children: [
        _loginButton(),
        const Padding(padding: EdgeInsets.all(12)),
        _signupButton(),
        const Padding(padding: EdgeInsets.all(12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _loginHeader(),
          const Padding(padding: EdgeInsets.only(top: 8)),
          _loginFields(),
          _loginSignin(),
          LoginMsg(
            visibleLog: _visibleLog,
            errMsg: errMsg,
          ),
        ],
      ),
    );
  }
}
