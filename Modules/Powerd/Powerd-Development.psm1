# Initialize Developer Environment from VS batch file
function Initialize-Development {
	$config = Get-PowerdConfig;

	$editions = @('Enterprise', 'Professional', 'Community', 'BuildTools');
	$envCacheFile = Get-PowerdFile "Cache\Development-Environment-$([Environment]::MachineName).ps1"

	if(!$envCacheFile.Exists -and $config.Development.VSDevCmd) {
		foreach($edition in $editions)
		{
			$vsDevCmd = [IO.FileInfo]"$([Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFilesX86))\Microsoft Visual Studio\2017\$edition\Common7\Tools\VSDevCmd.bat";
			if($vsDevCmd.Exists) {		
				$diff = Get-BatchFileEnvironmentEffect -File $vsDevCmd -Arg "-arch=amd64";
				$script = $diff.Keys | % { "`$env:$($_) += '$($diff[$_])'" }

				if($envCacheFile.Directory.Exists -eq $false) {
					Write-Host "Creating: $($envCacheFile.DirectoryName)";
					[IO.Directory]::CreateDirectory($envCacheFile.DirectoryName);
				}
				Write-Host "Updating $($envCacheFile.Name)";
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