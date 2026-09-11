#Requires -Version 5.1
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "common.ps1")

$root = Get-ProjectRoot
$envPath = Join-Path $root ".env"

$cmd = Get-SupabaseCommand
$allArgs = @()
if ($cmd.Prefix.Count -gt 0) {
    $allArgs += $cmd.Prefix
}
$allArgs += @("status", "-o", "env")

Push-Location $root
try {
    $statusEnv = & $cmd.Exe @allArgs
    if ($LASTEXITCODE -ne 0) {
        throw "无法读取 supabase status，请先运行 scripts\windows\start.ps1。"
    }
}
finally {
    Pop-Location
}

$statusMap = @{}
foreach ($line in $statusEnv) {
    if ($line -match "^\s*([A-Za-z0-9_]+)=(.*)$") {
        $statusMap[$matches[1]] = $matches[2].Trim('"')
    }
}

$anon = $statusMap["ANON_KEY"]
if (-not $anon) { $anon = $statusMap["PUBLISHABLE_KEY"] }
$service = $statusMap["SERVICE_ROLE_KEY"]
if (-not $service) { $service = $statusMap["SECRET_KEY"] }
$apiUrl = $statusMap["API_URL"]
if (-not $apiUrl) { $apiUrl = "http://127.0.0.1:54321" }
$dbUrl = $statusMap["DB_URL"]
if (-not $dbUrl) { $dbUrl = "postgresql://postgres:postgres@127.0.0.1:54322/postgres" }

@"
SUPABASE_URL=$apiUrl
SUPABASE_ANON_KEY=$anon
SUPABASE_SERVICE_ROLE_KEY=$service
DATABASE_URL=$dbUrl
STUDIO_URL=http://127.0.0.1:54323
MAILPIT_URL=http://127.0.0.1:54324
"@ | Set-Content -Path $envPath -Encoding utf8

Write-Host "已写入 $envPath"
