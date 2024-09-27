# Path to your .env file
$envFilePath = ".\path\to\your\.env"

# Check if the .env file exists
if (Test-Path $envFilePath) {
    # Read the .env file line by line
    Get-Content $envFilePath | ForEach-Object {
        # Match lines in the format KEY=VALUE
        if ($_ -match "^(?<key>[^=]+)=(?<value>.*)$") {
            # Set the environment variable for the current user
            [System.Environment]::SetEnvironmentVariable($matches['key'], $matches['value'], 'User')
            Write-Host "Exported: $($matches['key'])=$($matches['value'])"
        }
    }
    Write-Host "All environment variables have been exported successfully."
} else {
    Write-Host "The .env file was not found at the specified path: $envFilePath"
}
