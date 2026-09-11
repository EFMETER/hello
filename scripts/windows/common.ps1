$ErrorActionPreference = "Stop"

function Get-ProjectRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
}

function Get-SupabaseCommand {
    $root = Get-ProjectRoot
    $localCli = Join-Path $root "node_modules\.bin\supabase.cmd"
    if (Test-Path $localCli) {
        return @{ Exe = $localCli; Prefix = @() }
    }
    if (Get-Command supabase -ErrorAction SilentlyContinue) {
        return @{ Exe = "supabase"; Prefix = @() }
    }
    if (Get-Command npx -ErrorAction SilentlyContinue) {
        return @{ Exe = "npx"; Prefix = @("--yes", "supabase@2.117.0") }
    }
    throw "未找到 Supabase CLI。请先运行 scripts\windows\setup.ps1，或安装 Node.js 20+ / Scoop supabase。"
}

function Invoke-Supabase {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Args
    )

    $root = Get-ProjectRoot
    $cmd = Get-SupabaseCommand
    $allArgs = @()
    if ($cmd.Prefix.Count -gt 0) {
        $allArgs += $cmd.Prefix
    }
    $allArgs += $Args

    Push-Location $root
    try {
        & $cmd.Exe @allArgs
        if ($LASTEXITCODE -ne 0) {
            throw "supabase $($Args -join ' ') 失败，退出码 $LASTEXITCODE"
        }
    }
    finally {
        Pop-Location
    }
}

function Assert-DockerReady {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw @"
未检测到 Docker。请先安装并启动 Docker Desktop：
https://docs.docker.com/desktop/setup/install/windows-install/
"@
    }

    docker info 1>$null 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker 已安装但引擎未就绪。请打开 Docker Desktop，等到托盘图标变为 Running 后再重试。"
    }
}

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}
