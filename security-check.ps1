# Security validation script for public repository
param(
    [switch]$Fix
)

Write-Host "Security Validation for Public Repository" -ForegroundColor Cyan
Write-Host "=========================================="

$Issues = 0
$Warnings = 0

# Check 1: Verify .gitignore exists and has required entries
Write-Host "Checking .gitignore configuration..." -ForegroundColor Yellow

if (-not (Test-Path ".gitignore")) {
    Write-Host "[ERROR] .gitignore file not found" -ForegroundColor Red
    $Issues++
} else {
    $gitignoreContent = Get-Content ".gitignore" -Raw
    
    $requiredPatterns = @(
        "terraform.tfvars",
        "*.tfvars",
        ".env",
        "*.tfstate",
        "*.tfplan"
    )
    
    foreach ($pattern in $requiredPatterns) {
        if ($gitignoreContent -like "*$pattern*") {
            Write-Host "[OK] .gitignore includes: $pattern" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] .gitignore missing pattern: $pattern" -ForegroundColor Red
            $Issues++
        }
    }
}

# Check 2: Look for sensitive files that shouldn't be committed
Write-Host "Checking for sensitive files..." -ForegroundColor Yellow

$sensitiveFiles = @(
    "terraform.tfvars",
    "*.tfvars",
    ".env",
    "*.tfstate*",
    "*.tfplan*",
    "backend-config.hcl",
    "secrets.json"
)

foreach ($pattern in $sensitiveFiles) {
    $found = Get-ChildItem -Path . -Recurse -Name $pattern -ErrorAction SilentlyContinue
    if ($found) {
        foreach ($file in $found) {
            # Check if file is tracked by git
            $gitStatus = git status --porcelain $file 2>$null
            if ($gitStatus -and $gitStatus -notlike "??*") {
                Write-Host "[ERROR] Sensitive file is tracked by git: $file" -ForegroundColor Red
                $Issues++
                
                if ($Fix) {
                    git rm --cached $file 2>$null
                    Write-Host "[FIXED] Removed from git tracking: $file" -ForegroundColor Green
                }
            } else {
                Write-Host "[OK] Sensitive file properly ignored: $file" -ForegroundColor Green
            }
        }
    }
}

# Check 3: Search for potential secrets in tracked files
Write-Host "Scanning tracked files for potential secrets..." -ForegroundColor Yellow

$secretPatterns = @(
    @{ Pattern = "/subscriptions/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"; Description = "Azure Subscription ID in resource path" },
    @{ Pattern = "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"; Description = "GUID/UUID (potential subscription ID)" },
    @{ Pattern = "client.*secret\s*=\s*['""`][^'""`\s]+['""`]"; Description = "Client Secret" },
    @{ Pattern = "password\s*=\s*['""`][^'""`\s]+['""`]"; Description = "Password" },
    @{ Pattern = "secret\s*=\s*['""`][^'""`\s]+['""`]"; Description = "Secret" }
)

$trackedFiles = git ls-files

foreach ($file in $trackedFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
        if ($content) {
            foreach ($secretPattern in $secretPatterns) {
                if ($content -match $secretPattern.Pattern) {
                    # Skip template, example files, and placeholder patterns
                    if ($file -like "*.example*" -or $file -like "*.template*" -or $file -like "*README*" -or $file -like "*.md") {
                        Write-Host "[OK] Found $($secretPattern.Description) in template/doc file: $file" -ForegroundColor Green
                    } elseif ($content -match "\{.*subscription.*\}" -or $content -match "\{.*secret.*\}" -or $content -match "\{.*password.*\}") {
                        Write-Host "[OK] Found placeholder pattern in: $file" -ForegroundColor Green
                    } else {
                        Write-Host "[ERROR] Potential $($secretPattern.Description) found in: $file" -ForegroundColor Red
                        $Issues++
                        
                        # Auto-fix subscription IDs if Fix flag is used
                        if ($Fix -and $secretPattern.Description -like "*subscription*") {
                            $originalContent = $content
                            $fixedContent = $originalContent
                            
                            # Handle different subscription ID patterns
                            if ($secretPattern.Pattern -like "*/subscriptions/*") {
                                # Replace Azure resource path subscription IDs
                                $fixedContent = $fixedContent -replace "/subscriptions/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", "/subscriptions/{subscription-id}"
                            } else {
                                # Replace standalone GUIDs with placeholder
                                $fixedContent = $fixedContent -replace $secretPattern.Pattern, '{subscription-id}'
                            }
                            
                            if ($fixedContent -ne $originalContent) {
                                Set-Content -Path $file -Value $fixedContent -Encoding UTF8
                                Write-Host "[FIXED] Replaced subscription ID with placeholder in: $file" -ForegroundColor Green
                                $Issues-- # Reduce issue count since we fixed it
                            }
                        }
                    }
                }
            }
        }
    }
}

# Check 4: Verify template files exist
Write-Host "Checking for required template files..." -ForegroundColor Yellow

# Dynamically find terraform.tfvars.example files
$tfvarsExamples = Get-ChildItem -Path . -Recurse -Name "terraform.tfvars.example" -ErrorAction SilentlyContinue
if ($tfvarsExamples) {
    $uniqueTfvars = $tfvarsExamples | Sort-Object | Get-Unique
    foreach ($template in $uniqueTfvars) {
        Write-Host "[OK] Template file exists: $template" -ForegroundColor Green
    }
    Write-Host "[INFO] Found $($uniqueTfvars.Count) terraform.tfvars.example file(s)" -ForegroundColor Cyan
} else {
    Write-Host "[WARN] No terraform.tfvars.example files found in repository" -ForegroundColor Yellow
    $Warnings++
}

# Dynamically find .env.example files
$envExamples = Get-ChildItem -Path . -Recurse -Name ".env.example" -ErrorAction SilentlyContinue
if ($envExamples) {
    $uniqueEnv = $envExamples | Sort-Object | Get-Unique
    foreach ($template in $uniqueEnv) {
        Write-Host "[OK] Template file exists: $template" -ForegroundColor Green
    }
    Write-Host "[INFO] Found $($uniqueEnv.Count) .env.example file(s)" -ForegroundColor Cyan
} else {
    Write-Host "[WARN] No .env.example files found in repository" -ForegroundColor Yellow
    $Warnings++
}

# Check 5: Verify git staging area is clean of sensitive files
Write-Host "Checking git staging area..." -ForegroundColor Yellow

$stagedFiles = git diff --cached --name-only 2>$null
foreach ($file in $stagedFiles) {
    if ($file -like "*.tfvars" -or $file -like ".env" -or $file -like "*.tfstate*") {
        Write-Host "[ERROR] Sensitive file staged for commit: $file" -ForegroundColor Red
        $Issues++
        
        if ($Fix) {
            git reset HEAD $file 2>$null
            Write-Host "[FIXED] Unstaged sensitive file: $file" -ForegroundColor Green
        }
    }
}

# Summary
Write-Host ""
Write-Host "Security Validation Summary" -ForegroundColor Cyan
Write-Host "==========================="

if ($Issues -eq 0 -and $Warnings -eq 0) {
    Write-Host "All security checks passed! Repository is safe for public sharing." -ForegroundColor Green
} elseif ($Issues -eq 0) {
    Write-Host "$Warnings warnings found, but no critical security issues." -ForegroundColor Yellow
    Write-Host "Repository should be safe for public sharing."
} else {
    Write-Host "$Issues critical security issues found!" -ForegroundColor Red
    Write-Host "DO NOT commit until these are resolved."
    Write-Host ""
    Write-Host "Quick fixes:"
    Write-Host "  - Run: .\security-check.ps1 -Fix"
    Write-Host "  - Review and remove sensitive data"
    Write-Host "  - Ensure .gitignore is properly configured"
}

if ($Warnings -gt 0) {
    Write-Host ""
    Write-Host "Warnings: $Warnings" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Best Practices Reminder:" -ForegroundColor Cyan
Write-Host "[OK] Use template files (*.example) for public sharing"
Write-Host "[OK] Keep real values in .gitignore'd files"
Write-Host "[OK] Run this check before every commit"  
Write-Host "[OK] Never commit subscription IDs or secrets"

exit $Issues