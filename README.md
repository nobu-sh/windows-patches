# Windows Patches

Growing collection of random PowerShell scripts to fix some Windows annoyances I have. Works by creating startup tasks in the scheduler that run whenever you login.

## Current Fix List

- `audiodg.exe` priority and affinity issue that causes popping and static sounds in your mic. *Only really seems to occur when using custom audio drivers like voicemeeter*.

## Installation

1. Clone the repository with `https://github.com/nobu-sh/windows-patches.git`

2. Run `ApplyPatches.ps1` in PowerShell. *Usually just right click and there should be an option*.

## Updating

1. Run `git pull`.

2. Run `ApplyPatches.ps1` in PowerShell. *Usually just right click and there should be an option*.

> The apply patches command checks to see if a task is already scheduled for existing patches and will not create duplicates.

## Removal

1. Run `RemovePatches.ps1` in PowerShell. *Usually just right click and there should be an option*.

> Ensure to not manually modify or remove the patches in `{USERPROFILE}\.nobu\scheduler-patches`. The removal script depends on it to correctly remove tasks from the scheduler.


## Contributing

New startup patches should follow the lower snake case naming. Do not change the name of existing tasks otherwise updating will not work as intended creating duplicate tasks and possibly broken tasks.

