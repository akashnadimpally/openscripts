# Define the paths to your .env and app-config.yaml files
$envFilePath = ".\path\to\your\.env"
$configFilePath = ".\path\to\your\app-config.yaml"

# Check if both files exist
if (!(Test-Path $envFilePath)) {
    Write-Host "The .env file was not found at the specified path: $envFilePath" -ForegroundColor Red
    exit
}

if (!(Test-Path $configFilePath)) {
    Write-Host "The app-config.yaml file was not found at the specified path: $configFilePath" -ForegroundColor Red
    exit
}

# Read the .env file into a hashtable
$envVariables = @{}
Get-Content $envFilePath | ForEach-Object {
    if ($_ -match "^(?<key>[^=]+)=(?<value>.*)$") {
        $envVariables[$matches['key']] = $matches['value']
    }
}

# Read the app-config.yaml file content
$configContent = Get-Content $configFilePath -Raw

# Replace variables in the format ${VARIABLE_NAME} with their values from the .env file
foreach ($key in $envVariables.Keys) {
    $placeholder = "\${$key}" # This matches the placeholder format ${VARIABLE_NAME}
    $value = $envVariables[$key]
    $configContent = $configContent -replace [regex]::Escape($placeholder), $value
}

# Save the modified content back to the app-config.yaml file
Set-Content $configFilePath $configContent

Write-Host "All variables have been replaced in the app-config.yaml file successfully." -ForegroundColor Green
