# Variables for your Azure DevOps organization and project
$organization = "your-organization-name"
$project = "your-project-name"
$keyword = "<base />"

# Personal Access Token (PAT) for authentication
$pat = "your-pat-token"

# Base64 encode the PAT
$headers = @{
    Authorization = ("Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)")))
}

# Get the list of all repositories in the project
$reposUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories?api-version=6.0"
$reposResponse = Invoke-RestMethod -Uri $reposUrl -Method Get -Headers $headers

# Check if there are repositories
if ($reposResponse.value.Count -gt 0) {
    $results = @()

    # Loop through each repository
    foreach ($repo in $reposResponse.value) {
        $repoName = $repo.name
        $repoId = $repo.id

        # API endpoint for searching code in the repository
        $searchUrl = "https://dev.azure.com/$organization/$project/_apis/search/codeQueries?api-version=6.0-preview.1"

        # JSON body for search query
        $body = @{
            searchText = $keyword
            repositoryFilters = @($repoId)
            top = 1000 # Max results to fetch
        } | ConvertTo-Json

        # Send request to search the keyword in the current repository
        $searchResponse = Invoke-RestMethod -Uri $searchUrl -Method Post -Headers $headers -Body $body -ContentType "application/json"

        # Check if the search response contains results
        if ($searchResponse.results.Count -gt 0) {
            foreach ($result in $searchResponse.results) {
                $fileName = $result.fileName
                $results += [pscustomobject]@{
                    FileName = $fileName
                    RepoName = $repoName
                }
            }
        }
    }

    # Export results to CSV
    if ($results.Count -gt 0) {
        $csvPath = "C:\Path\To\Save\Results.csv"
        $results | Export-Csv -Path $csvPath -NoTypeInformation
        Write-Host "Results exported successfully to CSV."
    } else {
        Write-Host "No matches found for the keyword across all repositories."
    }
} else {
    Write-Host "No repositories found in the project."
}
