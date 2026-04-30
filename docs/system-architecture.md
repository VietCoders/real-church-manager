# System Architecture — Real Church Manager

## Tổng quan

Một giáo xứ = một deployment độc lập. Backend chạy trên 1 PC văn phòng giáo xứ, các thiết bị khác (mobile cha phó, PC giáo xứ con, tablet thư ký) kết nối realtime qua mạng LAN hoặc tunnel.

```
                    ┌─────────────────────────────────┐
                    │  PC văn phòng giáo xứ (1 máy)   │
                    │                                 │
                    │  ┌──────────────────────────┐   │
                    │  │ pocketbase (Go binary)   │   │
                    │  │ port 8090                │   │
                    │  │ + pb_data/data.db        │   │
                    │  │   (SQLite single file)   │   │
                    │  │ + pb_data/storage/       │   │
                    │  │   (file uploads)         │   │
                    │  └──────────────────────────┘   │
                    │            │ ▲                  │
                    │            │ │ HTTP + SSE       │
                    │  ┌─────────▼─┴──────────────┐   │
                    │  │ Flutter Desktop          │   │
                    │  │ (Win/Mac native)         │   │
                    │  │ - Cha xứ + thư ký        │   │
                    │  └──────────────────────────┘   │
                    └────────────┬────────────────────┘
                                 │ HTTPS + SSE
                                 │ (LAN / Cloudflare Tunnel / Tailscale)
                  ┌──────────────┼──────────────────────┐
                  │              │                      │
                  ▼              ▼                      ▼
        ┌──────────────┐ ┌──────────────┐ ┌──────────────────┐
        │ Flutter      │ │ Flutter      │ │ Flutter          │
        │ Android      │ │ macOS        │ │ Windows          │
        │ (cha phó di  │ │ (giáo xứ con │ │ (kế toán giáo xứ │
        │  chuyển)     │ │  / nhà xứ)   │ │  / phòng riêng)  │
        └──────────────┘ └──────────────┘ └──────────────────┘
```

## Component

### Backend: PocketBase

- **Repo**: github.com/pocketbase/pocketbase (Go, MIT)
- **Footprint**: 1 binary ~30MB chạy trên Linux/macOS/Windows.
- **Database**: SQLite embed (`pb_data/data.db`). Backup = copy 1 file.
- **Realtime**: Server-Sent Events native, mỗi client subscribe collection.
- **Auth**: Built-in users + roles. Email/password + OAuth (Google/Apple) optional.
- **Storage**: file uploads vào `pb_data/storage/` (ảnh giáo dân, logo giáo xứ).
- **Migrations**: file-based JSON trong `backend/pb_migrations/`.
- **Hooks**: JS (JSVM Goja) trong `backend/pb_hooks/` cho validation/derived field/automation.

### Frontend: Flutter

- **Stack**: Flutter 3.x stable, Dart 3.x.
- **State**: [Riverpod](https://riverpod.dev/) 2.x.
- **Navigation**: [go_router](https://pub.dev/packages/go_router).
- **PocketBase SDK**: [pocketbase](https://pub.dev/packages/pocketbase) Dart official.
- **Offline cache**: [Hive](https://pub.dev/packages/hive) + [hive_flutter](https://pub.dev/packages/hive_flutter).
- **i18n**: [intl](https://pub.dev/packages/intl) + Flutter `gen_l10n` + arb files.
- **PDF**: [pdf](https://pub.dev/packages/pdf) + [printing](https://pub.dev/packages/printing) cho in chứng chỉ.
- **File picker**: [file_picker](https://pub.dev/packages/file_picker) cho import.

### Sync model

**Realtime path**:
```
User A sửa Member → Flutter A POST /api/collections/members/records/{id}
                  → PocketBase update SQLite
                  → PocketBase emit SSE event "members" UPDATE record
                  → Flutter B+C+... nhận event qua subscription
                  → Riverpod provider invalidate cache
                  → UI rebuild
```

**Offline path**:
```
User mất mạng → Flutter ghi vào Hive box "real-cm:offline:queue"
              → Khi online lại, queue runner POST từng request
              → Conflict resolution: last-write-wins theo PB updated timestamp
                (v1 simple; v1.1+ có thể thêm CRDT cho field-level merge)
```

**Sync chỉ partial**: mobile chỉ sync data của giáo họ mình quản lý nếu user là trưởng giáo họ (RLS rule), giảm dung lượng cache.

## Data model overview

15+ collections, xem [`data-model.md`](data-model.md) cho chi tiết. Source-of-truth: `packages/schema/collections.json`.

Tóm tắt:

```
users (auth)
parish_settings (1 record cho cấu hình giáo xứ)
districts (giáo họ)
members (giáo dân) — link district
families (gia đình) — link district
family_members (junction: family ↔ member + role)
groups (đoàn thể)
group_members (junction: group ↔ member + role)
sacrament_baptism (sổ rửa tội) — link member
sacrament_confirmation (sổ thêm sức) — link member
sacrament_marriage (sổ hôn phối) — link 2 members + 2 witnesses
sacrament_anointing (sổ xức dầu) — link member
sacrament_funeral (sổ an táng) — link member
mass_intentions (lễ ý) — link member optional
donations (sổ thu chi) — link member optional
liturgical_events (lịch phụng vụ)
```

## Deployment

### Self-host trên máy giáo xứ

```bash
# 1. Tải binary PocketBase + migrations bundle
wget https://github.com/VietCoders/real-church-manager/releases/latest/download/real-cm-server-windows.zip
unzip real-cm-server-windows.zip

# 2. Start (Windows: real-cm-server.exe; macOS/Linux: ./real-cm-server)
real-cm-server serve --http=0.0.0.0:8090

# 3. Truy cập admin UI: http://localhost:8090/_/
#    Email/password admin tạo lần đầu chạy
```

### Cho phép mobile truy cập từ ngoài LAN

3 phương án (free):

1. **Cloudflare Tunnel** (recommended): không cần mở port, không cần IP tĩnh.
   ```bash
   cloudflared tunnel --url http://localhost:8090
   # → ra URL https://random-name.trycloudflare.com
   ```
2. **Tailscale**: VPN mesh, mobile cài Tailscale app, truy cập IP riêng `100.x.x.x`.
3. **Port forward router** (advanced): mở port 8090 trên router, dùng Dynamic DNS (DuckDNS).

### Backup

```bash
# Backup tự động hằng đêm (cron)
0 2 * * * cp -r ~/real-cm-server/pb_data ~/backups/pb_data-$(date +%F)/

# Hoặc qua admin UI: Settings → Backup → Create new
```

## Cấu trúc repo (monorepo)

```
real-church-manager/
├── backend/                   # PocketBase + migrations + hooks
│   ├── pb_migrations/
│   ├── pb_hooks/
│   └── README.md
├── apps/
│   └── flutter_app/           # Flutter monorepo (Phase 2 sẽ flutter create)
├── packages/
│   └── schema/                # Source-of-truth schema (JSON, dùng cả backend + frontend)
├── docs/                      # User guide, architecture, data model
├── maps/                      # tree.md, functions.md (anti-duplicate)
├── plans/                     # Phase plans
├── scripts/                   # Build/release/seed POSIX scripts
├── .github/workflows/         # CI/CD matrix build
├── LICENSE                    # MIT
├── README.md                  # VI
├── AGENTS.md                  # Project Overrides + convention
└── CLAUDE.md                  # AI agent context
```

## Bảo mật

- HTTPS bắt buộc khi expose ra internet (Cloudflare Tunnel auto cho HTTPS).
- PocketBase RLS rules per collection: `@request.auth.role = 'priest_pastor' || @request.auth.id = ownerField`.
- Secret keys (admin password, OAuth credentials) trong `pb_data/` per-deployment, KHÔNG commit.
- Audit log built-in PocketBase: ai sửa gì, lúc nào.
- Backup nhạy cảm cá nhân (giáo dân) — encrypt khi backup ra cloud.

## Performance

- Giáo xứ 5,000 giáo dân + 50 records/ngày = SQLite thừa sức (PB benchmark 10k+ req/s với SQLite).
- Realtime SSE: PB tested 10,000 concurrent subscribers.
- Mobile cache 50MB qua Hive đủ cho 1 giáo họ ~500 thành viên.

## Mở rộng

Khi giáo phận muốn quản lý đa giáo xứ, mỗi giáo xứ vẫn 1 PocketBase instance riêng (data isolation), thêm 1 lớp aggregator (giáo phận-level) đọc REST API tổng hợp. v1.1+.
