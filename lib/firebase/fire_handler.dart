import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firedart/auth/exceptions.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
import "dart:io";

class FireHandler {
  final testmail = dotenv.env['TestEmail'];
  final testpassword = dotenv.env['TestPwd'];
  late FirebaseAuth auth;
  //testing purposes
  String get _testmail {
    String? email = dotenv.env['TestEmail'];
    if (email != null) {
      return email;
    } else {
      throw FirebaseHandlerError("Cannot extract testemail from .env file");
    }
  }
  //testing purposes
  String get _testpassword {
    String? pwd = dotenv.env['TestPwd'];
    if (pwd != null) {
      return pwd;
    } else {
      throw FirebaseHandlerError("Cannot extract _testpassword from .env file");
    }
  }

  String get _imagePathUp {
    return "${Directory.current.path}/test.jpg";
  }

  String get _imagePathDown {
    return "${Directory.current.path}/downloadTest.jpg";
  }

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
  Future<bool> fireSignIn([String email = '1', String password = '1']) async {
    //since optional parameters must be const, I'm using a flag to
    //grab a non-const optional parameter
    if (email == '1') {
      try {
        email = _testmail;
      } on FirebaseHandlerError catch (e) {
        debugPrint("Error: ${e.toString()}");
        return false;
      }
    }
    //to-do move these into their own functions
    if (password == '1') {
      try {
        password = _testpassword;
      } on FirebaseHandlerError catch (e) {
        debugPrint("Error: ${e.toString()}");
        return false;
      }
    }
    FirebaseAuth auth = FirebaseAuth.instance;
    //TO-DO: Add limited cilent hashing
    //fireAuth will hash it on arrival
    try {
      await auth.signIn(email, password);
    } on AuthException catch (e) {
      //to-do allow retries for incorrect attempts
      debugPrint("Failed with error code: ${e.errorCode}");
      return false;
    }
    var user = await auth.getUser();
    debugPrint("user: $user");
    return true;
  }

  //true on success
  Future<bool> fireSignUp([String email = '1', String password = '1']) async {
    //since optional parameters must be const, I'm using a flag to
    //grab a non-const optional parameter
    if (email == '1') {
      try {
        email = _testmail;
      } on FirebaseHandlerError catch (e) {
        debugPrint("Error: ${e.toString()}");
        return false;
      }
    }
    if (password == '1') {
      try {
        password = _testpassword;
      } on FirebaseHandlerError catch (e) {
        debugPrint("Error: ${e.toString()}");
        return false;
      }
    }
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.signUp(email, password);
    } on AuthException catch (e) {
      //to-do allow retries for incorrect attempts
      debugPrint("Failed with error code: ${e.errorCode}");
      return false;
    }
    return true;
    //auth.userId;
  }

  //optional values is for testing purposes for now
  //yes I know it has hardcoded paths
  Future<void> imageUpload(
      [String userId = "testUser", String imagePathAddon = '1']) async {
    //since the path of ambience needs to be dynamically resolved, it cannot be passed as an optional parameter directly

    String imagePath = _imagePathUp;
 
    var docRef = Firestore.instance.collection(userId).document("wallpapers");
    File image = File(imagePath);
    //byte data
    List<int> imageData = await image.readAsBytes();
    //to-do check is base64Encode works with UTF-16, or replace with something that does
    await docRef.update({'imageData': base64Encode(imageData)});
  }

  //optional values is for testing purposes for now
  Future<void> imageDownload(
      [String userId = "testUser", String imagePathAddon = "1"]) async {
    //since the path of ambience needs to be dynamically resolved, it cannot be passed as an optional parameter directly
    if (imagePathAddon == '1') {
      imagePathAddon = _imagePathDown;
    }
    DocumentReference docRef =
        Firestore.instance.collection(userId).document('wallpapers');
    var snapshot = await docRef.get();
    String base64Image = snapshot.map['imageData'];
    //to-do check is base64Encode works with UTF-16, or replace with something that does

    List<int> imageData = base64Decode(base64Image);
    File output = File(imagePathAddon);
    await output.writeAsBytes(imageData);
  }
}

class FirebaseHandlerError implements Exception {
  final String message;

  FirebaseHandlerError(this.message);

  @override
  String toString() {
    return 'FirebaseHandlerError: $message';
  }
}
