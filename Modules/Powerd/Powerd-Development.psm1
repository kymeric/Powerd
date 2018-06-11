# Initialize Developer Environment from VS batch file
function Initialize-Development {
	$config = Get-PowerdConfig;

	$editions = @('Enterprise', 'Professional', 'Community', 'BuildTools');
	$envCacheFile = Get-PowerdFile "Cache\Development-Environment-$([Environment]::MachineName).ps1"

	if($envCacheFile -and !$envCacheFile.Exists -and !$config.Development.IsDisabled) {
		foreach($edition in $editions)
		{
			$vsDevCmd = [IO.FileInfo]"$([Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFilesX86))\Microsoft Visual Studio\2017\$edition\Common7\Tools\VSDevCmd.bat";
			if($vsDevCmd.Exists) {		
				$effect = Get-BatchFileEnvironmentEffect -File $vsDevCmd -Arg "-arch=amd64";
				$script = $effect.Keys | % {
					$item = $effect[$_];
					if($item.Before -eq $null) {
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
		. $envCacheFile;
	}
}


Initialize-Development;