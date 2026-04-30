# Data Model — Real Church Manager

> Schema 16 collections cho PocketBase. Source-of-truth: `packages/schema/collections.json`.

## Convention

- **Collection name**: snake_case (PocketBase default).
- **Field name**: snake_case.
- **Primary key**: PB tự sinh `id` (15-char base32). Không tự đặt.
- **Timestamp**: PB tự sinh `created`, `updated`.
- **Tham chiếu**: dùng `relation` field PB, lưu ID 15-char.
- **Soft delete**: thêm field `deleted_at` (nullable datetime) thay vì DELETE physical, để lịch sử sổ Bí Tích được giữ.

## ER Diagram (high-level)

```
users ──────────────────────┐
                            │ created_by, updated_by (audit)
                            ▼
parish_settings (1 record)
                            │
districts (giáo họ) ◄───────┐
   ▲                        │
   │ district_id            │
   │                        │
families ────► family_members ◄──── members
                                       ▲
                                       │ member_id
                  ┌────────────────────┤
                  │                    │
sacrament_baptism │  sacrament_confirmation
sacrament_marriage (link 2 members)
sacrament_anointing
sacrament_funeral
                  │
                  ▼
groups ──► group_members ◄── members
                  │
                  │ link member optional
                  ▼
mass_intentions
donations
liturgical_events (no member link)
```

## Collections

### 1. `users` (PB built-in, extended)

| Field | Type | Note |
|---|---|---|
| `id` | text (PK) | PB auto |
| `email` | email unique | đăng nhập |
| `password` | password | hash bcrypt |
| `name` | text | tên hiển thị |
| `role` | select | `priest_pastor` \| `priest_assistant` \| `secretary` \| `council_member` \| `guest` |
| `member_id` | relation→members | link nếu user cũng là giáo dân |
| `avatar` | file | optional |
| `verified` | bool | email verified |

**Rules**:
- `listRule`: `@request.auth.role = "priest_pastor"` (chỉ cha xứ liệt kê users)
- `viewRule`: `@request.auth.id != ""` (logged-in xem được info user khác trong cùng giáo xứ)
- `createRule`: `@request.auth.role = "priest_pastor"`
- `updateRule`: `@request.auth.id = id || @request.auth.role = "priest_pastor"`
- `deleteRule`: `@request.auth.role = "priest_pastor"`

### 2. `parish_settings`

Cấu hình giáo xứ (1 record duy nhất).

| Field | Type | Note |
|---|---|---|
| `name` | text required | "Giáo xứ Thánh Phêrô" |
| `address` | text | địa chỉ giáo xứ |
| `diocese` | text | giáo phận |
| `pastor_name` | text | tên cha xứ hiện tại |
| `phone` | text | |
| `email` | email | |
| `logo` | file | logo giáo xứ (in chứng chỉ) |
| `seal` | file | dấu giáo xứ (in chứng chỉ) |
| `founding_year` | number | năm thành lập |
| `patron_saint` | text | thánh bổn mạng giáo xứ |
| `feast_day` | date | ngày lễ bổn mạng |
| `notes` | editor | |

### 3. `districts` (Giáo họ / Giáo khu)

| Field | Type | Note |
|---|---|---|
| `name` | text required | "Giáo họ Thánh Giuse" |
| `code` | text | mã ngắn "GH-01" |
| `head_member_id` | relation→members | trưởng giáo họ |
| `address_zone` | text | mô tả vùng địa lý |
| `notes` | editor | |
| `deleted_at` | date | soft delete |

### 4. `members` (Giáo dân) — collection chính

| Field | Type | Note |
|---|---|---|
| `saint_name` | text | tên Thánh ("Phêrô", "Maria") |
| `full_name` | text required | họ tên đời ("Nguyễn Văn A") |
| `gender` | select | `male` \| `female` \| `other` |
| `birth_date` | date | ngày sinh |
| `birth_place` | text | nơi sinh |
| `death_date` | date | ngày qua đời (link với funeral) |
| `district_id` | relation→districts | giáo họ |
| `family_id` | relation→families | gia đình |
| `father_id` | relation→members | optional, nếu cha cũng trong hệ thống |
| `mother_id` | relation→members | optional |
| `father_name_text` | text | nếu cha không trong hệ thống |
| `mother_name_text` | text | tương tự |
| `spouse_id` | relation→members | optional |
| `phone` | text | |
| `email` | email | |
| `address` | text | địa chỉ riêng (nếu khác family) |
| `photo` | file | ảnh giáo dân |
| `id_number` | text | CCCD (encrypt nếu config) |
| `baptism_date` | date | derived từ sacrament_baptism, cache |
| `baptism_id` | relation→sacrament_baptism | |
| `confirmation_date` | date | derived |
| `confirmation_id` | relation→sacrament_confirmation | |
| `marriage_date` | date | derived |
| `marriage_id` | relation→sacrament_marriage | |
| `funeral_id` | relation→sacrament_funeral | |
| `notes` | editor | |
| `tags` | json | mảng tag tự do |
| `status` | select | `active` \| `moved_out` \| `deceased` \| `excommunicated` |
| `deleted_at` | date | |

### 5. `families` (Gia đình)

| Field | Type | Note |
|---|---|---|
| `family_name` | text | "Gia đình Phêrô Nguyễn Văn A" |
| `head_id` | relation→members required | gia trưởng |
| `district_id` | relation→districts | |
| `address` | text | |
| `phone` | text | điện thoại nhà |
| `notes` | editor | |
| `deleted_at` | date | |

### 6. `family_members` (junction)

| Field | Type | Note |
|---|---|---|
| `family_id` | relation→families required | |
| `member_id` | relation→members required | |
| `role` | select | `head` \| `spouse` \| `child` \| `parent` \| `sibling` \| `other` |
| `joined_date` | date | ngày vào gia đình (sinh ra hoặc kết hôn vào) |
| `left_date` | date | ngày rời (qua đời, lập gia đình riêng) |

### 7. `sacrament_baptism` (Sổ Rửa Tội)

| Field | Type | Note |
|---|---|---|
| `book_number` | text | số sổ "RT-2024-001" |
| `member_id` | relation→members required | người được rửa |
| `baptism_date` | date required | ngày rửa tội |
| `baptism_place` | text | "Nhà thờ giáo xứ XYZ" |
| `priest_name` | text required | cha rửa tội |
| `godfather_name` | text | cha đỡ đầu |
| `godmother_name` | text | mẹ đỡ đầu |
| `godfather_id` | relation→members | optional link nếu trong hệ thống |
| `godmother_id` | relation→members | optional |
| `father_name` | text | tên cha của người được rửa |
| `mother_name` | text | tên mẹ |
| `notes` | editor | |
| `attachment` | file[] | scan giấy chứng chỉ cũ |

### 8. `sacrament_confirmation` (Sổ Thêm Sức)

| Field | Type | Note |
|---|---|---|
| `book_number` | text | "TS-2024-001" |
| `member_id` | relation→members required | |
| `confirmation_date` | date required | |
| `confirmation_place` | text | |
| `bishop_name` | text required | đức Giám mục chủ sự |
| `confirmation_saint_name` | text | tên Thánh thêm sức (có thể khác saint_name) |
| `sponsor_name` | text | người đỡ đầu |
| `sponsor_id` | relation→members | optional |
| `notes` | editor | |
| `attachment` | file[] | |

### 9. `sacrament_marriage` (Sổ Hôn Phối)

| Field | Type | Note |
|---|---|---|
| `book_number` | text | "HP-2024-001" |
| `groom_id` | relation→members required | chồng |
| `bride_id` | relation→members required | vợ |
| `marriage_date` | date required | |
| `marriage_place` | text | |
| `priest_name` | text required | cha chủ sự |
| `groom_father_name` | text | |
| `groom_mother_name` | text | |
| `bride_father_name` | text | |
| `bride_mother_name` | text | |
| `witness_1_name` | text required | người chứng 1 |
| `witness_2_name` | text required | người chứng 2 |
| `witness_1_id` | relation→members | optional |
| `witness_2_id` | relation→members | optional |
| `dispensation` | text | miễn chuẩn (khác đạo, kết hôn ngoài đạo, ...) |
| `notes` | editor | |
| `attachment` | file[] | |

### 10. `sacrament_anointing` (Sổ Xức Dầu)

| Field | Type | Note |
|---|---|---|
| `member_id` | relation→members required | |
| `anointing_date` | date required | |
| `anointing_place` | text | (bệnh viện / nhà / nhà thờ) |
| `priest_name` | text required | |
| `condition` | text | tình trạng bệnh nhân |
| `notes` | editor | |

(Không có `book_number` vì xức dầu thường không lưu sổ chính thức ở nhiều giáo xứ. Có thể optional.)

### 11. `sacrament_funeral` (Sổ An Táng)

| Field | Type | Note |
|---|---|---|
| `book_number` | text | "AT-2024-001" |
| `member_id` | relation→members required | |
| `death_date` | date required | |
| `death_cause` | text | |
| `funeral_date` | date required | |
| `burial_place` | text | nghĩa trang |
| `priest_name` | text required | cha cử hành lễ an táng |
| `notes` | editor | |
| `attachment` | file[] | |

### 12. `groups` (Đoàn thể / Hội đoàn)

| Field | Type | Note |
|---|---|---|
| `name` | text required | "Hội Mân Côi" |
| `code` | text | "HMC" |
| `type` | select | `confraternity` \| `youth` \| `choir` \| `pastoral` \| `other` |
| `head_member_id` | relation→members | trưởng hội |
| `vice_head_member_id` | relation→members | phó hội |
| `founding_date` | date | |
| `meeting_schedule` | text | "Mỗi Chúa Nhật sau lễ 7h" |
| `notes` | editor | |
| `deleted_at` | date | |

### 13. `group_members` (junction)

| Field | Type | Note |
|---|---|---|
| `group_id` | relation→groups required | |
| `member_id` | relation→members required | |
| `role` | select | `head` \| `vice_head` \| `secretary` \| `treasurer` \| `member` |
| `joined_date` | date | |
| `left_date` | date | |
| `notes` | text | |

### 14. `mass_intentions` (Lễ ý cầu nguyện)

| Field | Type | Note |
|---|---|---|
| `intention_text` | text required | "Cầu cho linh hồn ông Phêrô" |
| `requester_name` | text required | tên người xin |
| `requester_member_id` | relation→members | optional |
| `mass_date` | date | ngày lễ dự kiến |
| `priest_id` | relation→users | cha cử hành |
| `donation_amount` | number | tiền dâng (VND) |
| `status` | select | `pending` \| `scheduled` \| `done` \| `cancelled` |
| `notes` | editor | |

### 15. `donations` (Sổ thu chi)

| Field | Type | Note |
|---|---|---|
| `date` | date required | ngày thu/chi |
| `type` | select | `sunday_offering` \| `feast_offering` \| `building_fund` \| `mass_intention` \| `other_in` \| `expense` |
| `amount` | number required | dương = thu, âm = chi |
| `currency` | text default `VND` | |
| `donor_name` | text | tên người dâng (có thể "Khuyết danh") |
| `donor_member_id` | relation→members | optional |
| `family_id` | relation→families | optional |
| `description` | text | |
| `receipt_no` | text | số phiếu thu |
| `notes` | editor | |

### 16. `liturgical_events` (Lịch phụng vụ)

| Field | Type | Note |
|---|---|---|
| `title` | text required | "Lễ Chúa Nhật Phục Sinh" |
| `event_date` | datetime required | |
| `end_date` | datetime | optional cho event nhiều ngày |
| `event_type` | select | `mass_regular` \| `mass_solemn` \| `mass_feast` \| `confession` \| `adoration` \| `meeting` \| `other` |
| `liturgical_color` | select | `white` \| `red` \| `green` \| `purple` \| `rose` \| `black` |
| `priest_name` | text | cha chủ sự dự kiến |
| `is_recurring` | bool | lễ định kỳ hằng tuần |
| `recurrence_rule` | text | RRULE format |
| `notes` | editor | |

## Indexes

PB tự index PK + relation field. Cần thêm:

- `members.full_name` (search) — text index
- `members.saint_name` — text
- `members.district_id` — index
- `members.status` — index
- `sacrament_*.book_number` — unique
- `sacrament_*.member_id` — index
- `liturgical_events.event_date` — index

## Validation hooks (PocketBase JSVM)

`backend/pb_hooks/`:

- `validate_member.js`: kiểm `birth_date < death_date`, format saint_name VN.
- `derived_member_dates.js`: khi tạo/update sacrament_baptism → cập nhật `members.baptism_date` + `baptism_id`.
- `auto_book_number.js`: tự sinh `book_number` theo format `<TYPE>-<YYYY>-<seq>`.
- `audit_log.js`: ghi mọi thay đổi vào `audit_logs` collection (sẽ thêm trong Phase 3).

## Migration version

Schema version: `v1.0.0`. Migration file naming: `20260430_<seq>_<description>.json` (PocketBase tự load theo thứ tự alphabet).
