#Requires -Version 5.1
param(
    [switch]$NoBackup
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "common.ps1")

Assert-DockerReady
Write-Header "停止本地 Supabase（默认保留数据库数据）"

if ($NoBackup) {
    Invoke-Supabase @("stop", "--no-backup")
}
else {
    Invoke-Supabase @("stop")
}
