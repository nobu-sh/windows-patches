# Check if running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  $scriptPath = $MyInvocation.MyCommand.Path
  Start-Process PowerShell.exe -ArgumentList "Start-Process PowerShell -ArgumentList '-File \`"$scriptPath\`"' -Verb RunAs" -Verb RunAs
  exit
}

Write-Host "Permissions elevated. Setting up patches..."

# Set the current directory to the script's directory
Set-Location $PSScriptRoot

# Copy patches to the user's directory
$destination = "$env:USERPROFILE\.nobu\scheduler-patches"
Write-Host "Destination folder: $destination"
Write-Host "Never delete this directory manually! To remove patches use the RemovePatches script!" -ForegroundColor Yellow

# Ensure destination directory exists
if (-Not (Test-Path $destination)) {
  New-Item -ItemType Directory -Path $destination -Force | Out-Null
}

# Copy all patch files to the destination
Write-Host " "
Write-Host "Copying patches..."
Copy-Item -Path "patches\*" -Destination $destination -Recurse -Force -PassThru | ForEach-Object {
  Write-Host "Copied: $($_.FullName)"
}

Write-Host " "
Write-Host "Generating patch configs..."
Get-ChildItem -Path "$destination\*.ps1" | ForEach-Object {
  $scriptName = $_.Name
  $lintedName = $scriptName -replace '\.ps1$', ''
  $taskName = "Patch_$lintedName"
  $xmlFile = "$destination\$lintedName.xml"

  # Generate XML file for the task
  @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>$((Get-Date).ToString("yyyy-MM-dd'T'HH:mm:ss"))</Date>
    <Author>$env:USERNAME</Author>
    <Description>Auto-generated task for $taskName</Description>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
      <Delay>PT30S</Delay>
    </LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <RunLevel>HighestAvailable</RunLevel>
      <UserId>S-1-5-18</UserId>
      <LogonType>InteractiveToken</LogonType>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-ExecutionPolicy Bypass -File "$($_.FullName)"</Arguments>
    </Exec>
  </Actions>
</Task>
"@ | Out-File $xmlFile -Encoding unicode

  Write-Host "Generated xml config for task: $taskName"
}

# Apply or update scheduled tasks
Write-Host " "
Write-Host "Setting up scheduled tasks..."
Get-ChildItem -Path "$destination\*.xml" | ForEach-Object {
  $scriptName = $_.Name
  $taskName = "Patch_$( $scriptName -replace '\.xml$', '')"

  $taskExists = $false
  try {
    $output = schtasks /query /tn $taskName 2>&1 | Out-String
    if ($output -match $taskName) {
      $taskExists = $true
    }
  }
  catch {
    Write-Host "No existing task found for: $taskName. Error: $($_.Exception.Message)"
  }

  if (-not $taskExists) {
    # Task does not exist, create it
    schtasks /create /tn $taskName /xml $xmlFile /f
    # Write-Host "Created task: $taskName"
  }
  else {
    Write-Host "Task already exists, no action taken: $taskName"
  }
}

Write-Host " "
Read-Host "Patches applied. Press Enter to exit..."
