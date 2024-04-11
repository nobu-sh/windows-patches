# Check if running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  $scriptPath = $MyInvocation.MyCommand.Path
  Start-Process PowerShell.exe -ArgumentList "Start-Process PowerShell -ArgumentList '-File \`"$scriptPath\`"' -Verb RunAs" -Verb RunAs
  exit
}

Write-Host "Permissions elevated. Applying patch to audiodg.exe..."

# Set the current directory to the script's directory
Set-Location $PSScriptRoot

$processorCount = [System.Environment]::ProcessorCount
Write-Host "Detected $processorCount logical cores."
$targetProcessor = $processorCount - 2 # Adjust to second-to-last processor (0-indexed)
Write-Host "Setting audiodg to logical core $targetProcessor."

# Try to set process priority and affinity
try {
  $processes = Get-Process audiodg -ErrorAction Stop
  foreach ($process in $processes) {
    $process.PriorityClass = 'High'
    # We set it to the second to last core so its sudo-random
    # This is to avoid the first core which is usually used the most.
    $process.ProcessorAffinity = 1 -shl $targetProcessor
  }
  Write-Host "Settings applied successfully."
}
catch {
  Write-Error "Failed to apply settings: $_"

  # Pause the script to view errors or confirm success
  Read-Host "Press Enter to exit..."
}
