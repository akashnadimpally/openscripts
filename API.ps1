# Define the root folder where all servicing-contactcenter-* folders are located
$rootFolder = "C:\path\to\your\folders"
$catalogFile = "$rootFolder\catalog-info.yml"

# Loop through all directories starting with servicing-contactcenter-*
$directories = Get-ChildItem -Path $rootFolder -Directory | Where-Object { $_.Name -like "servicing-contactcenter-*" }

foreach ($directory in $directories) {
    $folderPath = $directory.FullName
    $variablesFile = "$folderPath\variables-prod.yml"

    # Check if variables-prod.yml exists in the folder
    if (Test-Path $variablesFile) {
        # Read the variables-prod.yml file and extract values for apim_api_name and backend_url
        $variablesContent = Get-Content -Path $variablesFile -Raw
        $apiName = ($variablesContent | Select-String -Pattern "apim_api_name" -SimpleMatch).Line.Split(":")[1].Trim()
        $backendURL = ($variablesContent | Select-String -Pattern "backend_url" -SimpleMatch).Line.Split(":")[1].Trim()
    } else {
        Write-Host "No variables-prod.yml found in $folderPath. Skipping..."
        continue
    }

    # Look for openapi.json, openAPI.json, or swagger.json files
    $jsonFile = Get-ChildItem -Path $folderPath -Filter "*.json" | Where-Object { $_.Name -like "openapi.json" -or $_.Name -like "openAPI.json" -or $_.Name -like "swagger.json" } | Select-Object -First 1

    if ($jsonFile) {
        # Replace placeholders in the catalog-info.yml template with actual values
        $jsonFilePath = "./$($directory.Name)/$($jsonFile.Name)"

        $apiSection = @"
---
# API section - 1 
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: $apiName
  description: $apiName
  links:
  - url: https://github.com/your-repo/$($directory.Name)
    title: REPO:$($directory.Name)
  - url: $backendURL
    title: backedserviceURL
  tags: []
spec:
  type: openapi
  lifecycle: production
  owner: group:default/
  definition: 
    \$text: $jsonFilePath
"@

        # Append the API section to the catalog-info.yml file
        Add-Content -Path $catalogFile -Value $apiSection

        Write-Host "API section added for $($directory.Name)"
    } else {
        Write-Host "No openapi.json or swagger.json file found in $folderPath. Skipping..."
    }
}
