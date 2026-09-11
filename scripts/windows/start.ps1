#Requires -Version 5.1
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "common.ps1")

Assert-DockerReady
Write-Header "启动本地 Supabase（首次会拉取镜像，可能需要几分钟）"
Invoke-Supabase @("start")

Write-Header "写入 .env"
& (Join-Path $PSScriptRoot "write-env.ps1")

Write-Host ""
Write-Host "Studio:  http://127.0.0.1:54323"
Write-Host "API:     http://127.0.0.1:54321"
Write-Host "DB:      postgresql://postgres:postgres@127.0.0.1:54322/postgres"
Write-Host "Mailpit: http://127.0.0.1:54324"
