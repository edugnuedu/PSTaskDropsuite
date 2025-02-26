# Our task is to implement a PowerShell script to automate the following steps. Include logging and error handling as required: 
# 1. Download and extract a ZIP file from the given URL: https://coding-test-sample-data.s3.ap-southeast-1.amazonaws.com/sample_data.zip
# 2. This ZIP file may contain one or more CSV files. All the CSV files have the same headers but are from different partners (partner_id, organization_name, email, status, no_of_messages).
# 3. Extract the rows with a status of 'active' and no_of_messages > 0, and create a single CSV file with the filtered records.
# 4. At the end of the script, output the total number of messages from the filtered records.


# Define variables
$scriptFolder = $PSScriptRoot
$zipFile = "$scriptFolder\sample_data.zip"
$extractFolder = "$scriptFolder\sample_data"
$outputCsvFile = "$scriptFolder\filtered_output_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$logFile = "$scriptFolder\script_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$downloadUrl = "https://coding-test-sample-data.s3.ap-southeast-1.amazonaws.com/sample_data.zip"

# Write to log and print to console
function Write-ToLog($message) {
    $timeNow = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $fullMessage = "$timeNow - $message"
    Add-Content -Path $logFile -Value $fullMessage
    Write-Host $fullMessage
}

# Start the script
Write-ToLog "Script execution started"

# Make sure extract folder exists
if ((Test-Path $extractFolder) -eq $false) {
    New-Item -Path $extractFolder -ItemType Directory
}

# Download the zip file
Write-ToLog "Downloading ZIP file from URL"
$downloadWorked = $true
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
    Write-ToLog "ZIP file downloaded successfully"
}
catch {
    Write-ToLog "Error downloading ZIP file: $_"
    $downloadWorked = $false
}

if ($downloadWorked -eq $false) {
    Write-ToLog "Script stopped because download failed"
    exit
}

# Extract the zip file
Write-ToLog "Extracting ZIP file"
$extractWorked = $true
try {
    Expand-Archive -Path $zipFile -DestinationPath $extractFolder -Force
    Write-ToLog "ZIP file extracted successfully"
    
    $filesFound = Get-ChildItem -Path $extractFolder -Recurse
    Write-ToLog "Extracted contents count: $($filesFound.Count)"
    if ($filesFound.Count -gt 0) {
        Write-ToLog "Extracted files/folders:"
        foreach ($item in $filesFound) {
            $itemType = "File"
            if ($item.PSIsContainer) {
                $itemType = "Directory"
            }
            Write-ToLog "  - $($item.FullName) (Type: $itemType)"
        }
    }
}
catch {
    Write-ToLog "Error extracting ZIP file: $_"
    $extractWorked = $false
}

if ($extractWorked -eq $false) {
    Write-ToLog "Script stopped because extraction failed"
    exit
}

# Check for CSV files
Write-ToLog "Processing CSV files"
$csvFiles = Get-ChildItem -Path $extractFolder -Filter "*.csv" -Recurse
if ($csvFiles.Count -eq 0) {
    Write-ToLog "No CSV files found in extracted ZIP"
    Write-ToLog "Script stopped because no CSV files found"
    exit
}

# Process each CSV file
$allFilteredRecords = @()
foreach ($csv in $csvFiles) {
    Write-ToLog "Processing file: $($csv.Name)"
    $records = Import-Csv -Path $csv.FullName
    $filteredRecords = @()
    
    foreach ($record in $records) {
        if ($record.status -eq "active" -and [int]$record.no_of_messages -gt 0) {
            $filteredRecords += $record
        }
    }
    
    $allFilteredRecords += $filteredRecords
    Write-ToLog "Found $($filteredRecords.Count) active records in $($csv.Name)"
}

# Save the filtered records
if ($allFilteredRecords.Count -gt 0) {
    Write-ToLog "Exporting $($allFilteredRecords.Count) filtered records to $outputCsvFile"
    $allFilteredRecords | Export-Csv -Path $outputCsvFile -NoTypeInformation
}
else {
    Write-ToLog "No records matched the filter criteria"
}

# Count total messages
$totalMessages = 0
foreach ($record in $allFilteredRecords) {
    $totalMessages = $totalMessages + [int]$record.no_of_messages
}
Write-ToLog "Total number of messages from filtered records: $totalMessages"

Write-ToLog "Script completed successfully"

# Clean up files
Write-ToLog "Performing cleanup"
if (Test-Path $zipFile) {
    Remove-Item $zipFile
}
if (Test-Path $extractFolder) {
    Remove-Item $extractFolder -Recurse
}
Write-ToLog "Cleanup completed"