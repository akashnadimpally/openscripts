# Define the path to the catalog-info.yml file
$filePath = "C:\path\to\catalog-info.yml"

# Define the new API name to add
$newApiName = "omega"

# Read the file content
$content = Get-Content -Path $filePath

# Convert content to string and find providerApis section
$yamlContent = $content -join "`n"

# Regex to find existing providerApis list
$regex = "(providerApis:\s*- .*)"
$matches = [regex]::Matches($yamlContent, $regex)

# Extract existing APIs
$existingApis = $matches[0].Groups[1].Value -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "^- " }

# Add new API if not already present
if ($existingApis -notcontains "- $newApiName") {
    $existingApis += "- $newApiName"
    $updatedContent = $yamlContent -replace $regex, ("providerApis:`n" + ($existingApis -join "`n"))
    
    # Write the updated content back to the file
    Set-Content -Path $filePath -Value $updatedContent
    
    Write-Host "Updated providerApis list with new API: $newApiName"
} else {
    Write-Host "$newApiName is already present in providerApis list."
}

# Output updated content
$updatedContent




if ($matches.Count -gt 0) {
    # Extract existing APIs
    $existingApis = $matches[0].Groups[1].Value -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "^- " }
} else {
    Write-Host "No matches found for the providerApis section."
}
