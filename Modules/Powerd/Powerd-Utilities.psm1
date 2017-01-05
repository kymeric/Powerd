$powerdUtilities = [IO.DirectoryInfo]"$($env:LOCALAPPDATA)\Powerd\Utilities";

#Ensure Utilities directory exists
if(! $powerdUtilities.Exists) {
    [IO.Directory]::CreateDirectory($powerdUtilities.FullName);
}

#Ensure it's on the path
if(! ($env:Path -contains $powerdUtilities.FullName)) {
    $env:Path += ";$($powerdUtilities.FullName)";
}

#Set a utility to point to an executable/script
function Set-Utility([string]$Path, [string]$Name) {
    #TODO: Scan $Executable for special paths and replace (make portable)
    $executable = [IO.FileInfo](Convert-Path $Path);
    if(! $executable.Exists) {
        throw "$($executable.FullName) not found";
    }

    if(! $Name) {
        $Name = [IO.Path]::GetFileNameWithoutExtension($executable.FullName);
    }

    $utility = [IO.FileInfo]"$powerdUtilities\$Name.cmd";
    Set-Content $utility -Value "@ECHO OFF`r`n`"$executable`" %*";
}

