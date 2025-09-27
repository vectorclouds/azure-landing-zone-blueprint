# PowerShell script to load environment variables from .env file
# Usage: . .\load-env.ps1

param(
    [string]$EnvFile = ".env"
)

if (-not (Test-Path $EnvFile)) {
    Write-Host "[ERROR] Environment file '$EnvFile' not found!" -ForegroundColor Red
    Write-Host "[INFO] Copy .env.example to .env and fill in your values" -ForegroundColor Yellow
    Write-Host "   cp .env.example .env" -ForegroundColor Cyan
    return
}

Write-Host "[LOAD] Loading environment variables from $EnvFile..." -ForegroundColor Green

Get-Content $EnvFile | ForEach-Object {
    if ($_ -match "^\s*([^#][^=]*)\s*=\s*(.*)\s*$") {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        
        # Remove quotes if present
        $value = $value -replace '^"(.*)"$', '$1'
        $value = $value -replace "^'(.*)'$", '$1'
        
        # Skip empty values
        if ($value -and $value -ne "") {
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
            Write-Host "[OK] Set $name" -ForegroundColor Green
        }
    }
}

Write-Host "[SUCCESS] Environment variables loaded successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Available variables:" -ForegroundColor Cyan
Write-Host "- AZURE_SUBSCRIPTION_ID: $env:AZURE_SUBSCRIPTION_ID"
Write-Host "- STORAGE_ACCOUNT_NAME: $env:STORAGE_ACCOUNT_NAME"
Write-Host "- RESOURCE_GROUP_NAME: $env:RESOURCE_GROUP_NAME"
Write-Host "- AZURE_LOCATION: $env:AZURE_LOCATION"