# Installation
See master branch readme on setup and configuration of Flutter and other Ambience dependencies.
Note: Linux dependency "xfvb" is not required for this example, as it does not utilize the daemons.'

Place ".env" file in the root folder of Ambience, this contains all the API Keys needed as well as example account credenitals. 

# Usage
Once setup, type  `Flutter run`(Make sure you are on Windows(recommended) or Linux platform)
This branch has a hardcoded example of the firebase implementation. It will login, upload whatever file of the name "test.jpg"(note, if this file does not exist, program will throw an error) in the root folder of Ambience. The example well then download the from filebase and name it "downloadTest.jpg" in the root folder of Ambience.

# Misc
Firebase Auth will automatically hash & salt passwords. Firebase also uses Google Remote Procedure Call(GRPC) which is Transport Security Layer(TLS) providing cilent to server encryption and vice versa.  

# Roadmap
I will add another hash algorithim to enchance security. The idea is if a weakness is discovered in one hash algorithim the passwords aren't compromised, given the mix approach to hashing/

This needs to be tied to a GUI interface still, and something to handle the logic for that.
