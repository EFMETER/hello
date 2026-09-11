# 在本地 G 盘搭建 Supabase

这是一套可直接放到 **Windows `G:\supabase`** 的本地 Supabase 开发栈。它使用官方 [Supabase CLI](https://supabase.com/docs/guides/local-development) + Docker，启动后包含：

| 服务 | 本地地址 |
| --- | --- |
| Studio（控制台） | http://127.0.0.1:54323 |
| API / Auth / Storage / Realtime | http://127.0.0.1:54321 |
| Postgres | `postgresql://postgres:postgres@127.0.0.1:54322/postgres` |
| Mailpit（本地邮件） | http://127.0.0.1:54324 |

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

第一次 `start` 会下载官方镜像，可能需要几分钟。成功后浏览器打开 http://127.0.0.1:54323 ，在 Table Editor 里应能看到示例表 `notes` 和一条种子数据。

启动脚本会把当前密钥写入项目根目录的 `.env`（该文件已加入 `.gitignore`）。应用里请使用这份本地地址和密钥，不要提交真实密钥。

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
│   ├── config.toml           # 官方 CLI 本地配置
│   ├── migrations\           # 数据库迁移
│   └── seed.sql              # 本地种子数据
├── package.json              # 锁定 supabase CLI 2.117.0
└── .env.example
```

改 `supabase/config.toml` 或新增迁移后，执行 `.\scripts\windows\reset.ps1`（开发库）或重新 `start`，让本地库跟上。

## 6. 在应用里连接

`.env` 示例：

```
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=<supabase status 输出的 Publishable / anon key>
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:54322/postgres
```

密钥以 `.\scripts\windows\status.ps1` 的实时输出为准。新版 CLI 会打印 `sb_publishable_...` / `sb_secret_...`。

## 7. 常见问题

- **Docker 引擎未就绪**：先打开 Docker Desktop，等它完全启动。
- **端口被占用**：默认 API `54321`、Postgres `54322`、Studio `54323`。改 `supabase/config.toml` 里对应 `port` 后重新 start。
- **内存不足**：关掉其它占内存的程序，或在 `supabase start` 时用 `-x` 排除不需要的服务（见[官方 CLI](https://supabase.com/docs/reference/cli/supabase-start)）。
- **Windows 上看不到本地日志**：Analytics 在 Windows 上需要按官方说明暴露 Docker daemon socket（`tcp://localhost:2375`）。不影响 Studio、API、数据库的日常使用。
- **这不是生产自托管**：本仓库走的是官方本地开发栈。若要在服务器上自托管，请按 [Self-Hosting with Docker](https://supabase.com/docs/guides/self-hosting/docker) 单独部署，并务必替换默认密钥。
