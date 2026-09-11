#Requires -Version 5.1
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "common.ps1")

Assert-DockerReady
Invoke-Supabase @("status")

Write-Host ""
Write-Host "Flutter 共用地址: $(Get-UnifiedApiUrl)"
if (-not (Test-HostOnThisMachine -HostAddress (Get-UnifiedLanHost))) {
    Write-Host "未检测到热点网关 $(Get-UnifiedLanHost)。打开移动热点后，桌面和手机才能用同一个 URL。" -ForegroundColor Yellow
}
