================General Daemon Testing=======
Does NOT work in debug(The platform specific daemon manager cannot find executable in debug)!
Build the platform specific solution file e.g. "Flutter build windows" for windows.
Then place the relevant scripts from the script folder(see below) in the same folder as the executable.

================Windows Daemon===============
Prereq: 
    Daemon class uses path_provider module which has an additional step to install on windows: enable install form loose files in developer settings on Windows(Note this should not matter to the cilent but does matter for us).

Scripts: 
    Make sure "winTaskSetter.ps1" & "winTaskRemover.ps1" is in the same folder as "ambience.exe"

================Linux Daemon==================
Prereq:
    "xfvb" is installed("sudo apt install xvfb")
        Why: Because default Linux behavior for Flutter applictions is draw a Window. Cron jobs run in a "minimalistic" terminal enviroment with no display which causes ambience to fail since it cannot find a display. Xfvb comes in by giving a dummy display to make everyone happy.
Scripts:
    "UbuntuCronRemover.sh" & "UbuntuCronScheduler.sh" in the same folder as the executable.