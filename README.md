# Unity 2D Platformer Microgame Build
This repository contains a Windows Powershell script to build the Unity 2D Platformer Microgame. The script:
- Clones the 2D Platformer Microgame repostory.
- Uses the Unity Editor version 2020.3.42f1 to build the project for Android.
- Creates build artifacts in the same folder as the script itself
- Uploads the artifacts to JFrog Artifactory cloud storage.

Prerequisites:
- This script uses Git. The path to Git must be set in the PATH environment variable
- Powershell version 5.1 or greater
- Unity Editor version 2020.3.42f1 installed in "C:\Program Files\Unity\Hub\Editor\2020.3.42f1\Editor\Unity.exe"

How To Run :
- Windows command prompt
     - Open a command prompt as an Administrator
     - Change directory to the repository root folder
     - type "powershell -file build.ps1"
     
- Powershell command prompt
     - Open a Powershell window as an Administrator
     - Change directory to the repository root folder
     - type "./build.ps1"

