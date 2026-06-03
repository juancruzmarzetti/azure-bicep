$results = az deployment group what-if -g resourceGroupName -f main.bicep
--no-pretty-print --query "changes[*].changeType" --output tsv --mode Complete

foreach ($change in $results) {
    if($change -eq "Create") {
        Write-Host "Create detected"
    } elseif ($change -eq "Delete") {
        Write-Host "Delete detected"
    } elseif ($change -eq "Modify") {
        Write-Host "Modify detected"
    } else {
        Write-Host "No changes detected."
    }
}

Write-Host $results

