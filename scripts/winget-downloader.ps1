param(
    [Parameter(Mandatory=$true)]
    [string]$PackageListFile,
    
    [Parameter(Mandatory=$true)]
    [string]$DownloadDirectory
)

# Validate inputs
if (-not (Test-Path $PackageListFile)) {
    Write-Error "Package list file not found: $PackageListFile"
    exit 1
}

if (-not (Test-Path $DownloadDirectory)) {
    Write-Host "Creating download directory: $DownloadDirectory"
    New-Item -ItemType Directory -Path $DownloadDirectory -Force | Out-Null
}

# Read package IDs from file
$packageIds = Get-Content $PackageListFile | Where-Object { $_.Trim() -ne "" -and -not $_.StartsWith("#") }

Write-Host "Found $($packageIds.Count) packages to process"

foreach ($packageId in $packageIds) {
    Write-Host "`nProcessing: $packageId"
    
    try {
        # Get package info from winget
        $wingetOutput = winget show $packageId.Trim() --accept-source-agreements 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to get info for package: $packageId"
            continue
        }
        
        # Parse package information from winget output
        $packageName = $null
        $packageVersion = $null
        $installerUrl = $null
        
        foreach ($line in $wingetOutput) {
            if ($line -match "^\s*Found\s+(.+?)\s+\[(.+?)\]") {
                $packageName = $matches[1].Trim()
                # Package ID is in brackets, but we want the display name
            }
            elseif ($line -match "^\s*Version:\s*(.+)$") {
                $packageVersion = $matches[1].Trim()
            }
            elseif ($line -match "^\s*Installer Url:\s*(.+)$") {
                $installerUrl = $matches[1].Trim()
            }
        }
        
        # If packageName is still null, try to extract from Publisher/Name format
        if (-not $packageName) {
            foreach ($line in $wingetOutput) {
                if ($line -match "^\s*Package Name:\s*(.+)$") {
                    $packageName = $matches[1].Trim()
                    break
                }
                elseif ($line -match "^\s*Name:\s*(.+)$") {
                    $packageName = $matches[1].Trim()
                    break
                }
            }
        }
        
        if (-not $installerUrl) {
            Write-Warning "No installer URL found for package: $packageId"
            continue
        }
        
        if (-not $packageName -or -not $packageVersion) {
            Write-Warning "Could not extract package name or version for: $packageId"
            Write-Warning "Name: $packageName, Version: $packageVersion"
            Write-Warning "Falling back to package ID for filename"
            $packageName = $packageId
            $packageVersion = "unknown"
        }
        
        Write-Host "Package Name: $packageName"
        Write-Host "Package Version: $packageVersion"
        Write-Host "Installer URL: $installerUrl"
        
        # Extract file extension from URL
        $uri = [System.Uri]$installerUrl
        $originalFilename = Split-Path $uri.AbsolutePath -Leaf
        $extension = [System.IO.Path]::GetExtension($originalFilename)
        
        # If no extension found, default to .unknown
        if (-not $extension) {
            $extension = ".unknown"
        }
        
        # Clean package name for filename (remove invalid characters and replace spaces)
        $cleanPackageName = $packageName -replace '[<>:"/\\|?*]', '-' -replace '\s+', '_'
        $cleanVersion = $packageVersion -replace '[<>:"/\\|?*]', '-' -replace '\s+', '_'
        
        # Generate custom filename
        $filename = "$cleanPackageName-$cleanVersion$extension"
        $downloadPath = Join-Path $DownloadDirectory $filename
        
        # Check if file already exists
        if (Test-Path $downloadPath) {
            Write-Host "File already exists, skipping: $filename"
            continue
        }
        
        # Download the installer with retry logic
        Write-Host "Downloading to: $filename"
        
        $maxRetries = 3
        $retryCount = 0
        $downloaded = $false
        
        while (-not $downloaded -and $retryCount -lt $maxRetries) {
            try {
                Invoke-WebRequest -Uri $installerUrl -OutFile $downloadPath -UseBasicParsing -TimeoutSec 300
                $downloaded = $true
                Write-Host "Successfully downloaded: $filename" -ForegroundColor Green
            }
            catch {
                $retryCount++
                Write-Warning "Download attempt $retryCount failed: $($_.Exception.Message)"
                
                if ($retryCount -lt $maxRetries) {
                    Write-Host "Retrying in 5 seconds..."
                    Start-Sleep -Seconds 5
                }
                
                # Clean up partial download
                if (Test-Path $downloadPath) {
                    Remove-Item $downloadPath -Force
                }
            }
        }
        
        if (-not $downloaded) {
            Write-Warning "Failed to download $packageId after $maxRetries attempts"
        }
    }
    catch {
        Write-Error "Error processing $packageId`: $($_.Exception.Message)"
    }
}

Write-Host "`nDownload process completed!"