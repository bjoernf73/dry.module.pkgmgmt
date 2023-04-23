# Functions lists
This file fetures tables tracking ideas (the easy part) vs implented functionality (the fun part, sometimes tricky part, but definately the *reason why* part, in the spirit of the great Terry A. Davis)

## Bootstrapping
| feature | get | set | progress | comments |
| -------| --- | --- | -------- | -------- |
| Chocolatey | x | x | 100% | The choco.exe executable |
| ChocolateyGet | x | x | 100% | The ChcolateyGet module |
| Git client | x | x | 100% | Git client |
| Legacy Package Management | x | x | 100% | The legacy PackageManagement module must be physically removed from every instance of Windows for modern package management to function properly |
| Nuget Provider | x | x | 100% | The nuget provider must be upgraded to make package management work on a windows system. The nuget that comes out-of-the-box is for mysterious reasons insufficient for proper package management |
| Nuget Module | x | x | 100% | After reaplacing the nuget provider, the nuget powershell module must be installed |
| PackageManagement | x | x | 100% | The PackageManagement (aka "OneGet") module must be upgraded to a certain level |
| PowerShellGet | x | x | 100% | The PowershellGet module must be upgraded |
| oscdimg |  |  | 0% | n/a |
| PowerShell execution policy |  |  | 0% | n/a | 
| f1 |  |  | 0% | n/a |
| f2 |  |  | 0% | n/a |
| f3 |  |  | 0% | n/a |
| f4 |  |  | 0% | n/a |

## Providers
The providers-part registers online (public) or private sources for packages. 

| feature | get | set | progress | comments |
| -------| --- | --- | -------- | -------- |
| Providers |  |  | 0% | Custom providers of any type |
| Chocolatey |  |  | 0% | register your private chocolatey provider in the os to be used by choco.exe|

## Executing