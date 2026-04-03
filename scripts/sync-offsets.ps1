# sync-offsets.ps1

# Set Git Configuration
git config --global user.name "your-github-username"
git config --global user.email "your-email@example.com"

# Setting variables
$localPath = 'C:\Users\Administrator\Downloads\project69\project69\dump\output'
$repoUrl = 'https://github.com/lucaomecetref-ops/cs2offsets.git'
$repoDir = 'C:\path\to\your\local\repo\cs2offsets'  # Local path to the cloned repo

# Clone the repo if it does not exist
if (-not (Test-Path $repoDir)) {
    git clone $repoUrl $repoDir
}

Set-Location $repoDir

# Initialize FileSystemWatcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $localPath
$watcher.Filter = '*.*'
$watcher.IncludeSubdirectories = $true

# Define the action on change
$action = {
    Start-Sleep -Seconds 1  # Delay to ensure the file operation is complete
    git add .
    $commitMessage = "Auto-commit: Changes detected on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git commit -m $commitMessage
    git push origin main
}

# Register event handlers
Register-ObjectEvent $watcher 'Changed' -Action $action
Register-ObjectEvent $watcher 'Created' -Action $action
Register-ObjectEvent $watcher 'Deleted' -Action $action
Register-ObjectEvent $watcher 'Renamed' -Action $action

# Start monitoring
$watcher.EnableRaisingEvents = $true
Write-Host "Monitoring changes in $localPath. Press [Enter] to exit."
[Console]::ReadLine() | Out-Null

# Cleanup
Unregister-Event -SourceIdentifier $watcher
$watcher.Dispose()