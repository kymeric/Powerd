param([switch]$Development = $true)

if($Development) {

    $posh = Get-Module 'posh-git';
    if(-not $posh) {
        Write-Host "Installing Module: 'posh-git'";
        Install-Module posh-git -Scope CurrentUser;
    }

    if($IsLinux -or $IsMacOS) {
        $modules = [IO.DirectoryInfo]"$HOME/.local/share/powershell/Modules";
    } else {
        $docs = [Environment]::GetFolderPath("mydocuments");
        if ($PSEdition -eq 'Core') {
            $modules = [IO.DirectoryInfo]"$docs\PowerShell\Modules";
        } else {
            $modules = [IO.DirectoryInfo]"$docs\WindowsPowerShell\Modules";
        }
    }
    if(-not $modules.Exists) {
        [IO.Directory]::CreateDirectory($modules.FullName);
    }

    # Create link
    if(-not [IO.Directory]::Exists($link)) {
        if($IsLinux -Or $IsMacOS) {
            $link = "$modules/Powerd";
            $target = "$PSScriptRoot/Modules/Powerd";
            Write-Host "Linking $target to $link";
            ln -sd $target $link;
        } else {
            $link = "$modules\Powerd";
            $target = "$PSScriptRoot\Modules\Powerd";
            Write-Host "Linking $target to $link";
            cmd /c mklink /d $link $target;
        }
        if($LASTEXITCODE -ne 0) {
            throw "Error linking $target to $link";
        }
    }

    $profileFile = [IO.FileInfo]$profile;
    if(-not $profileFile.Exists) {
        if(-not $profileFile.Directory.Exists) {
            [IO.Directory]::CreateDirectory($profileFile.Directory.FullName);
        }
        Set-Content $profileFile -Value "";
    }
    $existing = Get-Content $profileFile;
    if(-not ($existing -like '*posh-git*')) {
        Write-Host "Adding 'Import-Module posh-git;' to your PowerShell Profile";
        Add-Content -Value "Import-Module posh-git;" -Path $profileFile;
    }
    if(-not ($existing -like '*Powerd*')) {
        Write-Host "Adding 'Import-Module Powerd;' to your PowerShell Profile";
        Add-Content -Value "Import-Module Powerd;" -Path $profileFile;
    }
} else {
    throw "Not implemented";
}