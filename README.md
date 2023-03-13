================Windows Daemon===============
This works fine in debug.HOWEVER, to make this work once ambience solution is built, you need to put the winTaskSetter.ps1 script in the same folder as the ambience.exe. I'm not sure how to "bundle" it with the exe.

================Linux Daemon==================
Does not work in debug mode, it doesn't find the executable file for ambience in debug mode. Instead, you must flutter build linux then place the script UbuntuCronScheduler.sh in that folder, then run the ambience executable. 

-xfvb is a requirement

-The current file_picker package we're using on Flutter requires developer mode on Windows to be activated when building the app. Must test that this is not a require for the client

-Path_provider requires install form loose files enaled in developer settings on Windows.
