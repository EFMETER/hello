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

# Windows 移动热点 / ICS 默认网关。桌面 App 和手机 App 都连这个地址，而不是 127.0.0.1。
$script:DefaultUnifiedHost = "192.168.137.1"
$script:ApiPort = 54321

function Get-UnifiedLanHost {
    $fromEnv = [Environment]::GetEnvironmentVariable("SUPABASE_LAN_HOST")
    if (-not [string]::IsNullOrWhiteSpace($fromEnv)) {
        return $fromEnv.Trim()
    }

    $addrs = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object {
                $_.IPAddress -and
                $_.IPAddress -notlike "127.*" -and
                $_.IPAddress -notlike "169.254.*"
            })

    $hotspot = $addrs |
        Where-Object { $_.IPAddress -eq $script:DefaultUnifiedHost -or $_.IPAddress -like "192.168.137.*" } |
        Select-Object -First 1
    if ($hotspot) {
        return $hotspot.IPAddress
    }

    return $script:DefaultUnifiedHost
}

function Test-HostOnThisMachine {
    param([Parameter(Mandatory = $true)][string]$HostAddress)

    $match = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -eq $HostAddress }
    return [bool]$match
}

function Get-UnifiedApiUrl {
    return "http://$(Get-UnifiedLanHost):$script:ApiPort"
}

function Test-UnifiedApiPort {
    $hostAddress = Get-UnifiedLanHost
    try {
        $result = Test-NetConnection -ComputerName $hostAddress -Port $script:ApiPort -WarningAction SilentlyContinue
        return [bool]$result.TcpTestSucceeded
    }
    catch {
        return $false
    }
}

function Write-DefenseCard {
    $apiUrl = Get-UnifiedApiUrl
    $lanHost = Get-UnifiedLanHost
    $hotspotUp = Test-HostOnThisMachine -HostAddress $lanHost

    Write-Host ""
    Write-Host "========== 答辩演示 ==========" -ForegroundColor Green
    Write-Host "共用 URL（桌面 + 手机）: $apiUrl"
    Write-Host "Studio（仅本机浏览器）:  http://127.0.0.1:54323"
    Write-Host "手机: 只连本机热点，不要连校园网"
    Write-Host "演示: 桌面往 notes 写入一条，手机刷新应立刻看到"
    if ($hotspotUp) {
        Write-Host "热点网关: $lanHost （已在本机网卡上）"
    }
    else {
        Write-Host "热点网关: $lanHost （尚未检测到，请打开移动热点）" -ForegroundColor Yellow
    }
    Write-Host "密钥: 项目根目录 .env 里的 SUPABASE_ANON_KEY"
    Write-Host "================================"
}

function Ensure-SupabaseLanFirewall {
    $ruleName = "Supabase LAN API for Flutter hotspot"
    $ports = @($script:ApiPort)

    try {
        $existing = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
        if (-not $existing) {
            New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Allow -Protocol TCP -LocalPort $ports -Profile Any | Out-Null
            Write-Host "已添加防火墙规则：$ruleName （TCP $ports）"
        }
    }
    catch {
        Write-Host "未能自动添加防火墙规则（通常需要以管理员运行 PowerShell）。请手动放行 TCP $ports，或用管理员执行：" -ForegroundColor Yellow
        Write-Host "  New-NetFirewallRule -DisplayName '$ruleName' -Direction Inbound -Action Allow -Protocol TCP -LocalPort $($ports -join ',') -Profile Any"
    }
}
