cls

[string]$sourceRepo = "https://github.com/branwenevans/2d-platformer/"

[string]$unityEditor = "C:\Program Files\Unity\Hub\Editor\2020.3.42f1\Editor\Unity.exe"

# All paths are relative to current folder
[string]$projectFolder = "$PSScriptRoot\2d-platformer"
[string]$unityLogFile = "$projectFolder\Editor.log"
[string]$buildConsoleLog = "$PSScriptRoot\buildConsole.log"
[string]$artifactsFolder = $PSScriptRoot


function LogMessage($msg)
{
  $logMsgTime = Get-Date -format "dd-MMM-yyyy-HH:mm:ss"
  $fullMsg = "$logMsgTime : $msg"
  write-host $fullMsg
  Add-Content -Path $buildConsoleLog $fullMsg
}

function VerifyProcessExitCode($action, $exitCode)
{
  if($process.ExitCode -ne 0 ) 
  { 
    throw "$action failed. The process has exited with code $($exitCode)"
  }
  else
  {
    LogMessage("$action completed successfully.")
  }
}



try
{  
  if( (Test-Path $unityEditor -PathType Leaf) -eq $false )
  {
    throw "Failed to find the Unity Editor executable at $unityEditor.  Please ensure the unity editor installed correctly."
  }


  # Remove old artifacts and log files
  Remove-Item -Path $PSScriptRoot\*.zip, $PSScriptRoot\*.log -ErrorAction SilentlyContinue

  # Remove existing repo folder if it exists
  if(Test-Path $projectFolder -PathType Container)
  {
    LogMessage("Removing folder $projectFolder")
    Remove-Item -Path $projectFolder -Recurse -Force
  }  

  # Clone the source to be built
  LogMessage("Cloning git repository $sourceRepo to $projectFolder")

  $process = start-process git -ArgumentList "clone -q $sourceRepo $projectFolder" -PassThru -Wait -WindowStyle Hidden
  VerifyProcessExitCode "Git clone" $process.ExitCode


  # Build it
  [string]$buildArgs = "-batchmode -logFile `"$unityLogFile`" -buildTarget Android -projectPath `"$projectFolder`" -quit"

  LogMessage("Starting Unity build.")

  $process = start-process $unityEditor -ArgumentList $buildArgs -PassThru -Wait
  VerifyProcessExitCode "Unity editor build " $process.ExitCode


  # Show the Unity log output on stdout for the user
  if(Test-Path $unityLogFile -PathType Leaf)
  {
    Get-Content $unityLogFile
  }

  # Zip artifacts. This will fail if any of the specified files/folders were not created.
  Compress-Archive -Path $buildConsoleLog, $unityLogFile, "$projectFolder\Logs\*" -DestinationPath "$artifactsFolder\BuildLogs.zip" -Force
  LogMessage("Created artifact BuildLogs.zip")

  $compressInfo = @{
    Path = "$projectFolder\Assets", "$projectFolder\Library", "$projectFolder\Packages", "$projectFolder\ProjectSettings"
    CompressionLevel = "Fastest"
    DestinationPath = "$artifactsFolder\com.unity.template.2d-5.0.2.zip"
  }

  Compress-Archive @compressInfo -Force
  LogMessage("Created artifact $($compressInfo['DestinationPath'])")


  # Upload the artifacts to artifactory
  LogMessage("Uploading artifacts to Artifactory cloud storage")
  $env:CI = "true"

  $currentDate = Get-Date -format "dd-MMM-yyyy-HH-mm"
  $repoPath = "unity-2D-platformer/test/$currentDate/"
  $username = "unityUser"
  $pwd = "Today123!"
  $args = "rt u --user $username --password $pwd --url `"https://quinncheung.jfrog.io/artifactory`" *.zip $repoPath"

  $process = start-process tools/jfrog.exe -ArgumentList $args -PassThru -Wait -WindowStyle Hidden
  VerifyProcessExitCode "Upload artifacts to cloud storage " $process.ExitCode



  write-host
  write-host
  write-host "***************************************************************"
  write-host "  BUILD SUCCESSFUL. View the build artifacts at "
  write-host "    https://quinncheung.jfrog.io/ui/login/"
  write-host
  write-host "  Login with username: $username and password: $pwd"
  write-host "  Then navigate to Artifactory->Artifacts->unity-2D-platformer"
  write-host "***************************************************************"  

}
catch
{
  LogMessage("ERROR: $_ " + $Error[0].ScriptStackTrace)
}
