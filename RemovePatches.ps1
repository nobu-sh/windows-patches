# Check if running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  $scriptPath = $MyInvocation.MyCommand.Path
  Start-Process PowerShell.exe -ArgumentList "Start-Process PowerShell -ArgumentList '-File \`"$scriptPath\`"' -Verb RunAs" -Verb RunAs
  exit
}

Write-Host "Permissions elevated. Setting up patches..."

# Set the current directory to the script's directory
Set-Location $PSScriptRoot

# Define the directory where patches are stored
$destination = "$env:USERPROFILE\.nobu\scheduler-patches"
Write-Host "Target folder: $destination"
Write-Host " "

# If destination doesn't exist, there's nothing to do
if (-Not (Test-Path $destination)) {
  Write-Host "Directory not found, nothing to clean up!" -ForegroundColor Yellow
  Read-Host "Press Enter to exit..."
  exit
}
 
# Remove scheduled tasks
Write-Host "Removing scheduled tasks..."
Get-ChildItem -Path "$destination\*.xml" | ForEach-Object {
  $scriptName = $_.Name
  $taskName = "Patch_$( $scriptName -replace '\.xml$', '')"

  # Attempt to remove the scheduled task
  $taskExists = $false
  try {
    $output = schtasks /delete /tn $taskName /F 2>&1 | Out-String
    if ($output -match $taskName) {
      $taskExists = $true
    }
  }
  catch {}

  if ($taskExists) {
    Write-Host "Successfully removed task: $taskName"
  }
  else {
    Write-Host "Task not found or could not be removed: $taskName"
  }
}

# Cleanup the directory
Write-Host " "
Write-Host "Cleaning up directory..."
Remove-Item -Path $destination -Recurse -Force
Write-Host "Removed: $destination"

Write-Host " "
Read-Host "Patches removed. Press Enter to exit..." 
