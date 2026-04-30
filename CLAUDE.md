# CLAUDE — Project context cho Real Church Manager

> File này load tự động khi Claude làm việc trong project. Chỉ ghi điều **khác** với rule global.

## Bối cảnh

- **Project type**: Flutter (Win+Mac+Android+Linux) + PocketBase backend.
- **Domain**: Quản lý giáo xứ Công giáo Việt Nam.
- **License**: MIT, repo public `VietCoders/real-church-manager`.
- **Source string locale**: `vi`. Toàn bộ UI/error/log/comment code mặc định **tiếng Việt**.
- **iOS**: chưa hỗ trợ v1, KHÔNG scaffold `ios/` folder hoặc thêm cấu hình Apple cho đến khi user yêu cầu.

## Override mặc định global

Đọc `AGENTS.md` để biết Project Overrides chi tiết. Một vài điểm quan trọng:

- Slug short: `real-cm` (KHÔNG `real-pt`, KHÔNG `real-rcm`).
- Dart package: `real_church_manager` (snake_case theo Dart convention).
- Brand color: tím phụng vụ `#7c3aed` (primary), vàng lễ trọng `#f59e0b` (accent).
- Test policy: OPT-IN. Không tự generate test trừ khi user yêu cầu hoặc trigger §2 active.

## Domain glossary (Catholic VN)

Khi viết code/UI, dùng đúng thuật ngữ phụng vụ Công giáo VN, KHÔNG dịch máy:

| English | Tiếng Việt |
|---|---|
| Baptism | Rửa Tội |
| Confirmation | Thêm Sức |
| First Communion | Rước Lễ Lần Đầu |
| Marriage / Holy Matrimony | Hôn Phối |
| Anointing of the Sick | Xức Dầu Bệnh Nhân |
| Funeral | An Táng (sổ Linh Hồn / Sổ Tử) |
| Holy Orders | Truyền Chức Thánh |
| Mass | Thánh Lễ |
| Mass intention | Lễ Ý / Ý Cầu Nguyện |
| Parish | Giáo Xứ |
| Parish district / zone | Giáo Họ / Giáo Khu |
| Diocese | Giáo Phận |
| Priest | Linh Mục / Cha |
| Pastor / Parish priest | Cha Xứ |
| Vicar / Assistant priest | Cha Phó |
| Parish council | Hội Đồng Mục Vụ Giáo Xứ |
| Parishioner | Giáo Dân |
| Family head | Gia Trưởng |
| Godfather / Godmother | Cha Đỡ Đầu / Mẹ Đỡ Đầu |
| Witness (marriage) | Người Chứng |
| Confraternity / Group | Hội Đoàn / Đoàn Thể |
| Donation / Offering | Dâng Cúng / Tiền Dâng |
| Liturgical calendar | Lịch Phụng Vụ |
| Feast day (solemn) | Lễ Trọng |
| Saint name | Thánh Bổn Mạng / Tên Thánh |

## Special data fields

- **Tên Thánh** (saint name) là field độc lập với họ tên. Đăng ký giáo dân thường ghi: `Phêrô Nguyễn Văn A` → first part = saint name (Phêrô), rest = họ tên đời. Tách 2 field riêng trong DB.
- **Ngày sinh** vs **ngày Rửa Tội** vs **ngày bổn mạng**: 3 ngày khác nhau, mỗi field riêng.
- **Cha mẹ** giáo dân: lưu reference đến member khác nếu cùng giáo xứ, hoặc text plain nếu không (cha mẹ chưa di chuyển sang hệ thống).

## Rule highlight

- **Maps trước code**: bắt buộc đọc `maps/tree.md` + `maps/functions.md` mỗi task. Tạo function/class mới phải PROPOSE qua `maps/proposals.md`.
- **i18n source string**: tiếng Việt. KHÔNG `<Text('Submit')>`, phải `<Text(AppLocalizations.of(context)!.commonSubmit)>` với arb VI ghi `"Gửi"`.
- **Folder depth ≤3 cấp** dưới `lib/`. Vi phạm = refactor structure.
- **CẤM verb-as-name**: `ApplyMember.dart` SAI → `member/applier.dart` ĐÚNG.

## Phases

7 phase, xem `plans/20260430-2330-bootstrap/plan.md`. Đang ở **Phase 1 (Foundation)**. Phase 2 sẽ Flutter scaffold.

## Liên hệ

Tác giả: Đạo Trần (`minhvinhdao.oc@gmail.com`).
