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
$dbUrl = $statusMap["DB_URL"]
if (-not $dbUrl) { $dbUrl = "postgresql://postgres:postgres@127.0.0.1:54322/postgres" }

$lanHost = Get-UnifiedLanHost
$apiUrl = Get-UnifiedApiUrl
$hotspotUp = Test-HostOnThisMachine -HostAddress $lanHost

@"
# Desktop and phone Flutter apps both use SUPABASE_URL (PC hotspot gateway).
SUPABASE_LAN_HOST=$lanHost
SUPABASE_URL=$apiUrl
SUPABASE_ANON_KEY=$anon
SUPABASE_SERVICE_ROLE_KEY=$service
DATABASE_URL=$dbUrl
STUDIO_URL=http://127.0.0.1:54323
MAILPIT_URL=http://127.0.0.1:54324
"@ | Set-Content -Path $envPath -Encoding utf8

Write-Host "已写入 $envPath"
Write-Host "Flutter 共用地址: $apiUrl"
if (-not $hotspotUp) {
    Write-Host "还没有在本机看到 $lanHost。请先打开 Windows「移动热点」，再让桌面和手机都连这个地址。" -ForegroundColor Yellow
}
