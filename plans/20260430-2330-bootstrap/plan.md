# Bootstrap Plan — Real Church Manager

> Created: 2026-04-30 23:30
> Owner: Đạo Trần
> Repo: VietCoders/real-church-manager (private dev → public khi v1 release)

## Mục tiêu

Build phần mềm quản lý giáo xứ Công giáo VN đa nền tảng (Win + Mac + Android, iOS sau), backend self-hostable, đồng bộ realtime, mã nguồn mở MIT. Cảm hứng từ QLGX 3.3.7 nhưng làm lại từ đầu.

## Stack đã quyết

| Layer | Tech |
|---|---|
| Frontend | Flutter 3.x (1 codebase → Win/Mac/Android/Linux) |
| State | Riverpod 2.x |
| Navigation | go_router |
| Backend | PocketBase ^0.22 (Go binary + SQLite) |
| Sync | PocketBase Realtime SSE |
| Offline cache | Hive |
| i18n | flutter_localizations + intl + arb files |
| PDF | pdf + printing packages |
| License | MIT |

## Verification quote (maps)

> Theo `maps/tree.md` repo root: skeleton 9 folder (docs, maps, plans, packages, backend, apps, scripts, .github, root files) đã định nghĩa. Theo `maps/functions.md`: Phase 1 chưa có Dart/Go symbol — chỉ docs + schema + license. Phase 2+ sẽ bắt đầu propose từng symbol qua `maps/proposals.md`.

## 7 Phase

### Phase 1 — Foundation + docs + maps + schema source ⬅ ĐANG LÀM

**Status**: 🔄 in_progress

**Owns**:
- `LICENSE`, `README.md`, `.gitignore`, `AGENTS.md`, `CLAUDE.md`
- `docs/system-architecture.md`, `docs/data-model.md`, `docs/feature-roadmap.md`
- `maps/tree.md`, `maps/functions.md`, `maps/touched.log`, `maps/proposals.md`
- `plans/20260430-2330-bootstrap/plan.md` (file này)
- `packages/schema/collections.json` + `packages/schema/README.md`
- `backend/README.md`, `apps/flutter_app/README.md`, `scripts/README.md`

**Depends on**: none

**Acceptance**:
- [x] LICENSE MIT 2026 author Đạo Trần
- [x] README VN với triết lý + tính năng + quick start placeholder
- [x] AGENTS.md có Project Overrides đầy đủ (slug, namespace, brand color, locale, github_owner)
- [x] CLAUDE.md với domain glossary VN Công giáo
- [x] docs/ 3 file: architecture + data-model 16 collections + roadmap 7 phase
- [x] maps/ 4 file scaffolded
- [x] plan.md với Agent Allocation Map
- [x] schema source (collections.json) cover 16 collections
- [ ] git init + first commit
- [ ] (Optional) gh repo create private → push

**Wave**: 1 (sequential — single agent / single session)

---

### Phase 2 — Flutter monorepo scaffold + design tokens + i18n + PocketBase client

**Status**: ⏳ pending

**Owns**: `apps/flutter_app/`

**Tasks**:
1. `cd apps/flutter_app && flutter create . --project-name real_church_manager --platforms=windows,macos,linux,android --org vn.realdev.realchurchmanager`
2. `pubspec.yaml` deps:
   - State: `flutter_riverpod ^2.5`
   - Navigation: `go_router ^14`
   - Backend: `pocketbase ^0.20`
   - Cache: `hive ^2.2` + `hive_flutter ^1.1`
   - i18n: `flutter_localizations` (sdk) + `intl ^0.19`
   - PDF: `pdf ^3.10` + `printing ^5.12`
   - File: `file_picker ^8`, `image_picker ^1`
   - Utility: `freezed ^2`, `json_serializable ^6`
3. `lib/` structure theo `maps/tree.md`:
   - `core/`, `design/`, `platform/`, `domain/`, `data/`, `features/`, `ui/`, `l10n/`
4. `lib/design/tokens.dart`: AppTokens (color theo brand `#7c3aed` tím phụng vụ + `#f59e0b` vàng lễ trọng, spacing scale 4-8-12-16-24-32, radius, duration, easing)
5. `lib/design/theme.dart`: ThemeData light/dark từ tokens
6. `lib/design/icons.dart`: IconMap semantic (member, family, baptism, mass, ...) → IconData
7. `l10n.yaml` + `lib/l10n/app_vi.arb` (source) + `app_en.arb` (translation stub)
8. `lib/platform/pocketbase/client.dart`: wrapper + retry + auth state
9. `lib/platform/pocketbase/auth.dart`: login/logout/refresh + role check
10. `lib/platform/storage/adapter.dart`: Hive box init + cache helpers
11. `lib/ui/modal/service.dart` + `toast/service.dart`: `realCmModal()`, `realCmToast()` abstraction
12. `lib/ui/field/`: FieldSchema + FieldRegistry + FieldRenderer (text/date/select/relation/textarea/file)
13. `lib/main.dart` + `lib/app.dart`: router skeleton, login screen placeholder

**Depends on**: Phase 1

**Wave**: 1 (single agent — fullstack-developer)

**Estimate**: ~30-40 file, ~2000-3000 LOC

---

### Phase 3 — PocketBase migrations + 16 collections + auth/roles + hooks

**Status**: ⏳ pending

**Owns**: `backend/`

**Tasks**:
1. `backend/start.sh` + `start.bat` launcher (POSIX-safe + Windows)
2. Download PocketBase binary script (v0.22+)
3. 16 migration files theo `docs/data-model.md`:
   - `001_users_extend.json` (thêm role/member_id field vào auth users)
   - `002_parish_settings.json`
   - `003_districts.json`
   - `004_members.json` (lớn nhất, ~30 fields)
   - `005_families.json`
   - `006_family_members.json`
   - `007_sacrament_baptism.json`
   - `008_sacrament_confirmation.json`
   - `009_sacrament_marriage.json`
   - `010_sacrament_anointing.json`
   - `011_sacrament_funeral.json`
   - `012_groups.json`
   - `013_group_members.json`
   - `014_mass_intentions.json`
   - `015_donations.json`
   - `016_liturgical_events.json`
4. RLS rules per collection (5 role: pastor/assistant/secretary/council/guest)
5. `pb_hooks/`:
   - `validate_member.js` (birth_date < death_date, format saint_name)
   - `validate_marriage.js` (groom != bride, dates valid)
   - `derived_member_dates.js` (auto-update member.baptism_date khi tạo Baptism)
   - `auto_book_number.js` (sinh `<TYPE>-<YYYY>-<seq>`)
   - `audit_log.js` (ghi mọi thay đổi)
6. Seed script `scripts/seed.sh`: tạo admin user + parish_settings demo + 1 district mẫu

**Depends on**: Phase 1 (schema source-of-truth `packages/schema/collections.json`)

**Wave**: 2 (sau Flutter scaffold xong để test client kết nối)

---

### Phase 4 — Member + Family + District modules

**Status**: ⏳ pending

**Owns**: `apps/flutter_app/lib/data/{member,family,district}/`, `lib/domain/{member,family,district}/`, `lib/features/{member,family,district}/`

**Tasks**:
1. Domain entities (Freezed): `Member`, `Family`, `FamilyMember`, `District`
2. Repository per entity với PocketBase + Hive cache
3. Riverpod providers: list, detail, search, filter
4. Realtime subscription mỗi collection
5. UI screens:
   - Member: list (paginated, search VN có dấu/không dấu, filter), detail, form (FieldRenderer schema), import Excel
   - Family: list, detail (members), tree visual
   - District: list, detail
6. Offline queue khi mất mạng

**Depends on**: Phase 2 + Phase 3

**Wave**: 3

---

### Phase 5 — 5 Sổ Bí Tích

**Status**: ⏳ pending

**Owns**: `apps/flutter_app/lib/{data,domain,features}/sacrament/`, `lib/platform/pdf/`

**Tasks**:
1. 5 domain entities + 5 repository
2. 5 feature module với CRUD UI
3. Auto-update member sacrament dates qua hook (Phase 3) hoặc Dart side (fallback)
4. PDF chứng chỉ:
   - Layout VN chuẩn: logo + tên giáo xứ + tiêu đề bí tích + thông tin người + cha cử hành + dấu/chữ ký
   - 1 layout per bí tích, share base
5. In sổ A4 nhiều record liên tục
6. Tìm kiếm theo book_number, ngày, tên người

**Depends on**: Phase 4 (cần Member để link)

**Wave**: 4

---

### Phase 6 — Group + Mass + Donation + Calendar + Reports

**Status**: ⏳ pending

**Owns**: `lib/{data,domain,features}/{group,mass,donation,calendar,report}/`

**Tasks**:
1. Group: CRUD, link member, role (head/vice/treasurer/...)
2. Mass intention: đăng ký + duyệt + xếp lịch
3. Donation: ledger thu/chi, link member/family optional
4. Liturgical calendar: events tuần/tháng/năm, lễ trọng, mùa phụng vụ
5. Reports: 8+ loại báo cáo (theo độ tuổi, giới tính, bí tích/năm, ...) export PDF + Excel

**Depends on**: Phase 4 (Member) + Phase 5 (Sacrament — cho report)

**Wave**: 5

---

### Phase 7 — CI/CD + release

**Status**: ⏳ pending

**Owns**: `.github/workflows/`, `scripts/`

**Tasks**:
1. Tạo repo `VietCoders/real-church-manager` (gh CLI, public từ đầu vì open source)
2. Branch protection main (require PR review)
3. `.github/workflows/build-flutter.yml`: matrix Win+Mac+Android trên tag `v*`
4. `.github/workflows/build-backend.yml`: bundle PocketBase + migrations + hooks → 3 binary (Win/Mac/Linux)
5. `.github/workflows/release.yml`: gh release create + upload artifacts
6. PR template với Maps compliance check
7. README badge build status + version
8. CHANGELOG.md
9. CONTRIBUTING.md
10. Issue templates

**Depends on**: Phase 6

**Wave**: 6

---

## Agent Allocation Map

| Phase | Agent type | Owns | Reads | Wave |
|---|---|---|---|---|
| 1 | (main, không delegate) | foundation files | rule global | 1 |
| 2 | fullstack-developer | `apps/flutter_app/lib/{core,design,platform,ui,l10n}/` + `pubspec.yaml` | docs/, maps/, packages/schema | 2 |
| 3 | fullstack-developer (Go/JS focus) | `backend/` | docs/data-model.md, packages/schema | 2 (parallel với Phase 2 nếu schema lock) |
| 4 | fullstack-developer | `lib/{data,domain,features}/{member,family,district}/` | core, design, platform, ui từ Phase 2; backend từ Phase 3 | 3 |
| 5 | fullstack-developer + ui-ux-designer (PDF layout) | `lib/{data,domain,features}/sacrament/`, `lib/platform/pdf/` | Phase 4 Member | 4 |
| 6 | fullstack-developer | `lib/{data,domain,features}/{group,mass,donation,calendar,report}/` | Phase 4-5 | 5 |
| 7 | fullstack-developer (DevOps) | `.github/workflows/`, `scripts/` | mọi nơi | 6 |

→ **Wave 2** Phase 2+3 có thể parallel nếu schema source-of-truth (Phase 1 deliverable) đủ chi tiết. Ownership không overlap (Flutter `apps/` vs `backend/`).

## Sau bootstrap

Phase 1 xong → user sẽ confirm ai chạy Phase 2 + 3 (Claude continue, hay user tự `flutter create` rồi paste code, hay parallel agent).

## Verification phrase (Phase 1 close)

Khi end Phase 1: "Đã tuân thủ primary-workflow §1.5 — maps đọc + quote, tree skeleton Concept/Role, structure + symbol approved (foundation only, no business symbol), agent map không overlap, Phase 1 hoàn tất chuẩn."
