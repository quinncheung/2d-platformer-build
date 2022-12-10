cls

[string]$sourceRepo = "https://github.com/branwenevans/2d-platformer/"
[string]$unityEditor = "C:\Program Files\Unity\Hub\Editor\2020.3.42f1\Editor\Unity.exe"

[string]$projectFolder = "$PSScriptRoot\2d-platformer"
[string]$unityLogFile = "$projectFolder\Editor.log"
[string]$buildConsoleLog = "$PSScriptRoot\buildConsole.log"


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
    LogMessage("$action completed without error.")
  }
}

try
{  
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

  LogMessage("Starting Unity build. Please stand by.")

  $process = start-process $unityEditor -ArgumentList $buildArgs -PassThru -Wait
  VerifyProcessExitCode "Unity editor build " $process.ExitCode

  # Show the Unity log output on stdout for the user
  if(Test-Path $unityLogFile -PathType Leaf)
  {
    Get-Content $unityLogFile
  }

}
catch
{
  LogMessage("ERROR: $_ " + $Error[0].ScriptStackTrace)
}
