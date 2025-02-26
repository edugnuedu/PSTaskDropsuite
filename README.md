# CSV Filter Script

This PowerShell script downloads a ZIP file containing CSV files, extracts them, filters the data based on specific criteria, and outputs the results to a new CSV file.

## Purpose
The script automates the following tasks:
1. Downloads a ZIP file from a specified URL
2. Extracts CSV files from the ZIP
3. Filters records where `status = "active"` and `no_of_messages > 0`
4. Creates a single output CSV with filtered records
5. Reports the total number of messages from filtered records
6. Cleans up temporary files

## Prerequisites
- PowerShell 5.1 or later
- Internet connection to download the ZIP file
- Write permissions in the script's directory
- Sufficient disk space for ZIP download and extraction

## Usage
1. Save the script as `filter_csv.ps1`
2. Open PowerShell in the directory containing the script
3. Run the script:
```powershell
.\filter_csv.ps1