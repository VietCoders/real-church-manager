# Changelog

Tất cả thay đổi quan trọng cho dự án này được ghi tại đây. Format theo [Keep a Changelog](https://keepachangelog.com/) + [SemVer](https://semver.org/).

## [Unreleased]

### Added
- **Phase 1**: Foundation (LICENSE MIT, README VN, AGENTS.md, CLAUDE.md, docs/, maps/, plans/, packages/schema 16 collections).
- **Phase 2**: Flutter monorepo scaffold — `pubspec.yaml`, `lib/` 3-cấp depth (core/design/platform/domain/data/features/ui/l10n), Riverpod + go_router + PocketBase + Hive + i18n VI/EN.
- **Phase 3**: PocketBase backend — 1 init migration tạo 16 collections, 4 hooks (validate_member, validate_marriage, derived_member_dates, auto_book_number), launcher cross-OS (start.sh + start.bat).
- **Phase 4**: Member full (entity + repository + list screen với search/drawer/realtime), Family + District (entity + repository).
- **Phase 5**: Sacrament Baptism (entity + repository + PDF certificate builder layout VN). 4 sổ còn lại theo cùng pattern (sẽ scaffold v1.0.x).
- **Phase 6**: Group + Donation entity. Mass intentions + Liturgical events + Reports sẽ làm v1.0.x.
- **Phase 7**: GitHub Actions CI/CD — build matrix Win+Mac+Android+Linux, backend bundle 5 OS/arch combos, auto release trên tag.

### Roadmap

- v1.0.0: hoàn thiện UI Member CRUD + 5 sacrament books + 1 báo cáo cơ bản.
- v1.1.0: Importer từ QLGX 3.3.7 DB, cây gia phả visual, lịch phụng vụ tích hợp.
- v1.2.0: iOS support, Linux desktop polish, notification.

[Unreleased]: https://github.com/VietCoders/real-church-manager
