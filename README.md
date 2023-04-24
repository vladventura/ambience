# Ambience

Cross-platform Wallpaper Manager that changes your device's wallpaper by the following criteria (and any combination between these):
- Time of day
- Weekday
- Month
- Weather Conditions  

### Table of contents
- [Tool Installation](#tool-installation)
  - [Flutter](#flutter)
  - [Android Studio](#android-studio)
  - [C languages Tools](#c-languages-tools)
- [Initial Setup](#initial-setup)
  - [Windows Initial Setup](#windows-initial-setup)
  - [Linux Initial Setup](#linux-initial-setup)
- [Usage Instructions](#usage-instructions)
- [Distribution](#distribution)
- [Compatibility](#compatibility)
- [Important Notes](#important-notes)

# Tool Installation
These are the tools that must be installed before building and/or contributing to our project. We highly recommend that these are
already installed before cloning the repo.

## Flutter
Google's cross-platform SDK that allows to create applications for multiple platforms with a single codebase.

Download the latest stable build of Flutter for your current operating system [here](https://docs.flutter.dev/get-started/install/).

### Flutter installation: Windows
- Extract the contents of the downloaded Flutter zip file, and copy them to a folder of your preference. It is recommended that you extract it in your user's root folder.
Usually, the path is in the shape of ```C:\Users\%user_name%\```. This should result in having a new folder with this path: ```C:\Users\%user_name%\flutter```.

**Do not extract the zip file in a folder that requires special permissions. This will make Flutter only be accessible by elevated permissions shells.**

- Update your path user variable

 - First, enter "env" into the search bar of your Start menu, and then select **Edit environment variables for your account.**
   - Next, select the **Environment Variables** option at the bottom of the window.
   - In this window, select the environment variable titled **Path**. If this variable does not
   exist yet, then select the **New** option under **User variables**, and name it **Path**.
   - Open the Path variable and select the **New** option, and enter the full filepath to the _flutter\bin\_ folder that was copied to the user's root folder.
   Ex: ```C:\Users\%user_name%\flutter\bin\```. 

- At this point, you should be able to open a new Powershell/Terminal window and run the command ```flutter doctor```.
The command will check the status of the Flutter installation, and will inform you if any needed software or tools are missing in bold text.

### Flutter installation: Linux
- Extract the contents of the downloaded Flutter zip file, and copy them to a directory of your preference. It is recommended that you extract it in your user's root directory.
A shorthand for this path is usually ```~/```. This should result in having a new directory with this path: ```~/flutter```.

**Do not extract the zip file in a directory that requires special permissions. This will make Flutter only be accessible with elevated permissions, such as sudo.**

- Add the flutter tool to your path using the command ```$ export PATH="$PATH:`pwd`/flutter/bin"``` for the current terminal session.
For a permanent solution, please see [Update your path](https://docs.flutter.dev/get-started/install/linux#update-your-path). 

- At this point, you should be able to run the command ```flutter doctor``` (if Path was updated, then open a new terminal).
The command will check the status of the Flutter installation, and will inform you if any needed software or tools are missing in bold text.

## Android Studio
Google's mobile development geared, Jetbrains-based Android Studio comes bundled with a Java SDK, a toolchain for debugging physical Android devices (see (ADB)[]),
an Android device emulator, and a set of licenses that are required to accept when bundling Android applications for Google Play. 
Please note that it is not necessary to use Android Studio for Flutter development, but rather these tools bundled with it are required for Flutter to work.

Download the latest stable version of Android Studio for your current operating system [here](https://developer.android.com/studio).

### Android Studio installation: Windows

- Execute the downloaded Android Studio installer
- Follow the instructions provided by the setup program
- If you wish to run the Android version of Ambience on a virtual Android device, click the check-box for the "Android Virtual Device" option.
- **It is recommended that you chose the default installation path that the setup tool selects.**

### Android Studio installation: Linux
**For 64-bit Ubuntu users:**
- You will need to install some 32-bit dependencies with this command: <br />
  `sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386`
  
**For 64-bit Fedora users:**
- install the same 32-bit libraries using the following command: <br />
  `sudo yum install zlib.i686 ncurses-libs.i686 bzip2-libs.i686`

After installing the missing dependencies/libraries, if applicable:

- Extract the contents of the downloaded Android Studio zip file, and copy them to a directory of your preference. It is recommended that you extract it in your user's root directory.
This should result in having a new directory with this path: ```~/android-studio/```.
- Run the ```studio.sh``` script inside the ```bin/``` directory of the extracted file. Ex: ```~/android_studio/bin/studio.sh```.
- Follow the instructions provided by the setup program.

## C languages Tools
These tools are needed for Flutter to properly make and build its dependencies.

### C languages Tools: Windows
[Msys2](https://www.msys2.org/), the tool we're recommending here, only works with Windows 8.1 or above.
For older versions of Windows, please look at the separate [mingw](https://www.mingw-w64.org/) installer.

- Download the installer [here](https://github.com/msys2/msys2-installer/releases/download/2023-01-27/msys2-x86_64-20230127.exe).
- Run the installer
- Set the installation path to the ```C:\``` drive, preferably in a dedicated folder.

Once installed, install the GCC compiler tool by entering the following command: <br />
`$ pacman -S mingw-w64-ucrt-x86_64-gcc`

### Visual Studio 2019 Build Tools
As of right now, Flutter requires us to use the 2019 version of Build Tools. At the time of writing, We know of at least two different
computers that are using version 16.11.22 specifically, and they've had no complaints from Flutter yet. Because of this, we'll recommend to
install that version.

Feel more than free, however, to try any version above it, as long as it's 2019 Build Tools. Please choose your preferred Build Tools version
number from [their release history](https://learn.microsoft.com/en-us/visualstudio/releases/2019/history#release-dates-and-build-numbers).

- Run the downloaded installer
- After the first setup ends, a new screen will show up prompting to either download while installing, or download then install dependencies.

### C languages Tools: Linux
Instead of Msys2, we use the build-essentials bundle. xvfb is used in Linux to 

- In a terminal window, run `sudo apt install build-essential`

### xbvf for Linux
The default Linux behavior for Flutter applictions is draw a Window. Cron jobs run in a "minimalistic" terminal enviroment with no display, which doesn't allow Flutter
to render since it cannot find a display. Xfvb comes in by giving a dummy display to make everyone happy.

- Install xvfb by running `sudo apt-get install xvfb`

# Initial Setup
After installing the myriad tools, packages, and binaries from the previous step, there's still some minimum setup to do.

- Using whichever method you like, clone or fork this repository into your local computer. You can use [Github Desktop](https://desktop.github.com/) or,
if you have git installed in your computer, just use ```git clone <url>``` where ```<url>``` is this repo's URL shown in your
browser's address bar.
- After cloning, please get an API key from [OpenWeatherAPI](https://openweathermap.org/api). We're deleting the ones that show up in our git history. This is
necessary because we're using OpenWeatherAPI for Weather and Geolocation operations.
- Create a new file in the root of the cloned repo called ```.env``` and inside of it put the following line: ```APIKEY=<key>```,
replacing ```<key>``` with the API key you got from OpenWeatherAPI.

## Windows Initial Setup
- Daemons use the path_provider module. This module uses symlinks made by Windows, and as a side effect
it requires to [Enable Developer Mode](https://learn.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development). This is only necessary for whoever works on the project, but not the end user.


## Linux Initial Setup
- Please make the script files prepended with "Ubuntu", inside of the scrips directory of the repo, [executable](https://linuxhint.com/make-a-file-executable-in-linux/). This is needed because
we use external bash scripts to schedule and remove background changes. 

# Usage Instructions
After everything is successfully installed and the initial setup is done, we're ready to start the project.

Before running, we should make a few things clear:
- Visual Studio Code has plenty of extensions that do most (if not all) of what we're going to outline. VSCode is not required
to run our project, which is why we didn't include it.
- Android Studio's IDE also takes care about plenty of (if not all) that we outline if you choose to use it as your IDE to
work on the project. You're not required to run our project in Android Studio though.
- If you have any apps that read your fingerprint for authentication, when USB Debugging is turned on some of these
apps will stop authenticating through fingerprint for safety reasons (the TD Bank app does this).

Inside of the root directory of the repo, please run ```flutter pub get``` to download all dependencies.

Please run ```flutter run -d <platform>``` on the root of the project, where platform can be either ```windows``` or ```linux```
(more on Android down below). This will build and run a debugging version of the project and attach a Debugger whose
address will be shown when the project starts running (information about memory usage, the rendered widget tree, any errors if any).

## Android Usage Instructions
Running the project in Android is a bit more involved because we can either use a physical device, or an emulated one.

First, we must choose what device we're using to run the project in.
- If you'd like to use a virtual device you must have [Android Studio](#android-studio) installed.
If you do, please follow [this guide](https://developer.android.com/studio/run/managing-avds) showing how to start and create your own Android Virtual Device.
- If you'd like to use your physical device, [Android Studio](#android-studio) or [ADB](https://developer.android.com/tools/adb) must be installed on your computer.
Then, USB Debugging must also be enabled on your physical device. This is a generalized way to do it, because it varies between manufacturers.
  - Go to Settings
  - Go to About Phone
  - Go to Software Information
  - Tap the "Build Number" option seven times. While doing it there might be a popup saying "You're X steps away from becoming a developer"
  - Go back to Settings
  - Scroll all the way down, then tap Developer Options
  - Switch the "USB Debugging" toggle on
  - Connect your device to your computer. The Android device should show a prompt asking if this computer should be trusted, showing the computer's
  signature. 
  - Tap on "Allow". 

Now that we have a device to run our app on, let's go back to the repo of our project. To make sure that your device is being recognized by
Flutter, please run ```flutter devices``` and find your device in here. On the first column from left to right it should say the 
make and model of the device, and on the second one it should say the device id. This device id is the one we'll use to run our project.
Please find your device and make note of its device id.

Finally, run ```flutter run -d <device_id>``` where ```<device_id>``` is the one we got from ```flutter devices```.

# Distribution
As of right now we've only worked with debug builds of the project, and we haven't made much progress towards executables or installers
besides using them to test Daemons. However, these are a few caveats that we'd also like to remember, when we decide to further our 
efforts in this space.

When building distributables for Windows, the Powershell scripts inside of the scripts folder named ```winTaskSetter.ps1``` and ```winTaskRemover.ps1```
must be placed next to the built executable. Similarly for Linux, the bash scripts ```UbuntuCronScheduler.sh``` and ```UbuntuCronRemover.sh``` inside of
the same scripts directory must be placed next to the built executable.

## Windows Distributing
To build a Windows executable, please use ```flutter build windows```. A new build folder will be generated, and
the executable will be in the path ```.\build\windows\runner\Release```.

More information about making executables and .zip files can be found in the [Building Windows apps with Flutter](https://docs.flutter.dev/development/platform-integration/windows/building) post
by the Flutter team, and [this](https://levelup.gitconnected.com/create-windows-apps-with-flutter-cd287c9a029c) insightful Medium post about creating
installers.

## Linux Distributing
To build a Linux executable, please use ```flutter build linux --release```. A new build directory will be generated, and
the executable will be in the path ```.\build\linux\release\bundle```.

More information about releasing an app on Snap for Linux can be found [here](https://docs.flutter.dev/development/platform-integration/linux/building).

## Android Distributing
To build an Android installable Package (to use right away on your Android device), please use ```flutter build apk```. A new build directory will
be generated, and the installable .apk files (several are made for different architectures) are in the path ```/build/app/outputs/apk/release/```.

To build an Android Appbundle (to distribute through Google Play Store or any other Android storefronts), please use ```flutter build appbundle```.
A new build directory will be generated, and the appbundle will be in the path ```/build/app/outputs/bundle/release/```.

More information about distributing Flutter apps in Android can be found [here](https://docs.flutter.dev/deployment/android)

# Compatibility
Currently, our project is available for Windows, Linux, and Android.
We decided to exclude the Apple operating systems MacOS and iOS because of the following reasons:

MacOS
- We originally excluded this platform because not everyone in our team has access to it. Due to this consensus, we've reached a point where, to meet the project deadline,
 it is in our best interest to leave this implementation as an extra goal of our product.

iOS:
  - Starting from iOS 9, Apple restricted the use of multiple OS system calls, and the one that changed the wallpaper was disabled as well.

# Important Notes
This section has information that is relevant to the project, but had no space for mention in any other section.

## General Daemon Testing
Does NOT work in debug mode (the platform specific daemon manager cannot find executable in debug)!
Instead, for the time being, we've opted to make distribution builds to test that they're working.

To make a distribution build, please see [Distribution](#distribution).

