# Define the path to the catalog-info.yml file
$filePath = "C:\path\to\catalog-info.yml"

# Define the new API name to add
$newApiName = "omega"  # Change this to the new API name you want to add

# Read the content of the YAML file
$content = Get-Content -Path $filePath -Raw

# Regex to find the providerApis section
$regex = "(providerApis:\s*- .*)"

# Check if the regex matches the providerApis section
$matches = [regex]::Matches($content, $regex)

if ($matches.Count -gt 0) {
    # Extract existing APIs from the matched content
    $existingApis = $matches[0].Groups[1].Value -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "^- " }

    # Check if the new API name is already in the list
    if ($existingApis -notcontains "- $newApiName") {
        # Add the new API name to the list
        $existingApis += "- $newApiName"
        # Replace the providerApis section in the original content
        $updatedContent = $content -replace $regex, ("providerApis:`n" + ($existingApis -join "`n"))

        # Write the updated content back to the file
        Set-Content -Path $filePath -Value $updatedContent
        Write-Host "Updated providerApis list with new API: $newApiName"
    } else {
        Write-Host "The API name '$newApiName' is already present in the providerApis list."
    }
} else {
    Write-Host "No providerApis section found in the file."
}

# Output the updated content
$updatedContent








# # Define the path to the catalog-info.yml file
# $filePath = "C:\path\to\catalog-info.yml"

# # Define the new API name to add
# $newApiName = "omega"

# # Read the file content
# $content = Get-Content -Path $filePath

# # Convert content to string and find providerApis section
# $yamlContent = $content -join "`n"

# # Regex to find existing providerApis list
# $regex = "(providerApis:\s*- .*)"
# $matches = [regex]::Matches($yamlContent, $regex)

# # Extract existing APIs
# $existingApis = $matches[0].Groups[1].Value -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "^- " }

# # Add new API if not already present
# if ($existingApis -notcontains "- $newApiName") {
#     $existingApis += "- $newApiName"
#     $updatedContent = $yamlContent -replace $regex, ("providerApis:`n" + ($existingApis -join "`n"))
    
#     # Write the updated content back to the file
#     Set-Content -Path $filePath -Value $updatedContent
    
#     Write-Host "Updated providerApis list with new API: $newApiName"
# } else {
#     Write-Host "$newApiName is already present in providerApis list."
# }

# # Output updated content
# $updatedContent




# if ($matches.Count -gt 0) {
#     # Extract existing APIs
#     $existingApis = $matches[0].Groups[1].Value -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "^- " }
# } else {
#     Write-Host "No matches found for the providerApis section."
# }
