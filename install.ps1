param([switch]$Development = $true)

if($Development) {

    $posh = Get-Module 'posh-git';
    if(! $posh) {
        Write-Host "Installing Module: 'posh-git'";
        Install-Module posh-git -Scope CurrentUser;
    }

    if($IsLinux -or $IsMacOS) {
        $modules = [IO.DirectoryInfo]"~/.local/share/powershell/Modules";
    } else {
        $docs = [Environment]::GetFolderPath("mydocuments");
        if ($PSEdition -eq 'Core') {
            $modules = [IO.DirectoryInfo]"$docs\PowerShell\Modules";
        } else {
            $modules = [IO.DirectoryInfo]"$docs\WindowsPowerShell\Modules";
        }
    }
    if(! $modules.Exists) {
        [IO.Directory]::CreateDirectory($modules.FullName);
    }

    # Create link
    if(! [IO.Directory]::Exists($link)) {
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
    if(! $profileFile.Exists) {
        Set-Content $profileFile -Value "";
    }
    $existing = Get-Content $profileFile;
    if(! ($existing -like '*posh-git*')) {
        Write-Host "Adding 'Import-Module posh-git;' to your PowerShell Profile";
        Add-Content -Value "Import-Module posh-git;" -Path $profileFile;
    }
    if(! ($existing -like '*Powerd*')) {
        Write-Host "Adding 'Import-Module Powerd;' to your PowerShell Profile";
        Add-Content -Value "Import-Module Powerd;" -Path $profileFile;
    }
} else {
    throw "Not implemented";
}