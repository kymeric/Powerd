param([switch]$Development = $true)

if($Development) {

    $posh = Get-Module 'posh-git';
    if(! $posh) {
        Write-Host "Installing Module: 'posh-git'";
        Install-Module posh-git -Scope CurrentUser;
    }

    $docs = [Environment]::GetFolderPath("mydocuments");
    $modules = [IO.DirectoryInfo]"$docs\WindowsPowerShell\Modules";
    if(! $modules.Exists) {
        [IO.Directory]::CreateDirectory($modules.FullName);
    }

    # Create link
    $link = "$modules\Powerd";
    $target = "$PSScriptRoot\Modules\Powerd";
    if(! [IO.Directory]::Exists($link)) {
        Write-Host "Linking $target to $link";
        cmd /c mklink /d $link $target;
    }

    $profilePath = [IO.FileInfo]$profile;
    if(! $profile.Exists) {
        Set-Content $profilePath -Value "";
    }
    $existing = Get-Content $profilePath;
    if(! ($existing -like '*posh-git*')) {
        Write-Host "Adding 'Import-Module posh-git;' to your PowerShell Profile";
        Add-Content -Value "Import-Module posh-git;" -Path $profilePath;
    }
    if(! ($existing -like '*Powerd*')) {
        Write-Host "Adding 'Import-Module Powerd;' to your PowerShell Profile";
        Add-Content -Value "Import-Module Powerd;" -Path $profilePath;
    }

    if(! ($existing -like '*function prompt*')) {
        Write-Host "Adding 'function prompt { ... }' to your PowerShell Profile";
        $gitPrompt = @"

function prompt {
    Write-GitPrompt;
}
"@;
        Add-Content -Value $gitPrompt -Path $profilePath;
    }
} else {
    throw "Not implemented";
}