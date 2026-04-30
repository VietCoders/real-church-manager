# Real Church Manager

> Phần mềm **Quản lý Giáo xứ** mã nguồn mở, miễn phí, chạy trên Windows + macOS + Android (iOS sắp tới). Lấy cảm hứng từ QLGX nhưng làm lại từ đầu với kiến trúc đa nền tảng, đồng bộ thời gian thực, và quan trọng nhất — **dữ liệu của giáo xứ thuộc về giáo xứ**, không nằm ở máy chủ bên thứ ba.

## Triết lý

1. **Dữ liệu của bạn — máy của bạn.** Backend là 1 file binary chạy ngay trên máy văn phòng giáo xứ. Cả cơ sở dữ liệu là một file SQLite duy nhất — sao lưu bằng cách copy file.
2. **Một mã nguồn — chạy mọi nơi.** Một codebase Flutter build ra 4 nền tảng. Không phân mảnh.
3. **Đồng bộ ngược thời gian thực.** Cha xứ ghi sổ trên PC văn phòng → cha phó/thư ký thấy ngay trên điện thoại.
4. **Mở để tin cậy.** Mã nguồn công khai trên GitHub. Bất kỳ giáo xứ nào cũng có thể tự kiểm tra, tự build, tự host.
5. **Không khoá người dùng.** MIT License. Fork, sửa, dùng nội bộ, đóng góp ngược — tự do hoàn toàn.

## Tính năng (lộ trình)

Tham khảo và mở rộng từ QLGX 3.3.7:

- **Sổ Bí Tích**: Rửa Tội · Thêm Sức · Hôn Phối · Xức Dầu Bệnh Nhân · An Táng (sổ tử)
- **Quản lý giáo dân**: hồ sơ cá nhân, ngày sinh, ngày bí tích, ảnh, ghi chú
- **Gia đình**: gia trưởng, vợ/chồng, con cháu, cây gia phả
- **Giáo họ / Giáo khu**: phân vùng địa lý
- **Đoàn thể / Hội đoàn**: Hội Mân Côi, Legio Mariæ, Thiếu Nhi Thánh Thể, Ca đoàn, ...
- **Lễ ý cầu nguyện** (Mass intentions): nhận và xếp lịch
- **Lịch phụng vụ**: lễ trong tuần, lễ trọng, mùa phụng vụ
- **Sổ thu chi**: dâng cúng, công đức, xin lễ
- **Báo cáo thống kê**: theo độ tuổi, giới tính, bí tích, năm
- **In chứng chỉ PDF**: chứng chỉ Bí Tích, sổ in A4
- **Phân quyền**: cha xứ, cha phó, thư ký, ban hành giáo
- **Đa ngôn ngữ**: tiếng Việt (gốc) + dễ mở rộng tiếng Anh, La-tinh phụng vụ

Chi tiết: xem [`docs/feature-roadmap.md`](docs/feature-roadmap.md).

## Kiến trúc

```
┌─────────────────────────────────────────────┐
│  PC văn phòng giáo xứ (Windows/macOS)       │
│  ┌────────────┐    ┌──────────────────────┐ │
│  │ Flutter    │←──→│ PocketBase           │ │
│  │ Desktop    │    │ Server (binary ~30MB)│ │
│  └────────────┘    │ + SQLite (1 file)    │ │
│                    └──────────────────────┘ │
│                          ↑ HTTPS + SSE      │
└──────────────────────────┼──────────────────┘
                           │ LAN / Cloudflare Tunnel / Tailscale
                  ┌────────┴────────┐
                  ▼                 ▼
        ┌─────────────────┐ ┌──────────────────┐
        │ Flutter Android │ │ Flutter macOS    │
        │ (cha phó)       │ │ (giáo xứ con)    │
        └─────────────────┘ └──────────────────┘
```

- **Frontend**: Flutter 3.x — 1 codebase cho Win + Mac + Android + Linux + (iOS sau).
- **Backend**: [PocketBase](https://pocketbase.io/) — single Go binary, SQLite embed, REST + Realtime SSE, auth/users built-in, MIT.
- **Sync**: PocketBase Realtime subscriptions; mobile offline-first qua Hive cache, queue khi mất mạng.
- **Build**: GitHub Actions matrix → release `.exe`, `.dmg`, `.apk` mỗi tag.

Chi tiết: [`docs/system-architecture.md`](docs/system-architecture.md).

## Cài đặt nhanh (cho cha xứ)

> v1 chưa release — phần này sẽ cập nhật sau Phase 7 hoàn tất.

```bash
# 1. Tải PocketBase backend (Win/Mac/Linux 1 file)
curl -L https://github.com/VietCoders/real-church-manager/releases/latest/download/real-cm-server.zip -o server.zip
unzip server.zip && cd real-cm-server
./pocketbase serve --dir=./pb_data

# 2. Tải app desktop hoặc Android
# Win: real-cm-desktop-windows.exe
# macOS: real-cm-desktop-macos.dmg
# Android: real-cm-android.apk
```

## Phát triển

```bash
# Backend
cd backend
./pocketbase serve --dir=./pb_data --dev

# Flutter
cd apps/flutter_app
flutter pub get
flutter run -d windows   # hoặc macos / android / linux
```

Xem [`docs/data-model.md`](docs/data-model.md) cho schema 15+ collections.

## Đóng góp

Mọi đóng góp đều được chào đón. Đọc [`AGENTS.md`](AGENTS.md) cho quy tắc đặt tên, cấu trúc thư mục, và `maps/` workflow trước khi mở PR.

## Bản quyền

[MIT License](LICENSE). Copyright © 2026 Đạo Trần — RealDev — VietCoders Community.

## Cộng đồng

- Tác giả: **Đạo Trần** ([realdev.vn](https://realdev.vn))
- Cộng đồng: [VietCoders](https://github.com/VietCoders)
- Email: minhvinhdao.oc@gmail.com

---

*Phần mềm này được làm với mong muốn phục vụ Hội Thánh và các giáo xứ Việt Nam. Soli Deo gloria.*
