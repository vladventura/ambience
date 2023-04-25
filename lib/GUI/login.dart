// log-in screen for fire branch functionality to work
import 'package:ambience/providers/location_provider.dart';
import 'package:ambience/storage/storage.dart';
import 'package:ambience/firebase/fire_handler.dart';
import 'package:ambience/weatherEntry/weather_entry.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ambience/constants.dart' as constants;
import 'package:ambience/daemon/daemon.dart';

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
      //commented out to allow rapid offline testing
      //accounts for download overriding the local json or another's json if the account is being switched.
       Map<String, WeatherEntry> ruleMap = await WeatherEntry.getRuleList();
      //kill all daemons if not empty, helps avoid "dangling" daemons.
      if (ruleMap.isNotEmpty) {
        List<dynamic> entryList = ruleMap.values.toList();
        for (int i = 0; i < entryList.length; i++) {
          await Daemon.daemonBanisher(entryList[i].idSchema);
        }
      }
      //fetch user config and wallpapers from cloud(Firestore)
      //await hand.ruleJSONDownload();
      //await hand.downloadLocJSON();
      //update rulemap incase of firebase download and spawn daemons
      //this prevents dangling daemons.
      ruleMap = await WeatherEntry.getRuleList();
      if (ruleMap.isNotEmpty) {
        List<dynamic> entryList = ruleMap.values.toList();
        for (int i = 0; i < entryList.length; i++) {
          await Daemon.daemonSpawner(entryList[i].idSchema);
        }
      }
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
    bool success = true; //set to true for rapid testing
    try {
      //uncomment in final version
      //success = await hand.fireSignUp(usrname, passwrd);
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      width: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: null,
            controller: _passController,
            obscureText: _obscureFlag,
            textAlign: TextAlign.left,
            maxLength: 50,
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: const TextStyle(fontSize: 20),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureFlag ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureFlag = !_obscureFlag;
                  });
                },
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                //commented out for rapid offline testing
                //await hand.resetPwd(_nameController.text);
              } catch (e) {
                errMsg = e.toString();
                setState(() {
                  _visibleLog = true;
                });
              }
              //if no throws
              errMsg = "Check your inbox for a password reset request";
              setState(() {
                _visibleLog = true;
              });
            },
            child: const Text('Forgot Your Password?'),
          ),
        ],
      ),
    );
  }

  Container _loginFields() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.topRight,
        constraints: BoxConstraints(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(flex: 2),
            _loginHeader(),
            Container(
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: _loginFields(),
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 8)),
            FittedBox(
              fit: BoxFit.fitHeight,
              child: _loginSignin(),
            ),
            Spacer(flex: 1),
            LoginMsg(
              visibleLog: _visibleLog,
              errMsg: errMsg,
            ),
            Spacer(flex: 2)
          ],
        ),
      ),
    );
  }
}
