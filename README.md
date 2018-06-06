# Powerd

Installs a powershell module and modifies your powershell profile to set up your VS 2017 environment in powershell.

###
Steps to install

1. Clone this repository
2. Open an administrative powershell prompt in the newly cloned directory
3. Run `powershell.exe -ExecutionPolicy Bypass .\install.ps1`
4. Click `y` or `a` to accept the prompts to configure nuget package provider, download/install posh-git, etc...
5. Close any powershell windows, open a new powershell window

Powerd is now pre-loaded when you open a powershell window.  All of your powershell windows will now have a full VS command prompt environment set up, so you can run msbuild, csc, devenv, etc...  It will also cache the environment variables it extracted from your VS command prompt batch file so opening the powershell prompt is faster in the future.
