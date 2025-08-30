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
        $wingetOutput = winget show $packageId.Trim() 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to get info for package: $packageId"
            continue
        }
        
        # Parse installer URL from winget output
        $installerUrl = $null
        foreach ($line in $wingetOutput) {
            if ($line -match "^\s*Installer Url:\s*(.+)$") {
                $installerUrl = $matches[1].Trim()
                break
            }
        }
        
        if (-not $installerUrl) {
            Write-Warning "No installer URL found for package: $packageId"
            continue
        }
        
        Write-Host "Installer URL: $installerUrl"
        
        # Extract filename from URL
        $uri = [System.Uri]$installerUrl
        $filename = Split-Path $uri.AbsolutePath -Leaf
        
        # Fallback filename for possible URL's containing trailing / or query parameters
        if (-not $filename) {
            $filename = "$packageId-installer.exe"
            Write-Host "Using default filename: $filename"
        }
        
        $downloadPath = Join-Path $DownloadDirectory $filename
        
        # Check if file already exists
        if (Test-Path $downloadPath) {
            Write-Host "File already exists, skipping: $filename"
            continue
        }
        
        # Download the installer
        Write-Host "Downloading to: $downloadPath"
        
        try {
            Invoke-WebRequest -Uri $installerUrl -OutFile $downloadPath -UseBasicParsing
            Write-Host "Successfully downloaded: $filename" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to download $packageId`: $($_.Exception.Message)"
            # Clean up partial download if it exists
            if (Test-Path $downloadPath) {
                Remove-Item $downloadPath -Force
            }
        }
    }
    catch {
        Write-Error "Error processing $packageId`: $($_.Exception.Message)"
    }
}

Write-Host "`nDownload process completed!"