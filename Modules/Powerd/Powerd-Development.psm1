Import-Module $PSScriptRoot/powerd-common.psm1;

# Initialize Developer Environment from VS batch file
function Initialize-Development {
	
	if([Environment]::OSVersion.Platform -in @([PlatformID]::Unix, [PlatformID]::MacOSX)) {
		return;
	}

	$config = Get-PowerdConfig;

	$editions = @('Enterprise', 'Professional', 'Community', 'BuildTools');
	$envCacheFile = Get-PowerdFile @('cache', "development-environment-$([Environment]::MachineName.ToLower()).ps1");

	if($envCacheFile -and !$envCacheFile.Exists -and !$config.Development.IsDisabled) {
		foreach($edition in $editions)
		{
			$vsDevCmd = [IO.FileInfo]"$([Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFilesX86))\Microsoft Visual Studio\2019\$edition\Common7\Tools\VSDevCmd.bat";
			if($vsDevCmd.Exists) {
				Write-Host "Initializing Development using $edition";		
				$effect = Get-BatchFileEnvironmentEffect -File $vsDevCmd -Arg "-arch=amd64";
				$script = $effect.Keys | % {
					$item = $effect[$_];
					if($null -eq $item.Before) {
						"`$env:$($_) = '$($item.After)'";
					} else {
						$diff = $item.After.Replace($item.Before, "").Trim(';');
						"`$env:$($_) = '$diff;' + `$env:$_";
					}
				};

				if($envCacheFile.Directory.Exists -eq $false) {
					Write-Host "Creating: $($envCacheFile.DirectoryName)";
					[IO.Directory]::CreateDirectory($envCacheFile.DirectoryName);
				}
				Write-Host "Updating $envCacheFile";
				Set-Content -Path $envCacheFile -Value $script;
				break;
			}
		}
	}
	if($envCacheFile.Exists) {
		Write-Host "Initializing Development from cache";
		. $envCacheFile;
	}
}


Initialize-Development;