# Initialize Developer Environment from VS 2015 batch file
function Initialize-Development {
	$config = Get-PowerdConfig;

	if($config.Development.VisualStudioVersion) {
		$regKey = [Microsoft.Win32.RegistryKey](Get-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\$($config.Development.VisualStudioVersion)");

		if($regKey) {
			$ide = $regKey.GetValue('InstallDir');
			$batchFile = Convert-Path (Join-Path -Path $ide -ChildPath "..\Tools\VsDevCmd.bat");
			Invoke-BatchFile $batchFile;
		}
	}
}

#Set a persistent variable for a path
function Set-VisualStudioVersion([string]$Version) {

	# TODO: Fancy lookup?  2015 = 14.0?
	$target = $Version;

	$regKey = Get-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\$target";

	if(! $regKey) {
		throw "Unable to locate registry key for Visual Studio: $target";
	}

    $config = Get-PowerdConfig;
    if(! $config.Development) {
		Add-Member -InputObject $config -MemberType NoteProperty -Name 'Development' -Value @{};
    }
	
	$m = Get-Member -InputObject $config -Name 'VisualStudioVersion';
	if(! $m) {
		Add-Member -InputObject $config.Development -MemberType NoteProperty -Name 'VisualStudioVersion' -Value $target;
	} else {
		$config.Development.VisualStudioVersion = $target;
	}
	
    Set-PowerdConfig $config;
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