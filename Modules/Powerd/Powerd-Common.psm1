Set-Variable -Name "Powerd" -Value @{Config = (Get-PowerdFile "config.json")} -Scope global;

function Get-PowerdFile([string[]]$parts) {
    $homeDir = if($env:HOME) { $env:HOME } else { $env:USERPROFILE }
    $target = @($homeDir, ".powerd");
    $target += $Parts;
    return [IO.FileInfo]($target -join [IO.Path]::DirectorySeparatorChar);
}

function Get-PowerdDirectory([string[]]$Parts) {
    $homeDir = if($env:HOME) { $env:HOME } else { $env:USERPROFILE }
    $target = @($homeDir, ".powerd");
    $target += $Parts;
    return [IO.DirectoryInfo]($target -join [IO.Path]::DirectorySeparatorChar);
}

function Get-PowerdConfig() {
    $file = Get-PowerdFile "config.json";
    Write-Debug "Config file: $($file.FullName)";
    if (! $file.Exists) {
        return @{};
    }
    return Get-Content -Path $file | ConvertFrom-Json;
}

function Set-PowerdConfig($Config) {
    $file = Get-PowerdFile "config.json";
    if (! $file.Directory.Exists) {
        [IO.Directory]::CreateDirectory($file.Directory.FullName);
    }
    $Config | ConvertTo-Json | Set-Content -Path $file -Force;
}

function Get-SpecialPortablePaths {
    return [enum]::GetValues([Environment+SpecialFolder]) `
        | % { $path = [Environment]::GetFolderPath($_); if ($path) { @{Name = "([Environment]::GetFolderPath([Environment+SpecialFolder]::$_))"; Path = $path}; } } `
        | Sort { $_.Path.Length } -Descending | ConvertTo-Json | ConvertFrom-Json;
}

function Get-PowerdPortablePaths {
    $config = Get-PowerdConfig;
    if (! $config.Paths) {
        return @();
    }
    $config.Paths | % { $_.Path = $ExecutionContext.InvokeCommand.ExpandString($_.Path); };
    [array]::Reverse($config.Paths);
    return $config.Paths; 
}

function Get-PortablePath([string]$Path) {
    $paths = Get-PowerdPortablePaths;
    $specials = Get-SpecialPortablePaths;
    $paths = $paths + $specials;

    $Path = (Convert-Path $Path).Trim('\', '/');
    foreach ($entry in $paths) {
        if ($Path -like "$($entry.Path)*") {
            $relativePath = $Path.Substring($entry.Path.Length);
            $ret = [IO.Path]::Combine($entry.Name, $relativePath).Trim('\', '/');
            return $ret;
        }
    }
    return $Path.Trim('\', '/');
}

#Set a persistent variable for a path
function Set-Path([string]$Path, [string]$Name) {
    $Path = Get-PortablePath ($Path);

    if (! $Name) {
        $Name = [IO.Path]::GetFileName($ExecutionContext.InvokeCommand.ExpandString($Path));
    }

    $config = Get-PowerdConfig;
    if (! $config.Paths) {
        Add-Member -InputObject $config -MemberType NoteProperty -Name 'Paths' -Value @();
    }

    $existing = $config.Paths | ? { $_.Name -eq $Name };

    if ($existing) {
        throw "Existing entry: $existing";
    }

    $config.Paths += @{Name = $Name; Path = $Path};
    
    Set-PowerdConfig $config;
    Write-Host "Setting $Name to $Path";
    Set-Variable $Name $Path -Scope 'global';
}

function Get-BatchFileEnvironmentEffect([IO.FileInfo]$File, [string]$Arg = $null) {
    if(! $File.Exists) {
        return $ret;
    }
    $ret = @{ };

    $applyMarker = 'APPLYBATCHFILE';

    $cmd = "set && echo $applyMarker && `"$File`" $Arg && set";

    $before = @{};
    $after = @{};
    $isAfter = $false;

    Write-Host "Executing: cmd /c $cmd";

    cmd /c $cmd | . { 
        process {
            $line = $_.Trim();
            if ($line -eq $applyMarker) {
                $isAfter = $true;
            }
            elseif ($line -match '^([^=]+)=(.*)') {
                $variable = $matches[1].Trim();
                $value = $matches[2].Trim();
                if ($isAfter) {
                    $after[$variable] = $value;
                }
                else {
                    $before[$variable] = $value;
                }
            }
        }
    }

    $after.Keys | % {
        $a = $after[$_];
        $b = $before[$_];

        if ($a -ne $b) {
            $ret[$_] = @{
                Before = $before[$_]
                After = $after[$_]
            };
        }
    }

    return $ret;
}

function Get-OperatingSystem {
    if($IsMacOS) {
        return "Mac";
    } elseif($IsLinux) {
        return "Linux";
    } else {
        return "Windows";
    }
}

function Initialize-Paths {
    Write-Debug "Initializing Paths...";
    $config = Get-PowerdConfig;
    $operatingSystem = Get-OperatingSystem;
    $machine = [Environment]::MachineName.ToLowerInvariant();

    Write-Debug "Config values: $($config | ConvertTo-Json -Depth 4)";
    if ($config.Paths) {
        $config.Paths | % { 
            $path = $_.Path;

            $osPaths = $config.OS.$operatingSystem.Paths;
            if($osPaths) {
                $value = $osPaths.$($_.Name);
                if($value) {
                    $path = $value;
                }    
            }

            $machinePaths = $config.Machine.$machine.Paths;
            if($machinePaths) {
                $value = $machinePaths.$($_.Name);
                if($value) {
                    $path = $value;
                }
            }

            $value = $ExecutionContext.InvokeCommand.ExpandString($path);
            Write-Debug "Path $($_.Name): $path = $value";
            Set-Variable $_.Name -Value $value -Scope 'global'; 
        };
    }
}

Initialize-Paths;