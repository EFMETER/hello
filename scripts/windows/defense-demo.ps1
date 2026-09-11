#Requires -Version 5.1
param(
    [switch]$SkipHotspotCheck
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "common.ps1")

Write-Header "学位论文答辩演示预检"

$lanHost = Get-UnifiedLanHost
$hotspotUp = Test-HostOnThisMachine -HostAddress $lanHost
if (-not $hotspotUp) {
    $message = @"
未检测到热点网关 $lanHost。
请先打开：设置 → 网络和 Internet → 移动热点，然后再运行本脚本。
桌面 Flutter 和手机必须都使用 $(Get-UnifiedApiUrl)，热点关闭则该地址不存在。
"@
    if ($SkipHotspotCheck) {
        Write-Host $message -ForegroundColor Yellow
    }
    else {
        throw $message
    }
}

Write-Host "请确认：电源已插上、睡眠已关闭、VPN 已关闭、Docker Desktop 正在运行。"
Write-Host "手机稍后只连本机热点，不要连校园网。"

& (Join-Path $PSScriptRoot "start.ps1")

Write-Header "检查 API 是否在热点地址上监听"
if (Test-UnifiedApiPort) {
    Write-Host "TCP $lanHost`:$script:ApiPort 可连通。"
}
else {
    Write-Host "还不能连上 $lanHost`:$script:ApiPort。核对热点、防火墙，并用手机浏览器打开 $(Get-UnifiedApiUrl)。" -ForegroundColor Yellow
}

Write-DefenseCard
Write-Host "现场兜底：准备一段已录好的桌面+手机操作视频。"
