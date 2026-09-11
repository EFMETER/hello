# 学位论文答辩演示

一台笔记本电脑跑本地 Supabase，手机连这台电脑的**移动热点**。  
Windows 桌面 Flutter 和手机 Flutter **使用同一个 URL**：

```text
http://192.168.137.1:54321
```

不要用校园网，不要用第二台服务器，不要用 `127.0.0.1`（手机上的 localhost 是手机自己）。

```text
笔记本电脑（插电、关休眠、关 VPN、开热点）
 ├── Docker 本地 Supabase
 ├── Windows Flutter  →  http://192.168.137.1:54321
 └── 手机（只连本机热点）→  同一个地址
```

## 答辩前一天（必须在家做完）

1. Docker Desktop 已安装，本仓库在 `G:\supabase`。
2. 管理员 PowerShell：

   ```powershell
   cd G:\supabase
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\scripts\windows\setup.ps1
   ```

3. 打开 **设置 → 网络和 Internet → 移动热点**，再执行：

   ```powershell
   .\demo.ps1
   ```

   第一次会下载镜像，需要联网。完成后不要再删 Docker 数据。

4. 浏览器打开 http://127.0.0.1:54323 ，确认表 `notes` 里有答辩演示种子数据。若没有：`.\scripts\windows\reset.ps1`。
5. Flutter 两端都写死 `SUPABASE_URL=http://192.168.137.1:54321` 和 `.env` 里的 `SUPABASE_ANON_KEY`（见 [examples/flutter](examples/flutter/README.md)）。
6. 手机允许明文 HTTP（Android `usesCleartextTraffic`，iOS `NSAllowsLocalNetworking`）。
7. 完整走一遍：桌面新增一条 `notes`，手机刷新能看到。
8. **录一段同样操作的视频** 拷到优盘，现场热点被禁或连不上时播放。

## 进答辩教室

1. 插电，关闭睡眠和 VPN，打开 Docker Desktop，打开移动热点。
2. `.\demo.ps1`（热点未开会直接失败，避免带着错误地址上场）。
3. 手机只连本机热点，浏览器先访问 `http://192.168.137.1:54321`。
4. 再开桌面 App 和手机 App。
5. 演示建议：桌面写入 → 口头说明同一数据库 → 手机打开同一列表。

## 现场不要做的事

- 不要让手机连学校 Wi‑Fi（常见「终端隔离」，会访问不到你的电脑）
- 不要依赖云端 Supabase 或教室外网
- 不要现场改 URL、升级 Docker、重置数据库（除非种子数据乱了且你很熟 `reset.ps1`）

## 命令

| 时机 | 命令 |
| --- | --- |
| 答辩当天启动 | `.\demo.ps1` |
| 热点暂时还没开、只先起服务 | `.\scripts\windows\defense-demo.ps1 -SkipHotspotCheck` |
| 只启动、不强制预检 | `.\scripts\windows\start.ps1` |
| 恢复演示数据 | `.\scripts\windows\reset.ps1` |
