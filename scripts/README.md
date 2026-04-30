# Scripts

> Build/release/seed scripts. POSIX-safe (mac + Linux). Windows có `.bat` riêng.

## Status

🚧 Phase tiếp sẽ thêm:

| Script | Phase | Vai trò |
|---|---|---|
| `seed.sh` | 3 | Tạo admin user + parish_settings demo + 1 district mẫu |
| `download-pocketbase.sh` | 3 | Tải PB binary cho OS hiện tại vào `backend/` |
| `bundle-backend.sh` | 7 | Đóng gói PB binary + migrations + hooks → zip release |
| `build-flutter-all.sh` | 7 | Build Flutter cho cả 4 platform local (test trước CI) |
| `schema-to-migrations.js` | 3 | Convert `packages/schema/collections.json` → 16 migration files |
| `schema-to-dart-entities.dart` | 2 | Convert schema → Dart Freezed entities |

## Convention

- Shebang `#!/usr/bin/env bash`
- POSIX-safe — test mac + AlmaLinux + Ubuntu (xem `~/.claude/rules/cross-os-rules.md`)
- Source `~/.claude/tools/lib/cross-os.sh` nếu cần `sed -i`/`stat`/`md5` portable
- Không hardcode `/Users/realdev/` — dùng `$HOME` hoặc `~`

## Chạy

```bash
chmod +x scripts/*.sh
./scripts/seed.sh
```
