#Requires -Version 5.1
$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "common.ps1")

Assert-DockerReady
Write-Header "重置本地数据库（会重新执行 migrations 和 seed.sql）"
Invoke-Supabase @("db", "reset")
