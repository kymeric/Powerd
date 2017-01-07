
#Initialize Developer Environment from VS 2015 batch file
function Initialize-Development {
	$batchFile = [IO.FileInfo]"C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\VsDevCmd.bat";
	if(! $batchFile.Exists) {
		return;
	}

	$tempFile = [IO.Path]::GetTempFileName();
	cmd /c " `"$batchFile`" && set > `"$tempFile`"";
	try {
		Get-Content $tempFile | ForEach-Object {
			if($_ -match "^(.*?)=(.*)$"){
				Set-Content "env:\$($matches[1])" $matches[2];
			}
		}	
	}
	finally {
		Remove-Item $tempFile;		
	}
}

function Write-GitPrompt {
    $realLASTEXITCODE = $LASTEXITCODE;

    # Reset color, which can be messed up by Enable-GitColors
    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor;
    Write-Host($pwd.ProviderPath) -NoNewline;
    Write-VcsStatus;
    $global:LASTEXITCODE = $realLASTEXITCODE;
    return "> ";
}

Initialize-Development;