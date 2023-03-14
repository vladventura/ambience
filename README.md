# Ambience

Cross-platform Wallpaper Manager that changes your device's wallpaper by the following criteria (and any combination between these):

- Time of day
- Weekday
- Month
- Weather Conditions  

Our project will focus on Windows devices for now. We decided to scrap the idea of MacOS because not all of us have access to an Apple computer, and it would be unfair for those who do not. There would be issues whenever we're testing code.

# Roadmap

This should be updated bit by bit as we figure out the "whats" and the "hows" of our project.


# Tools Used

Again, this should also be updated as we go with the packages that we use.

- [Flutter](https://flutter.dev/): Google's cross-platform SDK for multiple platforms with a single codebase
  - [Requests](https://pub.dev/packages/requests): Flutter package to simplify HTTP/HTTPS requests
- [Android Studio](https://developer.android.com/studio): IDE for Android app development
<br />

# How to install Flutter

  ## Windows

  Download the latest stable build of Flutter [here](https://docs.flutter.dev/get-started/install/windows).

  Extract the zip file, it is recommended that you extract it
  in your C: drive's root.
  _Do not extract the zip file in a directory that requires special permissions._

  Update your path user variable

  * First, enter "env" into the search bar of your Start menu, and then select **"Edit environment variables for your account."**
    * Next, select the "**Environment variables"** option at the bottom of the window.
    * In this window, select the environment variable titled **"Path."** If this variable does not
    exist yet, then select the **"New"** option under **"User variables,"** and name it "Path."
    * Open the Path variable and select the **"new"** option, and enter the full filepath to the _flutter\bin_ folder.
  
Run the **flutter doctor** to ensure that you have all of the necessary dependencies to properly run it.
  
  * From a console window, navigate to the extracted Flutter folder.
    * Once there, enter the command **"flutter doctor"**, and the command will check the status of your Flutter installation, and will inform you if any needed software is missing in bold text.

<br />

  ## Linux

<br />

 Download the Flutter SDK tar.xz file [here](https://docs.flutter.dev/get-started/install/linux).

Extract the file in a directory of your choice. 

Add the flutter tool to your path using the command:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ```$ export PATH="$PATH:`pwd`/flutter/bin"```

<br />

Run the **flutter doctor** to ensure that you have all of the necessary dependencies to properly run it.

* The command will check the status of the Flutter installation, and will inform you if any needed software or tools are missing in bold text.

<br />

# How to install Android Studio

 ## Windows

Download the latest stable version of android studio [here](https://developer.android.com/studio).

Run the downloaded .exe setup tool

* Follow the instructions provided by the setup program
* If you wish to run the android version of Ambience on a virtual android device, click the check-box for the "Android Virtual Device" option.
* **It is recommended that you chose the default installation path that the setup tool selects.**

<br />

## Linux

Download the Android Studio zip file for the Linux platform [here](https://developer.android.com/studio).

Extract the .zip file in a suitable directory, such as your local user directory.

Launch the setup tool by navigating to the `android-studio/bin/` directory,
and run `studio.sh`.

Follow the instructions provided by the setup program.

<br />

**For 64-bit Ubuntu users:**
  * You will need to install some 32-bit dependencies with this command: <br />
  `sudo apt-get install libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386`

**For 64-bit Fedora users:**
* install the same 32-bit libraries using the following command: <br />
  `sudo yum install zlib.i686 ncurses-libs.i686 bzip2-libs.i686`

<br />

# How to install Msys2

## Windows only

Download the installer [here](https://github.com/msys2/msys2-installer/releases/download/2023-01-27/msys2-x86_64-20230127.exe).

Run the installer, *ensure that your Windows version is 8.1 or newer*

* Set the installation path to the C:\ drive, preferably in a dedicated folder.

Once installed, install the GCC compiler tool by entering the following command: <br />
`$ pacman -S mingw-w64-ucrt-x86_64-gcc`

<br />

## Linux

Msys2 is not needed for the necessary tools to compile this project, simply
use the following command to install the essentials: <br />
`sudo apt install build-essential`

In addition to this, you will also need to install xvfb with this command: <br />
`sudo apt-get install xvfb`
