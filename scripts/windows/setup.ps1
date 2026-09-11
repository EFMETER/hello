#Requires -Version 5.1
param(
    [string]$InstallRoot = "G:\supabase"
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "common.ps1")

$root = Get-ProjectRoot

Write-Header "检查运行环境"
Write-Host "项目目录: $root"

if ($root -notlike "G:\*") {
    Write-Host "当前仓库不在 G: 盘。推荐克隆到 $InstallRoot 后再运行，这样项目文件会落在 G:。" -ForegroundColor Yellow
}

Assert-DockerReady
Write-Host "Docker 已就绪。"

$hasNode = [bool](Get-Command node -ErrorAction SilentlyContinue)
$hasNpm = [bool](Get-Command npm -ErrorAction SilentlyContinue)
$hasScoop = [bool](Get-Command scoop -ErrorAction SilentlyContinue)
$hasSupabase = [bool](Get-Command supabase -ErrorAction SilentlyContinue)

if ($hasNode) {
    $nodeVersion = (node -v).TrimStart("v")
    $major = [int]($nodeVersion.Split(".")[0])
    if ($major -lt 20) {
        throw "检测到 Node.js $nodeVersion，官方 CLI 通过 npm/npx 运行时需要 Node.js 20+。"
    }
    Write-Host "Node.js $nodeVersion 可用。"
}

if (-not $hasSupabase -and -not ($hasNode -and $hasNpm) -and -not $hasScoop) {
    throw @"
缺少 Supabase CLI 安装方式。任选其一：
1. 安装 Node.js 20+：https://nodejs.org/
2. 安装 Scoop 后执行：
   scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
   scoop install supabase
"@
}

if ($hasNode -and $hasNpm) {
    Write-Header "安装项目内 Supabase CLI 2.117.0"
    Push-Location $root
    try {
        npm install
        if ($LASTEXITCODE -ne 0) {
            throw "npm install 失败。"
        }
    }
    finally {
        Pop-Location
    }
}
elseif (-not $hasSupabase -and $hasScoop) {
    Write-Header "通过 Scoop 安装全局 Supabase CLI"
    $buckets = scoop bucket list
    if ($buckets -notmatch "supabase") {
        scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
    }
    scoop install supabase
}

if (-not (Test-Path (Join-Path $root "supabase\config.toml"))) {
    Write-Header "初始化 supabase/"
    Invoke-Supabase @("init")
}

Write-Header "安装完成"
Write-Host "下一步：在项目根目录运行  .\scripts\windows\start.ps1"
Write-Host "Studio 启动后打开 http://127.0.0.1:54323"
Write-Host ""
Write-Host "若希望 Docker 镜像和数据卷也占用 G: 而不是 C:，见 README 中「把 Docker 磁盘放到 G 盘」。"
