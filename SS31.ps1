# Define the path to the catalog-info.yml file
$filePath = "C:\path\to\catalog-info.yml"

# Define the new API name to add
$newApiName = "omega"  # Change this to the new API name you want to add

# Read the content of the YAML file
$content = Get-Content -Path $filePath -Raw

# Check if the providesApis section exists
if ($content -match 'providesApis:\s*([\s\S]*?)(?=\n\w|\Z)') {
    # Extract existing APIs
    $existingApis = [regex]::Matches($matches[1], '^\s*-\s*(\S+)', [System.Text.RegularExpressions.RegexOptions]::Multiline) | ForEach-Object { $_.Groups[1].Value }

    # Check if the new API name is already in the list
    if ($existingApis -notcontains $newApiName) {
        # Create a formatted string with the updated APIs
        $updatedApis = ($existingApis + $newApiName) | ForEach-Object { "    - $_" } | Out-String

        # Replace the existing providesApis section with the updated list
        $content = $content -replace 'providesApis:\s*([\s\S]*?)(?=\n\w|\Z)', "providesApis:`n$updatedApis"

        # Write the updated content back to the file
        Set-Content -Path $filePath -Value $content
        Write-Host "Updated providesApis list with new API: $newApiName"
    } else {
        Write-Host "The API name '$newApiName' is already present in the providesApis list."
    }
} else {
    Write-Host "No providesApis section found in the file."
}
