# Example of build & deploy using Powershell (with credentials already set in the session)

az bicep build -f main.bicep

bicep build main.bicep






New-AzResourceGroup -Name 'bicep-rg' -Location 'West Europe' -Force

$Parameters = @{
    name         = 'mainDeployment' + (Get-Date).toString('yyyyMMddhhmmss')
    TemplateFile = 'main.bicep'
    ResourceGroupName = 'bicep-rg'
    AppServiceAppName = 'bicepmoduleexample'
}


New-AzResourceGroupDeployment @Parameters -Verbose