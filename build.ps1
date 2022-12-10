cls

[string]$sourceRepo = "https://github.com/branwenevans/2d-platformer/"
[string]$unityEditor = "C:\Program Files\Unity\Hub\Editor\2020.3.42f1\Editor\Unity.exe"

[string]$projectFolder = "$PSScriptRoot\2d-platformer"
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
}
catch
{
  LogMessage("ERROR: $_ " + $Error[0].ScriptStackTrace)
}
