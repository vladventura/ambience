import "dart:async";
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:ffi/ffi.dart';
import 'dart:io' show Directory, File, Process, ProcessResult;
import 'package:ambience/native/generated_bindings.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class InvalidPlatformException implements Exception {
  String cause;
  InvalidPlatformException(this.cause);
}

class WallpaperHandler {
  static final String _dylibPath =
      path.join(Directory.current.absolute.path, 'set_wallpaper.so');
  static Future<bool> setWallpaper(String input,
      {TargetPlatform? platform}) async {
    bool ret = false;
    TargetPlatform currentPlatform = platform ?? defaultTargetPlatform;
    if (currentPlatform == TargetPlatform.windows) {
      ret = await _setWallpaperWindows(input);
    } else if (currentPlatform == TargetPlatform.linux) {
      ret = await _setWallpaperLinux(input);
    } else if (currentPlatform == TargetPlatform.android) {
      ret = await _setWallpaperAndroid(input);
    } else {
      throw InvalidPlatformException(" platform not implemented");
    }
    return ret;
  }

  static Future<File> getCurrentWallpaperPath(
      {TargetPlatform? platform}) async {
    TargetPlatform currentPlatform = platform ?? defaultTargetPlatform;
    // Android has too much variance per vendor for us to account for, sorry!
    switch (currentPlatform) {
      case TargetPlatform.windows:
        return await _getCurrentWallpaperPathWindows();
      case TargetPlatform.linux:
        return await _getCurrentWallpaperPathLinux();
      default:
        throw InvalidPlatformException(
            "Platform's current wallpaper not implemented");
    }
  }

  static Future<File> _getCurrentWallpaperPathLinux() async {
    String command = "gsettings get org.gnome.desktop.background picture-uri";
    ProcessResult result = await Process.run('bash', ['-c', command]);
    String path = utf8.decode(result.stdout);
    File f = File(path);
    return f;
  }

  static Future<File> _getCurrentWallpaperPathWindows() async {
    // get
    Directory d = await getApplicationSupportDirectory();
    // AppData
    d = d.parent.parent;
    File currentWallpaper = File(path.join(
        d.path, 'Microsoft', 'Windows', 'Themes', 'TranscodedWallpaper'));
    return currentWallpaper;
  }

  static String get dyLibPath => _dylibPath;

  static Future<String> _normalizeExistsPath(String input) async {
    String normalized = path.normalize(input);
    if (await File(normalized).exists()) {
      return normalized;
    }
    return "";
  }

  static Future<bool> _setWallpaperWindows(String input) async {
    String pathToFile = await _normalizeExistsPath(input);
    if (pathToFile.isEmpty) return false;
    NativeLibrary nativeLib =
        NativeLibrary(ffi.DynamicLibrary.open(_dylibPath));
    ffi.Pointer<ffi.WChar> charP = pathToFile.toNativeUtf16().cast<ffi.WChar>();

    nativeLib.change_wallpaper(charP);

    malloc.free(charP);
    return true;
  }

  static Future<bool> _setWallpaperLinux(String input) async {
    if (input.isEmpty) return false;
    // Following instructions @Bryan0x05's branch
    String pathToFile = await _normalizeExistsPath(input);
    String command =
        "gsettings set org.gnome.desktop.background picture-uri \"file://$pathToFile\"";
    String commandDarkTheme =
        "gsettings set org.gnome.desktop.background picture-uri-dark \"file://$pathToFile\"";
    await Process.run('bash', ['-c', command]);
    await Process.run('bash', ['-c', commandDarkTheme]);
    return true;
  }

  static Future<bool> _setWallpaperAndroid(String input) async {
    if (input.isEmpty) return false;
    String pathToFile = await _normalizeExistsPath(input);
    await AsyncWallpaper.setWallpaperFromFile(
        filePath: pathToFile, wallpaperLocation: AsyncWallpaper.HOME_SCREEN);
    return true;
  }
}
