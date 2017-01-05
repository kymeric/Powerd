
#Initialize Developer Environment from VS 2015 batch file
function Initialize-DeveloperEnvironment {
	$tempFile = [IO.Path]::GetTempFileName();
	$batchFile = '"C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\VsDevCmd.bat"';
	$tempFileName = '"' + $tempFile + '"';
	cmd /c " $batchFile && set > $tempFileName";
	Get-Content $tempFile | ForEach-Object {
		if($_ -match "^(.*?)=(.*)$"){
			Set-Content "env:\$($matches[1])" $matches[2];
		}
	}
	Remove-Item $tempFile;
}

Initialize-DeveloperEnvironment;