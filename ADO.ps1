# Variables for your Azure DevOps organization and project
$organization = "your-organization-name"
$project = "your-project-name"
$repository = "your-repo-name"
$keyword = "<base />"

# Personal Access Token (PAT) for authentication
$pat = "your-pat-token"

# Base64 encode the PAT
$headers = @{
    Authorization = ("Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)")))
}

# API endpoint for searching code in the repository
$searchUrl = "https://dev.azure.com/$organization/$project/_apis/search/codeQueries?api-version=6.0-preview.1"

# JSON body for search query
$body = @{
    searchText = $keyword
    top = 1000 # Max results to fetch
} | ConvertTo-Json

# Send request to search the keyword in the repository
$response = Invoke-RestMethod -Uri $searchUrl -Method Post -Headers $headers -Body $body -ContentType "application/json"

# Check if the response contains any search results
if ($response.results.Count -gt 0) {
    $results = @()

    # Iterate through the search results and extract file and repo name
    foreach ($result in $response.results) {
        $fileName = $result.fileName
        $repoName = $result.repository.name
        $results += [pscustomobject]@{
            FileName = $fileName
            RepoName = $repoName
        }
    }

    # Export results to CSV
    $csvPath = "C:\Path\To\Save\Results.csv"
    $results | Export-Csv -Path $csvPath -NoTypeInformation

    Write-Host "Results exported successfully to CSV."
} else {
    Write-Host "No results found for the keyword."
}
