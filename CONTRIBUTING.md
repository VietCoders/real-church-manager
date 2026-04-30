# Đóng góp cho Real Church Manager

Cảm ơn bạn quan tâm. Project này được làm với mong muốn phục vụ Hội Thánh và các giáo xứ Việt Nam.

## Trước khi đóng góp

1. Đọc [`AGENTS.md`](AGENTS.md) — naming convention, prefix, folder structure.
2. Đọc [`maps/tree.md`](maps/tree.md) + [`maps/functions.md`](maps/functions.md) — anti-duplicate workflow.
3. Đọc [`docs/feature-roadmap.md`](docs/feature-roadmap.md) — tránh đóng góp tính năng đã có hoặc đã loại.

## Loại đóng góp

| Loại | Cần làm gì |
|---|---|
| **Bug fix** | Mở issue mô tả bug → fork → branch `fix/<slug>` → PR |
| **Tính năng mới** | Mở issue thảo luận trước → đợi approve → fork → branch `feat/<slug>` |
| **Tài liệu** | Branch `docs/<slug>` — không cần issue |
| **Dịch thuật** | Sửa `apps/flutter_app/lib/l10n/app_<locale>.arb` |
| **Báo lỗi** | Mở GitHub issue, kèm version + OS + cách reproduce |

## Naming convention (BẮT BUỘC)

- **Folder depth ≤ 3 cấp** dưới `lib/` Flutter và `backend/` PocketBase.
- **File basename = 1 từ** `snake_case` (Dart) — vd `repository.dart`, KHÔNG `member_repository.dart`.
- **Concept = danh từ nghiệp vụ**: `Member`, `Family`, `Sacrament`. KHÔNG verb (`Apply`, `Process`).
- **Role chuẩn** (file 1 từ): `Repository`, `Service`, `Validator`, `Renderer`, `Notifier`, `Builder`. KHÔNG `Helper`, `Util`.
- **Prefix Dart**: top-level fn `realCm<Name>` camelCase, class theo namespace folder.
- **Prefix PocketBase**: hook event `real_cm_*`, collection `snake_case` (PB convention).

## Code quality

- KHÔNG hardcode chuỗi user-facing — qua i18n `AppLocalizations.of(context)!.<key>`.
- KHÔNG `alert()/confirm()/prompt()` native — dùng `realCmModal/realCmToast/realCmConfirm` từ `lib/ui/`.
- KHÔNG hardcode color/spacing — dùng `RealCmColors`, `RealCmSpacing` từ `lib/design/tokens.dart`.
- Source string locale = **tiếng Việt** (`app_vi.arb`). Tiếng Anh là bản dịch.

## Quy trình PR

1. Fork repo.
2. Clone fork: `git clone git@github.com:<your-user>/real-church-manager.git`.
3. Branch: `git checkout -b feat/<short-slug>` hoặc `fix/<short-slug>`.
4. Code + commit (message tiếng Việt, conventional format: `feat: thêm form đăng ký rửa tội`).
5. Push + mở PR vào `main` của `VietCoders/real-church-manager`.
6. Tick đủ checklist trong PR template, đặc biệt **Maps compliance**.
7. Đợi review. Cha xứ/maintainer sẽ check + merge.

## Setup dev local

```bash
# Backend
cd backend
./start.sh                # tự tải PocketBase v0.22.21

# Flutter (cài Flutter SDK 3.22+ trước)
cd apps/flutter_app
flutter pub get
flutter gen-l10n          # sinh AppLocalizations từ arb files
flutter run -d windows    # hoặc macos / android / linux
```

## Code of conduct

Project này phục vụ cộng đồng tôn giáo. Đối xử với contributor khác bằng sự kính trọng, không phân biệt:
- Tôn giáo, giáo phận, dòng tu
- Quốc tịch, dân tộc, ngôn ngữ
- Trình độ kỹ thuật, kinh nghiệm

Nội dung đóng góp phải:
- Phù hợp giáo lý Công giáo (vd: không thêm tính năng đi ngược giáo huấn Hội Thánh).
- Tôn trọng dữ liệu cá nhân giáo dân — KHÔNG làm tính năng leak data ra ngoài.

## Liên hệ

- **Maintainer**: Đạo Trần ([realdev.vn](https://realdev.vn) · `minhvinhdao.oc@gmail.com`)
- **Cộng đồng**: [VietCoders](https://github.com/VietCoders)

*Soli Deo gloria.*
