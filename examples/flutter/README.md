# Flutter：桌面和手机用同一个本地地址

Windows 开「移动热点」后，电脑网关一般是 `192.168.137.1`。  
**Windows 桌面 App 和手机 App 都写这一个 URL：**

```text
http://192.168.137.1:54321
```

不要用 `http://127.0.0.1:54321`。手机上的 localhost 是手机自己，桌面若继续用 localhost，两端地址就又不一致了。

## 启动顺序

1. 电脑打开 **设置 → 网络和 Internet → 移动热点**。
2. 在 `G:\supabase` 运行 `.\scripts\windows\start.ps1`（会写入 `.env` 里的 `SUPABASE_URL`）。
3. 手机连上这台电脑的热点。
4. 手机浏览器先打开 `http://192.168.137.1:54321`，确认能通。
5. 用同一组 `--dart-define` 跑 Windows 和手机：

```bash
flutter run -d windows --dart-define=SUPABASE_URL=http://192.168.137.1:54321 --dart-define=SUPABASE_ANON_KEY=来自.env
flutter run -d <手机> --dart-define=SUPABASE_URL=http://192.168.137.1:54321 --dart-define=SUPABASE_ANON_KEY=来自.env
```

`SUPABASE_ANON_KEY` 从项目根目录 `.env` 复制。两个命令里的 `SUPABASE_URL` 必须相同。

把 `lib/local_supabase.dart` 拷进你的 Flutter 工程，初始化见 `lib/main.dart.example`。

## 手机允许 HTTP

本地栈是明文 HTTP。

Android `android/app/src/main/AndroidManifest.xml` 的 `<application>`：

```xml
android:usesCleartextTraffic="true"
```

iOS `ios/Runner/Info.plist`：

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsLocalNetworking</key>
  <true/>
</dict>
```

## 热点 IP 不是 192.168.137.1 时

少数环境网关会变。看 `.env` 里的 `SUPABASE_LAN_HOST`，或：

```powershell
$env:SUPABASE_LAN_HOST="你的热点IP"
.\scripts\windows\write-env.ps1
```

然后桌面和手机一起改成 `http://你的热点IP:54321`，仍然保持同一个地址。
