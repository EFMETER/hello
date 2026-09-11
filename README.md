# 在本地 G 盘搭建 Supabase

这是一套可直接放到 **Windows `G:\supabase`** 的本地 Supabase 开发栈。它使用官方 [Supabase CLI](https://supabase.com/docs/guides/local-development) + Docker，启动后包含：

| 服务 | 谁用 | 地址 |
| --- | --- | --- |
| API / Auth / Storage / Realtime | **Flutter 桌面 + 手机（同一个）** | `http://192.168.137.1:54321` |
| Studio（控制台） | 仅电脑浏览器 | http://127.0.0.1:54323 |
| Postgres | 仅电脑（调试） | `postgresql://postgres:postgres@127.0.0.1:54322/postgres` |
| Mailpit（本地邮件） | 仅电脑 | http://127.0.0.1:54324 |

Flutter 两端不要用 `127.0.0.1`。Windows 开「移动热点」后，电脑网关一般是 `192.168.137.1`，桌面 App 也连这个地址，这样和手机完全一致。详见 [examples/flutter](examples/flutter/README.md)。

官方建议本机至少预留 **7 GB 内存**，才能较稳地拉起全部服务。

## 1. 本机准备

1. 确认有 **G:** 盘，并且剩余空间足够（镜像 + 数据库建议预留 20 GB 以上）。
2. 安装并启动 [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/)。托盘图标变为 Running 后再继续。
3. 安装 [Node.js 20+](https://nodejs.org/)（推荐，脚本会用项目内的 CLI），或用 [Scoop](https://scoop.sh) 安装全局 `supabase`。

### 可选：让 Docker 镜像和数据卷也占用 G 盘

仓库放在 `G:\supabase` 只会把**项目文件**放到 G:。Docker 镜像和 Postgres 数据默认仍在 C: 的 WSL2 虚拟磁盘里。

若 C: 空间紧张，打开 Docker Desktop → **Settings → Resources → Advanced → Disk image location**，改到例如 `G:\Docker`，然后 Apply & Restart。改完后镜像和本地数据库都会落在 G:。

## 2. 把本仓库放到 G 盘

在 PowerShell 中：

```powershell
git clone https://github.com/EFMETER/hello.git G:\supabase
cd G:\supabase
```

如果已经把仓库克隆到别的路径，也可以直接在该目录运行脚本；只是项目文件不会在 G:。

若脚本被策略拦截：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## 3. 安装并启动

在 `G:\supabase` 执行一次安装，再启动：

```powershell
.\scripts\windows\setup.ps1
.\scripts\windows\start.ps1
```

也可以一条命令完成（先 setup 再 start）：

```powershell
.\start.ps1
```

第一次 `start` 会下载官方镜像，可能需要几分钟。请先打开 Windows「移动热点」，再启动脚本，这样 `.env` 里的 `SUPABASE_URL` 会写成桌面和手机都能用的 `http://192.168.137.1:54321`。

电脑浏览器打开 http://127.0.0.1:54323 ，在 Table Editor 里应能看到示例表 `notes`。

启动脚本会把密钥写入项目根目录的 `.env`（已加入 `.gitignore`）。不要提交真实密钥。

## 4. 日常命令

| 操作 | 命令 |
| --- | --- |
| 启动（保留数据） | `.\scripts\windows\start.ps1` |
| 查看地址和密钥 | `.\scripts\windows\status.ps1` |
| 停止（默认保留数据） | `.\scripts\windows\stop.ps1` |
| 清空并重跑迁移 / 种子 | `.\scripts\windows\reset.ps1` |
| 停止并删除本地数据卷 | `.\scripts\windows\stop.ps1 -NoBackup` |

已安装 Node 时也可以在项目根目录使用：

```powershell
npm start          # supabase start
npm run status
npm run stop
npm run reset
```

## 5. 项目结构

```
G:\supabase
├── start.ps1                 # 一键 setup + start
├── scripts\windows\          # Windows 管理脚本
├── supabase\
│   ├── config.toml           # 官方 CLI 本地配置（Auth 面向 192.168.137.1）
│   ├── migrations\           # 数据库迁移
│   └── seed.sql              # 本地种子数据
├── examples\flutter\         # 桌面/手机共用 URL 的 Dart 片段
├── package.json              # 锁定 supabase CLI 2.117.0
└── .env.example
```

改 `supabase/config.toml` 或新增迁移后，执行 `.\scripts\windows\reset.ps1`（开发库）或重新 `start`，让本地库跟上。

## 6. Flutter 用同一个地址连接

桌面和手机共用 `.env` 里的这一行：

```
SUPABASE_URL=http://192.168.137.1:54321
SUPABASE_ANON_KEY=<scripts\windows\status.ps1 输出的 key>
```

```bash
flutter run -d windows --dart-define=SUPABASE_URL=http://192.168.137.1:54321 --dart-define=SUPABASE_ANON_KEY=...
flutter run -d <手机>  --dart-define=SUPABASE_URL=http://192.168.137.1:54321 --dart-define=SUPABASE_ANON_KEY=...
```

两个命令的 `SUPABASE_URL` 必须相同。手机需连电脑热点，并允许明文 HTTP（见 `examples/flutter`）。

若热点网关不是 `192.168.137.1`：

```powershell
$env:SUPABASE_LAN_HOST="实际IP"
.\scripts\windows\write-env.ps1
```

然后两端一起改成新的 `http://实际IP:54321`。

密钥以 `.\scripts\windows\status.ps1` 为准。新版 CLI 会打印 `sb_publishable_...` / `sb_secret_...`。

## 7. 常见问题

- **Docker 引擎未就绪**：先打开 Docker Desktop，等它完全启动。
- **端口被占用**：默认 API `54321`、Postgres `54322`、Studio `54323`。改 `supabase/config.toml` 里对应 `port` 后重新 start。
- **内存不足**：关掉其它占内存的程序，或在 `supabase start` 时用 `-x` 排除不需要的服务（见[官方 CLI](https://supabase.com/docs/reference/cli/supabase-start)）。
- **Windows 上看不到本地日志**：Analytics 在 Windows 上需要按官方说明暴露 Docker daemon socket（`tcp://localhost:2375`）。不影响 Studio、API、数据库的日常使用。
- **手机连不上、桌面却正常**：两端必须都用 `http://192.168.137.1:54321`，先打开移动热点；以管理员运行一次 `start.ps1` 以便写入防火墙规则；手机浏览器先测该地址。
- **这不是生产自托管**：本仓库走的是官方本地开发栈。若要在服务器上自托管，请按 [Self-Hosting with Docker](https://supabase.com/docs/guides/self-hosting/docker) 单独部署，并务必替换默认密钥。上线后桌面和手机再一起改成同一个 `https://xxxx.supabase.co`。
