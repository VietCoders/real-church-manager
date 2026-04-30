# Backend — PocketBase Server

> Server tự host cho Real Church Manager. 1 file binary + 1 file SQLite. Sao lưu = copy file.

## Status

🚧 **Phase 3 chưa bắt đầu**. Folder này hiện chỉ có README placeholder. Sẽ populate khi chạy Phase 3:

- `pb_migrations/` — 16 file JSON migration
- `pb_hooks/` — JS hooks cho validation, derived fields, audit log
- `start.sh` / `start.bat` — POSIX/Windows launcher
- PocketBase binary (download tự động qua script)

## Quick start (sau Phase 3)

```bash
cd backend
./pocketbase serve
# Admin UI: http://127.0.0.1:8090/_/
# REST API: http://127.0.0.1:8090/api/
```

## Schema

16 collections — xem `docs/data-model.md` và `packages/schema/collections.json`.

## Hooks (Phase 3)

- `validate_member.js` — kiểm `birth_date < death_date`, format saint_name VN
- `validate_marriage.js` — `groom_id != bride_id`, dates valid
- `derived_member_dates.js` — auto-update `members.baptism_date` khi tạo Baptism
- `auto_book_number.js` — sinh `book_number` format `<TYPE>-<YYYY>-<seq>`
- `audit_log.js` — ghi mọi CREATE/UPDATE/DELETE vào collection `audit_logs`

## Backup

```bash
# Manual backup
cp -r pb_data backups/pb_data-$(date +%F)

# Auto backup hằng đêm (cron)
0 2 * * * cp -r ~/real-cm-server/pb_data ~/backups/pb_data-$(date +%F) && find ~/backups -mtime +30 -delete
```

## Restore

```bash
# Stop PocketBase
# Replace pb_data
rm -rf pb_data
cp -r backups/pb_data-2026-04-30 pb_data
# Start lại
```

## Production

- Mặc định bind `127.0.0.1:8090`. Để expose:
  - `--http=0.0.0.0:8090` (mở mọi IP, dùng với firewall)
  - Hoặc Cloudflare Tunnel: `cloudflared tunnel --url http://localhost:8090` (free, không cần mở port)
  - Hoặc Tailscale: cài app trên PC + mobile, truy cập qua IP riêng `100.x.x.x`
- HTTPS: PocketBase tự lấy Let's Encrypt nếu domain trỏ thẳng (`--https=0.0.0.0:443 --http=0.0.0.0:80 --autocert=domain.example.com`)

## Tham khảo

- PocketBase docs: https://pocketbase.io/docs/
- JSVM API: https://pocketbase.io/jsvm/
- Migrations: https://pocketbase.io/docs/go-migrations/
