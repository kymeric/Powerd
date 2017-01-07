Import-Module "$PSScriptRoot\Powerd-Common.psm1";

function Initialize-Utilities {
    $config = Get-PowerdConfig;
    if($config.Utilities) {
        $config.Utilities | % { Set-Alias $_.Name $ExecutionContext.InvokeCommand.ExpandString($_.Path) -Scope 'global' };
    }
}

#Set a utility to point to an executable/script
function Set-Utility([string]$Path, [string]$Name) {
    $executable = [IO.FileInfo](Convert-Path $Path);
    if(! $executable.Exists) {
        throw "$($executable.FullName) not found";
    }

    if(! $Name) {
        $Name = [IO.Path]::GetFileNameWithoutExtension($executable.FullName);
    }

    $executable = Get-PortablePath $executable;

    $config = Get-PowerdConfig;
    if(! $config.Utilities) {
        Add-Member -InputObject $config -MemberType NoteProperty -Name 'Utilities' -Value @();
    }

    $existing = $config.Utilities | ? { $_.Name -eq $Name };

    if($existing) {
        throw "Existing entry: $existing";
    }

    $config.Utilities += @{Name = $Name; Path = $executable};

    Set-PowerdConfig $config;
    Set-Alias $Name $ExecutionContext.InvokeCommand.ExpandString($executable) -Scope 'global';
}

Initialize-Utilities;