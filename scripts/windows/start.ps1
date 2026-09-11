#Requires -Version 5.1
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "common.ps1")

Assert-DockerReady

$lanHost = Get-UnifiedLanHost
Write-Header "共用局域网地址"
Write-Host "桌面 Flutter 和手机 Flutter 都使用: $(Get-UnifiedApiUrl)"
if (Test-HostOnThisMachine -HostAddress $lanHost) {
    Write-Host "已检测到热点/ICS 地址 $lanHost。"
}
else {
    Write-Host "未检测到 $lanHost。请先打开 Windows「设置 → 网络和 Internet → 移动热点」，再启动 App。" -ForegroundColor Yellow
}

Write-Header "放行局域网访问（防火墙）"
Ensure-SupabaseLanFirewall

Write-Header "启动本地 Supabase（首次会拉取镜像，可能需要几分钟）"
Invoke-Supabase @("start")

Write-Header "写入 .env"
& (Join-Path $PSScriptRoot "write-env.ps1")

Write-Host ""
Write-Host "Flutter 共用 API: $(Get-UnifiedApiUrl)"
Write-Host "Studio（仅电脑浏览器）: http://127.0.0.1:54323"
Write-Host "DB（仅电脑）: postgresql://postgres:postgres@127.0.0.1:54322/postgres"
Write-Host "Mailpit: http://127.0.0.1:54324"
