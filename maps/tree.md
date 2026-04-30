# Project Tree — Real Church Manager

> Updated: 2026-04-30 · Sync với code mỗi commit · KHÔNG drift

## Repo root

```
real-church-manager/                    # Concept root: parish management monorepo
├── LICENSE                             # MIT
├── README.md                           # Hướng dẫn cài đặt + tính năng (VI)
├── AGENTS.md                           # Project Overrides + naming convention
├── CLAUDE.md                           # AI agent context (override global rules)
├── .gitignore                          # OS/IDE/secret/build artifacts
├── docs/                               # Documentation
│   ├── system-architecture.md          # WHAT + WHY high-level
│   ├── data-model.md                   # 16 collections schema chi tiết
│   └── feature-roadmap.md              # Lộ trình tính năng v1 → v1.x
├── maps/                               # Anti-duplicate inventory (BẮT BUỘC)
│   ├── tree.md                         # File này
│   ├── functions.md                    # Symbol inventory
│   ├── touched.log                     # Append-only task log
│   └── proposals.md                    # Function proposal ledger
├── plans/                              # Phase plans
│   └── 20260430-2330-bootstrap/        # Phase 1-7 plan
│       └── plan.md                     # Overview + Agent Allocation Map
├── packages/                           # Shared packages cross-target
│   └── schema/                         # Source-of-truth schema
│       ├── README.md
│       └── collections.json            # 16 collections JSON (PB import-able)
├── backend/                            # PocketBase server
│   ├── README.md                       # Hướng dẫn run/migrate/backup
│   ├── pb_migrations/                  # JSON migrations file-based
│   └── pb_hooks/                       # JS hooks JSVM
├── apps/                               # Platform apps
│   └── flutter_app/                    # Flutter monorepo (Phase 2 sẽ flutter create)
│       └── README.md                   # Placeholder
├── scripts/                            # Build/release/seed scripts (POSIX-safe)
│   └── README.md                       # Phase tiếp sẽ có script cụ thể
└── .github/                            # GitHub config
    └── workflows/                      # CI/CD (Phase 7)
```

## Flutter `apps/flutter_app/lib/` (Phase 2 sẽ scaffold)

```
lib/
├── main.dart                           # Entry point
├── app.dart                            # MaterialApp + router root
├── core/                               # Primitive (Concept: foundation)
│   ├── container/                      # DI
│   ├── events/                         # Pub/sub bus nội bộ
│   ├── http/                           # HTTP client wrapper
│   ├── cache/                          # Cache abstraction
│   ├── logging/                        # Logger
│   └── error/                          # Error types + handler
├── design/                             # Design system (Concept: visual)
│   ├── tokens.dart                     # AppTokens (color, spacing, radius, ...)
│   ├── theme.dart                      # ThemeData light/dark
│   └── icons.dart                      # IconMap semantic→IconData
├── platform/                           # Platform adapter (Concept: integration)
│   ├── pocketbase/                     # PB client + auth + realtime
│   │   ├── client.dart
│   │   └── auth.dart
│   ├── storage/                        # Hive setup
│   │   └── adapter.dart
│   └── pdf/                            # PDF generation
│       └── builder.dart
├── domain/                             # Pure business entity (Concept: model)
│   ├── member/
│   │   └── entity.dart
│   ├── family/
│   ├── sacrament/                      # 5 sub-concept
│   │   ├── baptism.dart
│   │   ├── confirmation.dart
│   │   ├── marriage.dart
│   │   ├── anointing.dart
│   │   └── funeral.dart
│   ├── group/
│   ├── district/
│   ├── donation/
│   ├── mass/
│   └── calendar/
├── data/                               # Repository (Concept: persistence)
│   ├── member/
│   │   └── repository.dart
│   ├── family/
│   ├── sacrament/
│   │   ├── baptism.dart                # Repository per sacrament
│   │   ├── confirmation.dart
│   │   ├── marriage.dart
│   │   ├── anointing.dart
│   │   └── funeral.dart
│   ├── group/
│   ├── district/
│   ├── donation/
│   ├── mass/
│   └── calendar/
├── features/                           # Feature module (UI + state per concept)
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── providers.dart
│   ├── member/
│   │   ├── list_screen.dart
│   │   ├── detail_screen.dart
│   │   ├── form_screen.dart
│   │   └── providers.dart
│   ├── family/
│   ├── district/
│   ├── sacrament/
│   │   ├── baptism_screen.dart
│   │   ├── confirmation_screen.dart
│   │   ├── marriage_screen.dart
│   │   ├── anointing_screen.dart
│   │   └── funeral_screen.dart
│   ├── group/
│   ├── mass/
│   ├── donation/
│   ├── calendar/
│   ├── report/
│   └── settings/
├── ui/                                 # Shared widget (Concept: component)
│   ├── button/
│   ├── field/
│   │   ├── renderer.dart               # FieldRenderer schema-first
│   │   ├── registry.dart
│   │   └── schema.dart
│   ├── form/
│   │   └── builder.dart                # FormBuilder
│   ├── modal/
│   │   └── service.dart                # real_modal abstraction
│   ├── toast/
│   │   └── service.dart                # real_toast abstraction
│   ├── card/
│   ├── table/
│   └── scaffold/                       # AppShell layout
└── l10n/                               # i18n
    ├── app_vi.arb                      # Source (tiếng Việt)
    └── app_en.arb                      # Translation
```

→ Depth tối đa 3 cấp dưới `lib/` (vd `lib/features/member/list_screen.dart`). Mọi file basename = 1 từ snake_case.

## Backend `backend/` (Phase 3 sẽ populate)

```
backend/
├── README.md
├── start.sh                            # POSIX launcher (cross-OS)
├── start.bat                           # Windows launcher
├── pb_migrations/
│   ├── 20260430_001_users_extend.json
│   ├── 20260430_002_parish_settings.json
│   ├── 20260430_003_districts.json
│   ├── 20260430_004_members.json
│   ├── 20260430_005_families.json
│   ├── 20260430_006_family_members.json
│   ├── 20260430_007_sacrament_baptism.json
│   ├── 20260430_008_sacrament_confirmation.json
│   ├── 20260430_009_sacrament_marriage.json
│   ├── 20260430_010_sacrament_anointing.json
│   ├── 20260430_011_sacrament_funeral.json
│   ├── 20260430_012_groups.json
│   ├── 20260430_013_group_members.json
│   ├── 20260430_014_mass_intentions.json
│   ├── 20260430_015_donations.json
│   └── 20260430_016_liturgical_events.json
└── pb_hooks/
    ├── validate_member.js
    ├── validate_marriage.js
    ├── derived_member_dates.js
    ├── auto_book_number.js
    └── audit_log.js
```

## Notes

- **Folder = 1 trách nhiệm**: `data/member/` chỉ DB access cho Member; `features/member/` chỉ UI Member; KHÔNG trộn.
- **Shared module**: `core/`, `design/`, `platform/`, `ui/` dùng chung mọi feature. CẤM clone vào từng feature.
- **5 sổ Bí Tích là 5 sub-concept của `sacrament`**: mỗi sổ có data + domain + feature riêng nhưng chia sẻ pattern (Repository, Form, List, PDF) qua shared `ui/` + `platform/pdf/`.
