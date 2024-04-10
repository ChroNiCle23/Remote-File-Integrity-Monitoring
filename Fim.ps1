Write-Host ""
Write-Host "What would you like to do?"
Write-Host ""
Write-Host "A) Collect new baseline?"
Write-Host "B) Begin monitoring files with saved Baseline?"
Write-Host ""

$response = Read-Host -Prompt "Please enter 'A' or 'B'"

Function Calculate-File-Hash($filepath) {
    $hash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $hash
}

Function Erase-Baseline-If-Already-Exists() { 
    $baselinePath = Join-Path $PSScriptRoot "baseline.txt"
    $baselineExists = Test-Path $baselinePath

    if ($baselineExists) {
        # Delete baseline.txt if already exists
        Remove-Item -Path $baselinePath
    }
}

# Initialize baseline file path
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$baselinePath = Join-Path $scriptDirectory "baseline.txt"

# $hash = Calculate-File-Hash "C:\Users\wende\OneDrive\Desktop\FIM\Files\aaa.txt"

# Write-Host "user entered $($response))"
if ($response -eq "A".ToUpper()) {
    # Delete baseline.txt if already exists
    Erase-Baseline-If-Already-Exists

    # Collect all the files in the target folder
    $files = Get-ChildItem -Path $PSScriptRoot -Recurse -File

    # For each file, Calculate the hash and write it to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath $baselinePath -Append
    }
    #Write-Host "Calculate Hashes, make a new baseline.txt" -ForegroundColor Cyan
}

elseif ($response -eq "B".ToUpper()) {
    # Prompt for remote execution
    $executeRemotely = Read-Host "Do you want to execute the script remotely? (Y/N)"
    if ($executeRemotely -eq "Y") {
        # Remote execution requested
        $remoteComputerName = Read-Host "Enter the remote computer name:"
        $sourcePath = $PSScriptRoot
        $destinationPath = "C:\Users\phone\OneDrive\Desktop\FIM"  # Change this to the appropriate directory on the remote computer
        $scriptPath = Join-Path $destinationPath "Fim.ps1"  # Change YourScript.ps1 to your actual script name
        
        # Copy script and baseline file to the remote computer
        Copy-FilesToRemote -remoteComputerName $remoteComputerName -sourcePath $sourcePath -destinationPath $destinationPath
        
        # Execute the script remotely
        Execute-ScriptRemotely -remoteComputerName $remoteComputerName -scriptPath $scriptPath
        
        exit
    }

    $fileHashDictionary = @{}

    # Load file hash from baseline.txt and store them in a dictionary 
    $filePathsAndHashes = Get-Content -Path $baselinePath

    foreach ($f in $filePathsAndHashes) {
        $fileHashDictionary.Add($f.Split("|")[0], $f.Split("|")[1])
    }

    # Begin monitoring files with saved Baseline
    while ($true) { 
        Start-Sleep -Seconds 1
        $files = Get-ChildItem -Path $PSScriptRoot -Recurse -File
    
        # For each file, Calculate the hash and compare with the baseline
        foreach ($f in $files) {
            $hash = Calculate-File-Hash $f.FullName

            # Notify if a new file has been created 
            if (-not $fileHashDictionary.ContainsKey($hash.Path)) {
                # A new file has been created!
                Write-Host "$($hash.Path) Has been created!" -ForegroundColor Green
            }
            else {
                # Notify if a file has been changed
                if ($fileHashDictionary[$hash.Path] -ne $hash.Hash) {
                    # File has been compromised! Notify the user
                    Write-Host "$($hash.Path) has changed!!!" -ForegroundColor Yellow
                }
            }
        }

        # Check if any baseline files have been deleted
        foreach ($key in $fileHashDictionary.Keys) {
            $baselineFileStillExists = Test-Path -Path $key
            if (-not $baselineFileStillExists) {
                # One of the baseline files must have been deleted. Notify the user
                Write-Host "$($key) Has been deleted!" -ForegroundColor DarkRed -BackgroundColor Gray
            }
        }
    }
}

Function Copy-FilesToRemote {
    param (
        [string]$remoteComputerName,
        [string]$sourcePath,
        [string]$destinationPath
    )

    # Copy files to remote computer
    Copy-Item -Path $sourcePath -Destination "\\$remoteComputerName\$destinationPath" -Recurse -Force
}

Function Execute-ScriptRemotely {
    param (
        [string]$remoteComputerName,
        [string]$scriptPath
    )

    # Execute script remotely on the specified computer
    Invoke-Command -ComputerName $remoteComputerName -FilePath $scriptPath
}
