# Flutter App — Real Church Manager

> 1 codebase Flutter build cho Windows + macOS + Android + Linux. iOS sẽ thêm trong v1.1.

## Status

🚧 **Phase 2 chưa bắt đầu**. Folder này sẽ được populate khi chạy Phase 2:

```bash
cd apps/flutter_app
flutter create . \
  --project-name=real_church_manager \
  --org=vn.realdev.realchurchmanager \
  --platforms=windows,macos,linux,android \
  --description="Phần mềm quản lý giáo xứ Công giáo VN, đa nền tảng, đồng bộ thời gian thực"
```

Sau đó:
1. Sửa `pubspec.yaml` thêm dependencies (Riverpod, go_router, pocketbase, hive, intl, pdf, ...)
2. Setup `lib/` structure theo `maps/tree.md`
3. Implement design tokens, theme, i18n, PocketBase client

## Targets

| Platform | Status v1 | Notes |
|---|---|---|
| Windows | ✅ | `flutter build windows` → `.exe` |
| macOS | ✅ | `flutter build macos` → `.app` → `.dmg` |
| Android | ✅ | `flutter build apk` → `.apk` |
| Linux | ✅ | `flutter build linux` → binary |
| iOS | ❌ v1 | v1.1+ (cần Apple Developer $99/năm) |
| Web | ❌ scope | Có thể build nhưng không scope v1 |

## Cấu trúc `lib/` (Phase 2 sẽ tạo)

Xem `maps/tree.md` section "Flutter `apps/flutter_app/lib/`".

## Dev

```bash
# Chạy desktop
flutter run -d windows
flutter run -d macos
flutter run -d linux

# Chạy Android (cần emulator hoặc device)
flutter run -d <device-id>

# Hot reload: r
# Hot restart: R
# Quit: q
```

## Build release

```bash
# Windows
flutter build windows --release
# → build/windows/x64/runner/Release/real_church_manager.exe

# macOS
flutter build macos --release
# → build/macos/Build/Products/Release/real_church_manager.app

# Android APK
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk

# Android AAB (cho Play Store, sau)
flutter build appbundle --release

# Linux
flutter build linux --release
# → build/linux/x64/release/bundle/real_church_manager
```

## Cấu hình PocketBase backend URL

Sau khi build, app sẽ hỏi backend URL khi mở lần đầu:
- Default `http://127.0.0.1:8090` (cho desktop chung máy với backend)
- Hoặc `http://192.168.1.100:8090` (LAN IP của PC văn phòng)
- Hoặc `https://parish.trycloudflare.com` (Cloudflare Tunnel)

Lưu trong Hive box `real-cm:settings`.
