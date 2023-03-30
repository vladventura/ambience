import 'dart:convert';

import 'package:firedart/auth/exceptions.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
import "dart:io";

class FireHandler {
  static const apiKey =
      'placeholder on github until I make a way to hide the key';
  static const projectId =
      'placerholder on github until I make a way to hide the id';
  static const testmail = 'placeholder until I can hide this';
  static const testpassword = 'placeholder until I can hide this';
  late FirebaseAuth auth;
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
      [String userId = "testUser",
      String imagePath = "C:\\Users\\bryan\\Downloads\\test.jpg"]) async {
    var docRef = Firestore.instance.collection(userId).document("wallpapers");
    File image = File(imagePath);
    //byte data
    List<int> imageData = await image.readAsBytes();
    //to-do bheck is base64Encode works with UTF-16, or replace with something that does
    await docRef.update({'imageData': base64Encode(imageData)});
  }

  //optional values is for testing purposes for now
  Future<void> imageDownload(
      [String userId = "testUser",
      String imagePath = "C:\\Users\\bryan\\Downloads\\download.jpg"]) async {
    DocumentReference docRef =
        Firestore.instance.collection(userId).document('wallpapers');
    var snapshot = await docRef.get();
    String base64Image = snapshot.map['imageData'];
    List<int> imageData = base64Decode(base64Image);
    File output = File(imagePath);
    await output.writeAsBytes(imageData);
  }
}
