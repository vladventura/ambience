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