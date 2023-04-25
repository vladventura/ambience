import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firedart/auth/exceptions.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
import "dart:io";
import "package:ambience/storage/storage.dart";
import "package:ambience/constants.dart" as constants;
import 'package:argon2/argon2.dart';

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
      //since free plan can't access server side functions, delete if they try to
      //sign in with unverified account
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
      //check if it's a weak password, will throw if it is.
      //it throws to take advantage of login screen displaying errors
      isWeakPassword(password);
      await auth.signUp(email, password);
      await auth.requestEmailVerification();
      //throwing to show message to user
      throw "please verify your email, then sign in";
    } on AuthException catch (e) {
      //to-do allow retries for incorrect attempts
      throw (e.message);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<bool> resetPwd(String email) async {
    try {
      await auth.resetPassword(email);
    } on AuthException catch (e) {
      //to-do allow retries for incorrect attempts
      throw (e.message);
    } catch (e) {
      throw e.toString();
    }
    return true;
  }

  //encode and upload image to firestore(firebase database)
  Future<void> imageUpload(String imagePath, String imageName) async {
    Firestore fstore = Firestore.instance;
    var docRef = fstore
        .collection("users")
        .document(userID)
        .collection("wallpapers")
        .document(imageName);
    File image = File(imagePath);
    //byte data
    List<int> imageData = await image.readAsBytes();
    await docRef.update({imageName: base64Encode(imageData)});
  }

  //optional values is for testing purposes for now
  Future<void> imageDownload(String imageName) async {
    Firestore fstore = Firestore.instance;
    var docRef = fstore
        .collection("users")
        .document(userID)
        .collection("wallpapers")
        .document(imageName);

    Document snapshot = await docRef.get();
    String base64Image = snapshot.map[imageName];
    //to-do check is base64Encode works with UTF-16, or replace with something that does

    List<int> imageData = base64Decode(base64Image);
    //store in Firebase folder inside Ambience folder
    Storage store = Storage();
    String path = "Firebase/$imageName";
    await store.writeAppDocFileBytes(imageData, path);
  }

  void fireSignOut() {
    auth.signOut();
  }

  Future<void> ruleJSONUpload() async {
    var docRef = Firestore.instance
        .collection("users")
        .document(userID)
        .collection("config")
        .document(constants.jsonPath);
    Storage store = Storage();
    Map<String, dynamic> ruleJSON =
        await store.readAppDocJson(constants.jsonPath);
    String imageName, fileExt;
    //extract images and rename them to ensure names are unique
    for (dynamic entry in ruleJSON.values) {
      fileExt = ((entry["wallpaperFilepath"]).split(".")).last;
      imageName =
          "Fire_${(entry["idSchema"]).replaceAll("_daemon_", "_")}.$fileExt";
      await imageUpload(entry["wallpaperFilepath"], imageName);
      entry["wallpaperFilepath"] = imageName;
    }
    //upload json
    await docRef.update(ruleJSON);
  }

  Future<void> ruleJSONDownload() async {
    var docRef = Firestore.instance
        .collection("users")
        .document(userID)
        .collection("config")
        .document(constants.jsonPath);
    Document snapshot = await docRef.get();
    //get the ruleset map
    Map<String, dynamic> ruleMap = snapshot.map;
    //append file path to downloaded images
    Storage store = Storage();
    String imageName;
    for (dynamic entry in ruleMap.values) {
      imageName = entry['wallpaperFilepath'];
      //set wallfile path to dynamic absolute path of Firebase download folder
      entry["wallpaperFilepath"] =
          await store.provideAppDirectory("Firebase/$imageName");
      //download the image to Firebase download folder
      await imageDownload(imageName);
    }

    //properly encodes map in a json format string
    String encodedMap = jsonEncode(ruleMap);
    //write to file, overwritting existing json
    store.writeAppDocFile(encodedMap, constants.jsonPath);
  }

  //will throw if the password is weak
  //this done to take advantage of the error message stream display to user the login screen has
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

  Future<void> deleteWallpaper(String imageName) async {
    //check if it exists on Firebase(done by checking if it has the "Fire_" tag)
    if (imageName.contains("Fire_ambience_")) {
      Firestore fstore = Firestore.instance;
      var docRef = fstore
          .collection("users")
          .document(userID)
          .collection("wallpapers")
          .document(imageName.split("\\").last);
      //delete from firebase
      await docRef.delete();
      //also check and delete if it's in the local cache
      File imageFile = File(imageName);
      //if it's in local cache delete it
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
      //else no further action needed
    }
    //else it is a local only file
    //so firehandler doesn't have to act
  }

  Future<void> uploadLocJSON() async {
    var docRef = Firestore.instance
        .collection("users")
        .document(userID)
        .collection("config")
        .document("location");
    Storage store = Storage();
    //get the map from file using storage
    //docRef.update(map);
  }

  Future<void> downLocJSON() async {
    var docRef = Firestore.instance
        .collection("users")
        .document(userID)
        .collection("config")
        .document("location");
    Document snapshot = await docRef.get();
    var locMap = snapshot.map;
    Storage store = Storage();
    //write Map to file using storage
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
