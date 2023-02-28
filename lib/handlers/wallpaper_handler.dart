import "dart:async";
import 'dart:ffi' as ffi;
import 'package:ambience/exceptions/wallpaper_exceptions.dart';
import 'package:ffi/ffi.dart';
import 'dart:io' show Directory, File, Platform;
import 'package:ambience/native/generated_bindings.dart';
import 'package:path/path.dart' as path;

class WallpaperHandler {
  static final String _dylibPath =
      path.join(Directory.current.absolute.path, 'set_wallpaper.so');
  static Future<void> setWallpaper(String input) async {
    if (Platform.isWindows) {
      await _setWallpaperWindows(input);
    } else if (Platform.isLinux) {
      await _setWallpaperLinux(input);
    } else if (Platform.isAndroid) {
      await _setWallpaperAndroid(input);
    } else {
      throw InvalidPlatformException("Android platform not implemented");
    }
  }

  static Future<String> _normalizeExistsPath(String input) async {
    String normalized = path.normalize(input);
    if (await File(normalized).exists()) {
      return normalized;
    }
    return "";
  }

  static Future<void> _setWallpaperWindows(String input) async {
    if (input.isEmpty) return;
    String pathToFile = await _normalizeExistsPath(input);
    ffi.Pointer<ffi.Char> charP = pathToFile.toNativeUtf8().cast<ffi.Char>();

    final nativeLib = NativeLibrary(ffi.DynamicLibrary.open(_dylibPath));
    nativeLib.change_wallpaper(charP);
    malloc.free(charP);
  }

  static Future<void> _setWallpaperLinux(String input) async {}

  static Future<void> _setWallpaperAndroid(String input) async {}
}
