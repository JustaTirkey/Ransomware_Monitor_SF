# Define the directory to monitor (current directory)
$monitorDir = Get-Location

# Create the FileSystemWatcher to monitor the directory
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $monitorDir.Path
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# Ensure it detects all file changes
$watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName, 
                        [System.IO.NotifyFilters]::DirectoryName,
                        [System.IO.NotifyFilters]::LastWrite,
                        [System.IO.NotifyFilters]::CreationTime

# Define the action for file changes
$action = {
    param ($eventSource, $eventArgs)

    $changeTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $changeType = $eventArgs.ChangeType
    $filePath = $eventArgs.FullPath
    $currfolder = Split-Path $filePath -Parent
    $filename = Split-Path $filePath -Leaf
    
    # Print event details to the shell
    Write-Host "$changeTime - File '$filePath' was $changeType."

    # If the file change happened in the current directory, create an ACK file
    if ($currfolder -eq $monitorDir.Path) {
        $ackFilePath = "$currfolder\ACK_$filename.txt"
        New-Item -ItemType File -Path $ackFilePath -Force | Out-Null
        Write-Host "Created ACK file: $ackFilePath"
    }
}

# Register the event handlers for "Created", "Changed", and "Deleted" events
$CreatedEvent = Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action
$ChangedEvent = Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action
$DeletedEvent = Register-ObjectEvent -InputObject $watcher -EventName "Deleted" -Action $action


# Keep the script running for monitoring
Write-Host "Monitoring started in '$monitorDir'. Press [Ctrl+C] to stop."

# Infinite loop to keep the script running
try {
    while ($true) {
        Start-Sleep -Seconds 2
    }
} finally {
    # Cleanup: Unregister all event handlers when the script stops
    Unregister-Event -SubscriptionId $CreatedEvent.Id
    Unregister-Event -SubscriptionId $ChangedEvent.Id
    Unregister-Event -SubscriptionId $DeletedEvent.Id
    $watcher.Dispose()
    Write-Host "Monitoring stopped."
}


