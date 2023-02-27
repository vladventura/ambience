// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

class NativeLibrary {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeLibrary(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeLibrary.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  int set_wallpaper(
    int a,
    int b,
  ) {
    return _set_wallpaper(
      a,
      b,
    );
  }

  late final _set_wallpaperPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Int)>>(
          'set_wallpaper');
  late final _set_wallpaper =
      _set_wallpaperPtr.asFunction<int Function(int, int)>();

  int change_wallpaper(
    ffi.Pointer<ffi.Char> input,
  ) {
    return _change_wallpaper(
      input,
    );
  }

  late final _change_wallpaperPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<ffi.Char>)>>(
          'change_wallpaper');
  late final _change_wallpaper =
      _change_wallpaperPtr.asFunction<int Function(ffi.Pointer<ffi.Char>)>();
}
