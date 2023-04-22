# Functions lists
This file fetures tables tracking ideas (the easy part) vs implented functionality (the fun part, sometimes tricky part, but definately the *reason why* part, in the spirit of the great Terry A. Davis)

## bootstrapping
| fature | get | set | progress | comments |
| -------| --- | --- | -------- | -------- |
| chocolatey | x | x | 100% | The choco.exe executable |
| ChocolateyGet | x | x | 100% | The ChcolateyGet module |
| Git client | x | x | 100% | Git client |
| Legacy Package Management | x | x | 100% | The legacy PackageManagement module must be physically removed from every instance of Windows for modern package management to function properly |
| nuget provider | x | x | 100% | The nuget provider must be upgraded to make package management work on a windows system. The nuget that comes out-of-the-box is for mysterious reasons insufficient for proper package management |
| nuget module | x | x | 100% | After reaplacing the nuget provider, the nuget powershell module must be installed |
| PackageManagement | x | x | 100% | The PackageManagement (aka "OneGet") module must be upgraded to a certain level |
| PowerShellGet | x | x | 100% | The PowershellGet module must be upgraded |
| oscdimg |  |  | 0% | n/a |
| powershell execution policy |  |  | 0% | n/a | 
| f1 |  |  | 0% | n/a |
| f2 |  |  | 0% | n/a |
| f3 |  |  | 0% | n/a |
| f4 |  |  | 0% | n/a |

## sources
The sources-part of the module, registers online (public) or private sources for package management. While features, optional features, capabilities and so on are predominantly available-in-os, allthough semibright brains at Microsoft has romanced with ideas of removing this lately (there must be idiots at every company. Microsoft is no exception, allthough current employees).

## executing

