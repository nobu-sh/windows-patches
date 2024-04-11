# Windows Patches

Growing collection of random PowerShell scripts to fix some Windows annoyances I have. Works by creating startup tasks in the scheduler that run whenever you login.

## Current Fix List

- `audiodg.exe` priority and affinity issue that causes popping and static sounds in your mic. *Only really seems to occur when using custom audio drivers like voicemeeter*.

## Installation

1. Clone the repository with `https://github.com/nobu-sh/windows-patches.git`

2. Run `ApplyPatches.ps1` in PowerShell. *Usually just right click and there should be an option*.

3. GLHF!

## Removal

1. Run `RemovePatches.ps1` in PowerShell. *Usually just right click and there should be an option*.

> Ensure to not manually modify or remove the patches in `{USERPROFILE}\.nobu\scheduler-patches`. The removal script depends on it to correctly remove tasks from the scheduler.