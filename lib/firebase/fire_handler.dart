import 'dart:convert';

import 'package:firedart/auth/exceptions.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
import "dart:io";

class FireHandler {
  static const apiKey = 'placeholder until I can hide this on github';
  static const projectId = 'placeholder until I can hide this on github';
  static const testmail = 'placeholder until I can hide this on github';
  static const testpassword = 'placeholder until I can hide this on github';
  late FirebaseAuth auth;

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
    FirebaseAuth.initialize(apiKey, VolatileStore());
    Firestore.initialize(projectId);
  }

  Future<void> fireSignIn(
      [String email = testmail, String password = testpassword]) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    //TO-DO: Add limited cilent hashing
    //fireAuth will hash it on arrival
    try {
      await auth.signIn(email, password);
    } on AuthException catch (e) {
      //to-do allow retries for incorrect attempts
      debugPrint("Failed with error code: ${e.errorCode}");
      return;
    }
    var user = await auth.getUser();
    debugPrint("user: $user");
  }

  void fireSignUp(
      [String email = testmail, String password = testpassword]) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.signUp(email, password);
    } on AuthException catch (e) {
      //to-do allow retries for incorrect attempts
      debugPrint("Failed with error code: ${e.errorCode}");
      return;
    }
    //auth.userId;
  }

  //optional values is for testing purposes for now
  //yes I know it has hardcoded paths
  Future<void> imageUpload(
      [String userId = "testUser", String imagePath = '1']) async {
    //since the path of ambience needs to be dynamically resolved, it cannot be passed as an optional parameter directly

    if (imagePath == '1') {
      imagePath = _imagePathUp;
    }
    var docRef = Firestore.instance.collection(userId).document("wallpapers");
    File image = File(imagePath);
    //byte data
    List<int> imageData = await image.readAsBytes();
    //to-do check is base64Encode works with UTF-16, or replace with something that does
    await docRef.update({'imageData': base64Encode(imageData)});
  }

  //optional values is for testing purposes for now
  Future<void> imageDownload(
      [String userId = "testUser", String imagePath = "1"]) async {
    //since the path of ambience needs to be dynamically resolved, it cannot be passed as an optional parameter directly
    if (imagePath == '1') {
      imagePath = _imagePathDown;
    }
    DocumentReference docRef =
        Firestore.instance.collection(userId).document('wallpapers');
    var snapshot = await docRef.get();
    String base64Image = snapshot.map['imageData'];
    //to-do check is base64Encode works with UTF-16, or replace with something that does

    List<int> imageData = base64Decode(base64Image);
    File output = File(imagePath);
    await output.writeAsBytes(imageData);
  }
}
