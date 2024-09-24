# Define the path to the catalog-info.yml file
$filePath = "C:\path\to\catalog-info.yml"

# Define the new API name to add
$newApiName = "omega"  # Change this to the new API name you want to add

# Read the content of the YAML file
$content = Get-Content -Path $filePath -Raw

# Check if the providerApis section exists
if ($content -match 'providerApis:\s*([\s\S]*?)(?=\n\w|\Z)') {
    # Extract existing APIs
    $existingApis = [regex]::Matches($matches[1], '^\s*-\s*(\S+)', [System.Text.RegularExpressions.RegexOptions]::Multiline) | ForEach-Object { $_.Groups[1].Value }

    # Check if the new API name is already in the list
    if ($existingApis -notcontains $newApiName) {
        # Add the new API name to the list and format correctly
        $updatedApis = ($existingApis + $newApiName) | ForEach-Object { "    - $_" } -join "`n"
        $content = $content -replace 'providerApis:\s*([\s\S]*?)(?=\n\w|\Z)', "providerApis:`n$updatedApis"

        # Write the updated content back to the file
        Set-Content -Path $filePath -Value $content
        Write-Host "Updated providerApis list with new API: $newApiName"
    } else {
        Write-Host "The API name '$newApiName' is already present in the providerApis list."
    }
} else {
    Write-Host "No providerApis section found in the file."
}



# # Define the path to the catalog-info.yml file
# $filePath = "C:\path\to\catalog-info.yml"

# # Define the new API name to add
# $newApiName = "omega"  # Change this to the new API name you want to add

# # Read the content of the YAML file
# $content = Get-Content -Path $filePath -Raw

# # Check if the providerApis section exists
# if ($content -match 'providerApis:\s*([\s\S]*?)(?=\n\w|\Z)') {
#     # Extract existing APIs
#     $existingApis = [regex]::Matches($matches[1], '^\s*-\s*(\S+)', [System.Text.RegularExpressions.RegexOptions]::Multiline) | ForEach-Object { $_.Groups[1].Value }

#     # Check if the new API name is already in the list
#     if ($existingApis -notcontains $newApiName) {
#         # Add the new API name to the list
#         $updatedApis = ($existingApis + $newApiName) -join "`n    - "
#         $content = $content -replace 'providerApis:\s*([\s\S]*?)(?=\n\w|\Z)', "providerApis:`n    - $updatedApis"

#         # Write the updated content back to the file
#         Set-Content -Path $filePath -Value $content
#         Write-Host "Updated providerApis list with new API: $newApiName"
#     } else {
#         Write-Host "The API name '$newApiName' is already present in the providerApis list."
#     }
# } else {
#     Write-Host "No providerApis section found in the file."
# }















# # Define the path to the catalog-info.yml file
# $filePath = "C:\path\to\catalog-info.yml"

# # Define the new API name to add
# $newApiName = "omega"  # Change this to the new API name you want to add

# # Read the content of the YAML file as an array of lines
# $content = Get-Content -Path $filePath

# # Find the index of the providerApis section
# $index = $content.IndexOf('  providerApis:')

# # If providerApis section is found
# if ($index -ge 0) {
#     # Extract existing APIs
#     $existingApis = $content[$index+1..($content.Length - 1)] | Where-Object { $_ -match "^\s*-\s*.*" }

#     # Check if the new API name is already in the list
#     if ($existingApis -notcontains "- $newApiName") {
#         # Add the new API name
#         $content.Insert($index + 1 + $existingApis.Length, "    - $newApiName")
#         Set-Content -Path $filePath -Value $content
#         Write-Host "Updated providerApis list with new API: $newApiName"
#     } else {
#         Write-Host "The API name '$newApiName' is already present in the providerApis list."
#     }
# } else {
#     Write-Host "No providerApis section found in the file."
# }




# # # Define the path to the catalog-info.yml file
# # $filePath = "C:\path\to\catalog-info.yml"

# # # Define the new API name to add
# # $newApiName = "omega"  # Change this to the new API name you want to add

# # # Read the content of the YAML file
# # $content = Get-Content -Path $filePath -Raw

# # # Regex to find the providerApis section
# # $regex = "(providerApis:\s*[\s\S]*?)(?=\s{2}\w|$)"

# # # Check if the regex matches the providerApis section
# # $matches = [regex]::Matches($content, $regex)

# # if ($matches.Count -gt 0) {
# #     # Extract existing APIs from the matched content
# #     $existingApis = $matches[0].Groups[1].Value -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "^- " }

# #     # Check if the new API name is already in the list
# #     if ($existingApis -notcontains "- $newApiName") {
# #         # Add the new API name to the list
# #         $existingApis += "- $newApiName"
# #         # Replace the providerApis section in the original content
# #         $updatedContent = $content -replace $regex, ("providerApis:`n" + ($existingApis -join "`n"))

# #         # Write the updated content back to the file
# #         Set-Content -Path $filePath -Value $updatedContent
# #         Write-Host "Updated providerApis list with new API: $newApiName"
# #     } else {
# #         Write-Host "The API name '$newApiName' is already present in the providerApis list."
# #     }
# # } else {
# #     Write-Host "No providerApis section found in the file."
# # }

# # # Output the updated content
# # $updatedContent



# # # # Define the path to the catalog-info.yml file
# # # $filePath = "C:\path\to\catalog-info.yml"

# # # # Define the new API name to add
# # # $newApiName = "omega"  # Change this to the new API name you want to add

# # # # Read the content of the YAML file
# # # $content = Get-Content -Path $filePath -Raw

# # # # Regex to find the providerApis section
# # # $regex = "(providerApis:\s*- .*)"

# # # # Check if the regex matches the providerApis section
# # # $matches = [regex]::Matches($content, $regex)

# # # if ($matches.Count -gt 0) {
# # #     # Extract existing APIs from the matched content
# # #     $existingApis = $matches[0].Groups[1].Value -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "^- " }

# # #     # Check if the new API name is already in the list
# # #     if ($existingApis -notcontains "- $newApiName") {
# # #         # Add the new API name to the list
# # #         $existingApis += "- $newApiName"
# # #         # Replace the providerApis section in the original content
# # #         $updatedContent = $content -replace $regex, ("providerApis:`n" + ($existingApis -join "`n"))

# # #         # Write the updated content back to the file
# # #         Set-Content -Path $filePath -Value $updatedContent
# # #         Write-Host "Updated providerApis list with new API: $newApiName"
# # #     } else {
# # #         Write-Host "The API name '$newApiName' is already present in the providerApis list."
# # #     }
# # # } else {
# # #     Write-Host "No providerApis section found in the file."
# # # }

# # # # Output the updated content
# # # $updatedContent








# # # # # Define the path to the catalog-info.yml file
# # # # $filePath = "C:\path\to\catalog-info.yml"

# # # # # Define the new API name to add
# # # # $newApiName = "omega"

# # # # # Read the file content
# # # # $content = Get-Content -Path $filePath

# # # # # Convert content to string and find providerApis section
# # # # $yamlContent = $content -join "`n"

# # # # # Regex to find existing providerApis list
# # # # $regex = "(providerApis:\s*- .*)"
# # # # $matches = [regex]::Matches($yamlContent, $regex)

# # # # # Extract existing APIs
# # # # $existingApis = $matches[0].Groups[1].Value -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "^- " }

# # # # # Add new API if not already present
# # # # if ($existingApis -notcontains "- $newApiName") {
# # # #     $existingApis += "- $newApiName"
# # # #     $updatedContent = $yamlContent -replace $regex, ("providerApis:`n" + ($existingApis -join "`n"))
    
# # # #     # Write the updated content back to the file
# # # #     Set-Content -Path $filePath -Value $updatedContent
    
# # # #     Write-Host "Updated providerApis list with new API: $newApiName"
# # # # } else {
# # # #     Write-Host "$newApiName is already present in providerApis list."
# # # # }

# # # # # Output updated content
# # # # $updatedContent




# # # # if ($matches.Count -gt 0) {
# # # #     # Extract existing APIs
# # # #     $existingApis = $matches[0].Groups[1].Value -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "^- " }
# # # # } else {
# # # #     Write-Host "No matches found for the providerApis section."
# # # # }
