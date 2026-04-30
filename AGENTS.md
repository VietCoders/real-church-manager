# AGENTS — Real Church Manager

> Tài liệu này dành cho **AI agent (Claude Code, Codex, ...) và contributor**. Đọc trước khi sửa code.

## Rule version

```
Snapshot: 2026-04-30-v5.23
```

Khi rule global RealDev (`~/.claude/rules/`) thay đổi, project tuân theo snapshot này cho đến khi chạy `/realinit --boiler` hoặc `/realinit --audit` để sync/verify current contract.

## Project Overrides

Override các biến `{{VAR}}` từ `~/.claude/CLAUDE.md`:

```yaml
# Identity
PROJECT_NAME_HUMAN: "Real Church Manager"
PROJECT_SLUG: real-church-manager
PROJECT_SLUG_SHORT: real-cm
PROJECT_SLUG_SNAKE: real_cm
PROJECT_NAMESPACE: RealChurchManager       # Dart class name root
PROJECT_DART_PACKAGE: real_church_manager  # pubspec name
PROJECT_JS_GLOBAL: realCm
PROJECT_TYPE: "Multi-platform App + Backend"
PROJECT_TYPE_FULL: "Flutter (Win+Mac+Android) + PocketBase (Go) + SQLite"
PROJECT_INDUSTRY: "Catholic Parish Management"
PROJECT_DESCRIPTION: "Phần mềm quản lý giáo xứ Công giáo đa nền tảng, đồng bộ thời gian thực, mã nguồn mở MIT"
PROJECT_PURPOSE: "Số hoá việc quản lý giáo dân, gia đình, sổ Bí Tích, đoàn thể, lễ phụng vụ. Dữ liệu thuộc về giáo xứ, không lock vendor."

# Brand colors — preset Catholic/Religious
PROJECT_PRIMARY_COLOR: "#7c3aed"   # tím phụng vụ (mùa Vọng/Chay)
PROJECT_ACCENT_COLOR: "#f59e0b"    # vàng (lễ trọng)

# License
DEFAULT_LICENSE: MIT
DEFAULT_LICENSE_SPDX: "MIT"
DEFAULT_LICENSE_URI: "https://opensource.org/licenses/MIT"

# Locale
DEFAULT_LOCALE: vi   # source string locale
SUPPORTED_LOCALES: [vi, en]   # mở rộng dần

# GitHub
GITHUB_OWNER: VietCoders
GITHUB_REPO: real-church-manager
GITHUB_VISIBILITY: public   # OPEN SOURCE — repo public từ ngày đầu

# Stack
FRONTEND: Flutter 3.x
FRONTEND_TARGETS: [windows, macos, android, linux]   # iOS sẽ thêm v1.1
BACKEND: PocketBase ^0.22
DATABASE: SQLite (PocketBase embed)
SYNC: SSE Realtime (PocketBase native)

# Test policy
test_policy: optional   # mặc định OPT-IN per ~/.claude/rules/primary-workflow.md §2
```

## Convention

### Naming

- **Folder structure**: depth tối đa 3 cấp dưới `lib/` (Flutter) và `backend/` (PocketBase).
- **File basename**: 1 từ snake_case (Dart convention), ví dụ `member_repository.dart` → SAI; phải là `lib/data/member/repository.dart` ✓.
- **Concept = danh từ nghiệp vụ**: `Member`, `Family`, `Sacrament`, `Group`, `Mass`, `Donation`, `District`, `User`.
- **Role = role chuẩn**: `Repository`, `Service`, `Validator`, `Renderer`, `Notifier`, `Builder`, `Factory`, `Provider`, `Controller`. CẤM `Helper`, `Util`, `Manager*Manager`.
- **CẤM verb-as-name**: `ApplyX`, `ProcessY`, `RunZ`. Dùng `Applier`, `Processor`, `Runner`.

### Prefix

| Loại | Format | Ví dụ |
|---|---|---|
| Dart top-level fn | `realCm<Name>` camelCase | `realCmFormatBaptismDate()` |
| Dart class | `RealCm<Name>` Pascal hoặc đặt theo namespace folder | `RealCmTokens`, `Member.fromJson()` |
| PocketBase collection | snake_case, **không prefix** (PB convention) | `members`, `sacrament_baptism` |
| PocketBase hook event | `real_cm_<event>` | `real_cm_member_created` |
| Dart event/stream key | `real-cm:<event>` | `real-cm:realtime:member` |
| LocalStorage / Hive box | `real-cm:<key>` | `real-cm:cache:members` |
| Asset handle | `real-cm-<role>` | `real-cm-icons`, `real-cm-tokens` |

### Folder structure (Flutter `lib/`)

```
lib/
├── core/                 # primitive: container, events, http, cache, logging
├── design/               # tokens.dart, theme.dart, icon_map.dart
├── data/                 # repository per concept
│   ├── member/
│   ├── family/
│   ├── sacrament/        # 5 sub-concept đi qua role file
│   └── ...
├── domain/               # entity + value object thuần
├── features/             # feature module (UI + state)
│   ├── member/
│   ├── family/
│   ├── sacrament/
│   ├── group/
│   ├── mass/
│   ├── donation/
│   └── report/
├── ui/                   # shared widget (button, field, card, modal)
├── l10n/                 # arb files
├── platform/             # adapter: pocketbase_client, hive_adapter, file_picker
└── main.dart
```

→ Mỗi feature có `data/`, `presentation/` (screen + widget), `state/` (providers). Domain/entity nằm ở `domain/`.

### Maps workflow

Bắt buộc đọc `maps/tree.md` + `maps/functions.md` TRƯỚC mọi task. Mọi function/class/hook MỚI phải qua **PROPOSE block** trong `maps/proposals.md`. Xem `~/.claude/rules/maps-folder-rules.md`.

### i18n

- Source string locale: `vi` (Tiếng Việt). LLM tạo UI/error/log message **tiếng Việt** mặc định.
- File: `apps/flutter_app/lib/l10n/app_vi.arb` (source) + `app_en.arb` (translation).
- Hàm: `AppLocalizations.of(context)!.<key>` — KHÔNG hardcode chuỗi user-facing.
- Key: `snake_case` namespace rõ: `member.form.full_name`, `sacrament.baptism.title`.

### Git commit

- Commit ngay sau từng phần nhỏ. KHÔNG hỏi lại.
- Type: `feat` · `fix` · `refactor` · `style` · `docs` · `chore` · `test`.
- Tiếng Việt: `feat: thêm form đăng ký rửa tội` · `fix: sửa nonce verify khi update member`.
- Build/release commit có Before/After block (xem `~/.claude/rules/github-sync-rules.md` §5).
- Auto bump version timestamp trước commit theo `~/.claude/CLAUDE.md` Git section: gọi `bash ~/.claude/tools/bump-version-timestamp.sh` để bump `<base>.<TS>` cho `pubspec.yaml` Flutter và bất kỳ file version nào khác.

## Kiến trúc dữ liệu

15+ collections, xem `docs/data-model.md`. Source-of-truth schema: `packages/schema/collections.json`.

## Phases

Project chia 7 phase. Xem `plans/20260430-2330-bootstrap/plan.md`.

## Stack tham khảo (không tự đổi nếu không discuss)

- **Flutter**: Riverpod (state), go_router (navigation), pocketbase (Dart SDK), hive (offline cache), intl (i18n), pdf (in chứng chỉ), file_picker (import).
- **PocketBase**: hooks JS (JSVM), migrations file-based, SSE realtime native.
- **Build**: GitHub Actions matrix `windows-latest` + `macos-latest` + `ubuntu-latest`.

## Liên hệ

- **Tác giả**: Đạo Trần (`minhvinhdao.oc@gmail.com`)
- **Repo**: github.com/VietCoders/real-church-manager
