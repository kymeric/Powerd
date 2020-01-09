
#Invoke 1 or more $Command(s) on 1 or more $Computer(s)
function Invoke-Ssh([string[]]$Computer, [string[]]$Command, [string]$Shell = "sh -") {
    foreach($cpu in $Computer) {
        foreach($cmd in $Command) {
            #Give some visual separation for each command
            $separator = [String]::new('-', $cpu.Length);
            Write-Host -ForegroundColor Cyan " $separator";
            Write-Host -ForegroundColor Cyan "[$cpu]`>: " -NoNewline;
            Write-Host -ForegroundColor Yellow $cmd;
            Write-Host -ForegroundColor Cyan " $separator";

            $args = @($cpu);
            #Base64 encode
            $encodedCommand = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($cmd));

            #Echo on $cpu, base64 decode and send to $Shell
            $args += "echo '$encodedCommand' | base64 -d | $Shell";
            Write-Debug "Executing: ssh $($args -join ' ')";
            $process = Start-Process -FilePath "ssh" -ArgumentList $args -NoNewWindow -Wait -PassThru;            
            if($process.ExitCode -ne 0) {
                if($ErrorActionPreference -eq 'silentlycontinue') {
                } elseif($ErrorActionPreference -eq 'continue') {
                    Write-Warning "Warning: SSH exit code = $($process.ExitCode)";
                } else {
                    throw "Error: SSH exit code = $($process.ExitCode)";
                }
            }
        }
    }
}