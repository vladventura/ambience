import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firedart/auth/exceptions.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
import "dart:io";
import "package:ambience/weatherEntry/weather_entry.dart";
import "package:ambience/storage/storage.dart";
import "package:ambience/constants.dart" as constants;
import 'dart:isolate';

class FireHandler {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static String userID = auth.userId;
  //to-be broken down into sub functions
  FireHandler() {
    auth = FirebaseAuth.instance;
  }

  static void initialize() {
    final apiKey = dotenv.env['FirebaseAPIKey'];
    final projectId = dotenv.env['FirebaseID'];
    if (apiKey != null || projectId != null) {
      //null assertion makes the dart compiler happy, and since prior if checks for null
      //this should be a safe usage of it.
      FirebaseAuth.initialize(apiKey!, VolatileStore());
      Firestore.initialize(projectId!);
    }
  }

  //true on success
  Future<bool> fireSignIn(String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    //TO-DO: Add limited cilent hashing
    try {
      await auth.signIn(email, password);
      //checks to see if user has verified or not.
      final user = await auth.getUser();
      if (user.emailVerified == false) {
        //auth.deleteAccount();
       // throw "Email is not verified, please sign up, then verify, then login";
      }
    } on AuthException catch (e) {
      //to-do allow retries for incorrect attempts
      throw (e.errorCode);
    } catch (e) {
      throw e.toString();
    }
    var user = await auth.getUser();
    debugPrint("user: $user");
    return true;
  }

  //true on success
  Future<bool> fireSignUp(String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      isWeakPassword(password);
      await auth.signUp(email, password);
      await auth.requestEmailVerification();
      throw "please verify your email, then sign in";
    } on AuthException catch (e) {
      //to-do allow retries for incorrect attempts
      throw (e.message);
    } catch (e) {
      throw e.toString();
    }
    return true;
  }

  Future<bool> changepwd(password) async {
    try {
      //isWeakPassword(password);
      await auth.changePassword(password);
    } catch (e) {
      throw e.toString();
    }
    return true;
  }

  //optional values is for testing purposes for now
  //yes I know it has hardcoded paths
  Future<void> imageUpload(String imagePathAddon) async {
    //since the path of ambience needs to be dynamically resolved, it cannot be passed as an optional parameter directly
    var docRef = Firestore.instance.collection(userID).document("wallpapers");
    File image = File(imagePathAddon);
    //byte data
    List<int> imageData = await image.readAsBytes();
    //to-do check is base64Encode works with UTF-16, or replace with something that does
    await docRef.update({'imageData': base64Encode(imageData)});
  }

  //optional values is for testing purposes for now
  Future<void> imageDownload(String imagePathAddon) async {
    DocumentReference docRef =
        Firestore.instance.collection(userID).document('wallpapers');
    Document snapshot = await docRef.get();
    String base64Image = snapshot.map['imageData'];
    //to-do check is base64Encode works with UTF-16, or replace with something that does

    List<int> imageData = base64Decode(base64Image);
    File output = File(imagePathAddon);
    await output.writeAsBytes(imageData);
  }

  Future<void> ruleJSONUpload() async {
    DocumentReference docRef =
        Firestore.instance.collection(userID).document("ruleset");
    Storage store = Storage();
    var ruleJSON = await store.readAppDocJson(constants.jsonPath);
    //upload json
    await docRef.update(ruleJSON);
    //to-do: extract wallpapers from ruleset and upload
  }

  Future<void> ruleJSONDownload() async {
    DocumentReference docRef =
        Firestore.instance.collection(userID).document("ruleset");
    Document snapshot = await docRef.get();
    //get the ruleset map
    Map<String, dynamic> ruleMap = snapshot.map;
    //properly encodes map in a json format string
    String encodedMap = jsonEncode(ruleMap);
    Storage store = Storage();
    //write to file, overwritting existing map
    store.writeAppDocFile(encodedMap, constants.jsonPath);
  }

  void isWeakPassword(String password) {
    // Check length
    if (password.length < 8) {
      throw "Weak password! Password must be at least 8 characters";
    }
    // complexity flags
    bool hasUppercase = false;
    bool hasLowercase = false;
    bool hasNumber = false;
    bool hasSpecialChar = false;
    String char;
    // check complexity
    for (int i = 0; i < password.length; i++) {
      char = password[i];
      if (char.toUpperCase() != char) {
        hasLowercase = true;
      } else {
        hasUppercase = true;
      }
      if (int.tryParse(char) != null) {
        hasNumber = true;
      }
      if ('!@#\$%^&*()_-+=[{]}\\|;:",<.>/?'.contains(char)) {
        hasSpecialChar = true;
      }
    }
    //if not all flags are set, it's a weak password
    if (!(hasUppercase && hasLowercase && hasNumber && hasSpecialChar)) {
      throw "Weak password! Must be 8 or more characters, include upper & lower case characters, a number"
          " and a special character (!@#\$%^&*()_-+=[{]}\\|;:\",<.>/?)";
    }
    // Check common passwords
    // Could be improved with a dictionary
    List<String> commonPasswords = [
      'password',
      '123456',
      'qwerty',
      '123456789',
      '12345678',
      '12345'
    ];
    if (commonPasswords.contains(password.toLowerCase())) {
      throw "Weak password! Don't use a common password";
    }

    // Password is strong, no throws
  }

  //to-do: test the upload and download functions
  //to-do: handle weather entry rule creation/deletion, and intergrate with firebase
}

class FirebaseHandlerError implements Exception {
  final String message;

  FirebaseHandlerError(this.message);

  @override
  String toString() {
    return 'FirebaseHandlerError: $message';
  }
}
