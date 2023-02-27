# Ambience

Cross-platform Wallpaper Manager that changes your device's wallpaper by the following criteria (and any combination between these):

- Time of day
- Weekday
- Month
- Weather Conditions  

Our project will focus on Windows devices for now. We decided to scrap the idea of MacOS because not all of us have access to an Apple computer, and it would be unfair for those who do not. There would be issues whenever we're testing code.

# Target Platforms

Due to certain restrictions on Apple's major operating systems, iOS and MacOS, there are no plans for development on these platforms.

- Windows
- Linux
- Android

# Requirements for development/usage

These tools must be installed for developing and contributing to the project. At the time of writing, there are no compiled executables or packaged installers for our target platforms. This means that the following Software Development Kits are necessary to use the project as well. Distinctions by the (development) platform will be made, if they apply.

- [Flutter](https://flutter.dev)
- C/C++ Compilers
  - Windows: [MinGW](https://opensource.com/article/20/8/gnu-windows-mingw)
  - Linux: [gcc and g++](https://www.cyberciti.biz/faq/howto-installing-gnu-c-compiler-development-environment-on-ubuntu/)

To generate ffi bindings again, you'll need to install [LLVM](https://pub.dev/packages/ffigen#installing-llvm) on your machine. You don't have to because these usually don't change once done, and you can manually do these on your own, but there's the option of doing them automatically.

# Roadmap

This should be updated bit by bit as we figure out the "whats" and the "hows" of our project.


# Tools Used

Again, this should also be updated as we go with the packages that we use.

- [Flutter](https://flutter.dev/): Google's cross-platform SDK for multiple platforms with a single codebase
  - [Requests](https://pub.dev/packages/requests): Flutter package to simplify HTTP/HTTPS requests
  - [File Picker](https://pub.dev/packages/file_picker): Opening a file picker native dialog


# How to run the app?

- Run ```flutter pub get``` to download all required packages from the yaml
- If the current and target platforms are Windows, please run ```make``` to compile the shared library to change the wallpaper on Windows platforms.
  - The current platform must be Windows because we need the C++ Windows headers to do so
- Run ```flutter run -d <device>``` where device is your target device. For now, use ```windows``` as the device.

# Notes

Please keep an eye on these.

- The current file_picker package we're using on Flutter requires developer mode on Windows to be activated when building the app. Must test that this is not a require for the client
- Still missing the permissions for Android file picking