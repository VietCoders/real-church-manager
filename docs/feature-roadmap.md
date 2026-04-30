# Feature Roadmap — Real Church Manager

> Lộ trình tính năng dựa trên QLGX 3.3.7 (tham khảo) + cải tiến cho v1+.

## Triết lý cải tiến vs QLGX

| QLGX 3.3.7 | Real Church Manager |
|---|---|
| Windows-only Delphi monolith | Đa nền tảng Win + Mac + Android (iOS sau) |
| Database file local lock 1 PC | Backend PocketBase, sync nhiều thiết bị |
| Mỗi giáo xứ 1 file riêng, cập nhật mất tay | Realtime sync — sửa 1 nơi cập nhật mọi nơi |
| Đóng nguồn, license trả phí mỗi máy | MIT mã nguồn mở, không phí, fork tự do |
| In sổ giấy → cha xứ ký tay | Vẫn in PDF, kèm số liệu xuất Excel |
| UI cũ kỹ Delphi 32-bit | Material Design 3, dark mode, tokens |
| Tiếng Việt only | i18n từ đầu, cộng đồng dịch dễ |
| Không có mobile | Android trước, iOS sau |

## v1 Scope (MVP — Phase 1-7)

### M1 — Quản lý giáo dân (Member)
- Hồ sơ giáo dân: tên thánh, họ tên, ngày sinh, giới tính, địa chỉ, điện thoại, email, ảnh, ghi chú
- Liên kết: cha, mẹ, gia đình, giáo họ
- Tham chiếu chéo: các bí tích đã nhận
- Tìm kiếm full-text VN (có dấu / không dấu)
- Filter theo độ tuổi, giới tính, giáo họ
- Import từ Excel/CSV, export

### M2 — Gia đình (Family)
- Gia trưởng + vợ/chồng + con cháu
- Cây gia phả (tree visual cơ bản)
- Lịch sử hôn phối
- Địa chỉ chung của gia đình
- Phân vùng giáo họ

### M3 — Giáo họ / Giáo khu (District)
- Phân vùng địa lý của giáo xứ
- Trưởng giáo họ
- Liệt kê thành viên theo giáo họ
- Bản đồ (optional v1.x)

### M4 — Sổ Bí Tích (Sacrament books) — 5 sổ
1. **Sổ Rửa Tội**: số sổ, ngày rửa tội, người được rửa, cha mẹ, cha/mẹ đỡ đầu, cha rửa tội, ghi chú phụng vụ
2. **Sổ Thêm Sức**: ngày thêm sức, người được thêm sức, đức Giám mục, người đỡ đầu, tên Thánh thêm sức
3. **Sổ Hôn Phối**: ngày hôn phối, chàng + nàng, cha mẹ 2 bên, người chứng, cha chủ sự, ghi chú
4. **Sổ Xức Dầu**: ngày xức dầu, người được xức, tình trạng, cha thực hiện
5. **Sổ An Táng (Linh Hồn / Tử)**: ngày qua đời, ngày an táng, nguyên nhân, nơi an táng, cha cử hành

Mỗi sổ:
- CRUD record
- Tự động cập nhật field tương ứng trên Member (vd `member.baptism_date` khi tạo Baptism record liên kết)
- In **chứng chỉ Bí Tích PDF** layout chuẩn VN (cha xứ ký + dấu giáo xứ)
- In **sổ giấy A4** xuất nhiều record liên tục
- Tìm kiếm theo số sổ, ngày, tên người

### M5 — Đoàn thể / Hội đoàn (Group)
- Danh sách hội đoàn: Hội Mân Côi, Legio Mariæ, Thiếu Nhi Thánh Thể, Gia Đình Phạt Tạ, Ca đoàn, Giới Trẻ, Giới Cao Niên, ...
- Mỗi hội: trưởng hội, phó hội, thành viên (link đến Member)
- Lịch họp/sinh hoạt cơ bản
- Báo cáo số thành viên theo hội/độ tuổi

### M6 — Lễ ý cầu nguyện (Mass intention)
- Đăng ký lễ ý: ngày dự kiến, tên người xin, ý chỉ (cầu cho ai/việc gì), số tiền dâng (nếu có)
- Cha xứ duyệt + xếp lịch lễ
- Báo cáo lễ ý đã thực hiện / chờ

### M7 — Sổ thu chi (Donation)
- Dâng cúng theo dịp: lễ Chúa Nhật, lễ trọng, công đức xây dựng, xin lễ
- Theo cá nhân hoặc gia đình hoặc khuyết danh
- Báo cáo thu/chi tháng/quý/năm

### M8 — Lịch phụng vụ (Liturgical calendar)
- Lịch Mass hàng tuần (giờ lễ thứ 2-CN)
- Lễ trọng / lễ kính
- Mùa phụng vụ: Vọng, Giáng Sinh, Thường Niên, Chay, Phục Sinh
- Tích hợp lịch ngày Thánh / lễ bổn mạng
- (Optional v1.x) Đồng bộ với liturgicalcalendar.org API

### M9 — Báo cáo thống kê (Reports)
- Số giáo dân theo độ tuổi (0-12, 13-18, 19-30, 31-60, 60+)
- Theo giới tính
- Theo giáo họ
- Số bí tích trong năm: bao nhiêu rửa tội, bao nhiêu hôn phối...
- Số người mất trong năm
- Export PDF + Excel

### M10 — Phân quyền (Auth & Roles)
- **Cha xứ** (priest_pastor): full quyền
- **Cha phó** (priest_assistant): tất cả trừ xoá settings giáo xứ
- **Thư ký** (secretary): CRUD giáo dân/sổ, đọc reports, không xoá
- **Ban hành giáo** (council_member): đọc, sửa data trong phạm vi được giao
- **Khách** (guest): chỉ đọc info công khai (lịch lễ, tên cha xứ)

## v1.1+ Roadmap

- iOS support (cần Apple Developer account)
- Linux desktop polish
- Importer từ QLGX 3.3.7 database (cần file mẫu DB Paradox/SQLite)
- Bản đồ giáo họ (Leaflet/MapBox)
- Notification: nhắc lễ giỗ, sinh nhật, lễ bổn mạng giáo dân
- SMS/Zalo gateway gửi thông báo lễ
- Multi-parish: 1 instance phục vụ nhiều giáo xứ (giáo phận-level)
- Tích hợp livestream Mass YouTube
- Encrypted backup tự động (rclone đến Google Drive cá nhân)
- Đa ngôn ngữ: Anh, Latin (phụng vụ), Tày/Nùng (vùng dân tộc)

## Chưa làm trong v1 (intentional)

- Web SPA truy cập qua browser (Flutter web build được nhưng không scope v1)
- Kế toán phức tạp (chỉ có thu/chi đơn giản)
- Tích hợp ngân hàng (sao kê tự động)
- Mobile app cho **giáo dân** (chỉ cho **người quản lý** giáo xứ)
- AI nhận diện chữ viết tay từ sổ giấy cũ
- Reverse engineering format DB QLGX 3.3.7 (cần file mẫu)

## Phase mapping

| Phase | Modules | Trạng thái |
|---|---|---|
| 1 | Foundation (rules, docs, schema) | 🔄 Đang làm |
| 2 | Flutter scaffold + tokens + i18n | ⏳ Chờ |
| 3 | PocketBase migrations + auth | ⏳ Chờ |
| 4 | M1 Member + M2 Family + M3 District | ⏳ Chờ |
| 5 | M4 Sacrament books (5 sổ) | ⏳ Chờ |
| 6 | M5 Group + M6 Mass + M7 Donation + M8 Calendar + M9 Reports | ⏳ Chờ |
| 7 | CI/CD + release packaging | ⏳ Chờ |
