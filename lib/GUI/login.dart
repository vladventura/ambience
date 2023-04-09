// log-in screen for fire branch functionality to work
import 'package:flutter/material.dart';
import 'dart:io';

String current = Directory.current.path;

class LoginMsg extends StatelessWidget {
  final bool visibleLog;
  final bool visibleSign;

  const LoginMsg({
    super.key,
    required this.visibleLog,
    required this.visibleSign,
  });

  Text _loginFail() {
    return const Text(
      "Failed to log in: \n Username or Password is incorrect.",
      style: TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      textAlign: TextAlign.center,
    );
  }

  Text _signupFail() {
    return const Text(
      "Failed to sign up: \n Username is already taken.",
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
          Visibility(
            visible: visibleLog,
            child: _loginFail(),
          ),
          Visibility(
            visible: visibleSign,
            child: _signupFail(),
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
  bool _visibleSign = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  void _login(String usrname, String passwrd) {
    bool success = false; /* BOOLEAN FUNCTION PART GOES HERE */

    if (success) {
      Navigator.pushNamed(context, '/Home');
    } else {
      setState(() {
        _visibleLog = true;
        _visibleSign = false;
      });
    }
  }

  void _signup(String usrname, String passwrd) {
    bool success = true; /* BOOLEAN FUNCTION PART GOES HERE */

    if (success) {
      Navigator.pushNamed(context, '/Home');
    } else {
      _visibleSign = true;
      _visibleLog = false;
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
          labelText: "Username",
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
        textAlign: TextAlign.left,
        maxLength: 50,
        decoration: const InputDecoration(
          labelText: "Password",
          labelStyle: TextStyle(fontSize: 20),
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
            visibleSign: _visibleSign,
          ),
        ],
      ),
    );
  }
}