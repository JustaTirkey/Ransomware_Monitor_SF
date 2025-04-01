# Log file location
$logFile = "$env:USERPROFILE\system_performance.log"

# Interval for performance data collection in seconds (e.g., 5 seconds)
$interval = 5

# Start logging
"Monitoring system performance..." | Out-File -FilePath $logFile -Append
"Start Time: $(Get-Date)" | Out-File -FilePath $logFile -Append
"--------------------------------------" | Out-File -FilePath $logFile -Append
"Interval: $interval seconds" | Out-File -FilePath $logFile -Append
"--------------------------------------" | Out-File -FilePath $logFile -Append

# Infinite monitoring (press Ctrl+C to stop)
while ($true) {
    # Log the date and time of the performance data capture
    "--------------------------------------" | Out-File -FilePath $logFile -Append
    "Timestamp: $(Get-Date)" | Out-File -FilePath $logFile -Append
    "--------------------------------------" | Out-File -FilePath $logFile -Append

    # CPU Usage
    "CPU Usage (Get-WmiObject):" | Out-File -FilePath $logFile -Append
    $cpuUsage = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty LoadPercentage
    "$cpuUsage%" | Out-File -FilePath $logFile -Append
    Write-Host "CPU Usage: $cpuUsage%"

    # Memory Usage
    "Memory Usage (Get-WmiObject):" | Out-File -FilePath $logFile -Append
    $memoryInfo = Get-WmiObject -Class Win32_OperatingSystem
    $totalMemory = [math]::round($memoryInfo.TotalVisibleMemorySize / 1MB, 2)
    $freeMemory = [math]::round($memoryInfo.FreePhysicalMemory / 1MB, 2)
    $usedMemory = $totalMemory - $freeMemory
    $memoryUsage = [math]::round(($usedMemory / $totalMemory) * 100, 2)
    "Used Memory: $usedMemory MB, Free Memory: $freeMemory MB, Total Memory: $totalMemory MB" | Out-File -FilePath $logFile -Append
    "Memory Usage: $memoryUsage%" | Out-File -FilePath $logFile -Append
    Write-Host "Memory Usage: $memoryUsage%"

    # Disk Usage
    "Disk Usage (Get-WmiObject):" | Out-File -FilePath $logFile -Append
    Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        $disk = $_
        if ($disk.Size -gt 0) {
            $diskUsage = [math]::round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 2)
            "$($disk.DeviceID) - $diskUsage% Used" | Out-File -FilePath $logFile -Append
            Write-Host "$($disk.DeviceID) - $diskUsage% Used"
        }
    }

    # Number of Running Processes
    $processCount = (Get-Process).Count
    "Number of Running Processes: $processCount" | Out-File -FilePath $logFile -Append
    Write-Host "Running Processes: $processCount"

    # Top Processes by CPU
    "Top Processes (Get-Process):" | Out-File -FilePath $logFile -Append
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 | ForEach-Object {
        "$($_.Name) - $($_.CPU) CPU" | Out-File -FilePath $logFile -Append
        Write-Host "$($_.Name) - $($_.CPU) CPU"
    }

    # Add a blank line to separate each iteration
    "" | Out-File -FilePath $logFile -Append

    # Sleep for the specified interval
    Start-Sleep -Seconds $interval
}
