# Path to the variables-prod.yml file
$variablesFile = "C:\path\to\your\variables-prod.yml"

# Check if the file exists
if (Test-Path $variablesFile) {
    # Read the content of the YAML file
    $variablesContent = Get-Content -Path $variablesFile
    
    # Initialize variables to store the values
    $apiName = ""
    $backendURL = ""

    # Loop through the lines and extract the values for apim_api_name and backend_url
    for ($i = 0; $i -lt $variablesContent.Length; $i++) {
        if ($variablesContent[$i] -like "*apim_api_name*") {
            $apiName = $variablesContent[$i+1] -replace "value:", "" -replace '"', '' -replace "'", '' -replace "\s", ""
            $apiName = $apiName.Trim()
        }
        if ($variablesContent[$i] -like "*backend_url*") {
            $backendURL = $variablesContent[$i+1] -replace "value:", "" -replace '"', '' -replace "'", ''
            $backendURL = $backendURL.Trim()
        }
    }

    # Output the required values
    Write-Host "API Name: $apiName"
    Write-Host "Backend URL: $backendURL"
} else {
    Write-Host "File not found: $variablesFile"
}
