# Design System — Real Church Manager

> **Bắt buộc cho mọi contributor**: nguyên tắc nhất quán toàn app. Vi phạm = reject PR.

## Triết lý

1. **Một abstraction — nhiều consumer**: feedback (modal/toast/lightbox) dùng chung; field renderer dùng chung; icon mapping dùng chung.
2. **Token-only**: mọi giá trị thiết kế qua `RealCmColors`, `RealCmSpacing`, `RealCmRadius`, `RealCmTypography`, `RealCmDuration`, `RealCmShadows`, `RealCmZIndex`. CẤM hardcode.
3. **i18n-first**: mọi chuỗi user-facing qua `AppLocalizations.of(context)!.<key>`. Source string locale = `vi`. CẤM hardcode tiếng Việt trong code (trừ debug log).
4. **Có giao diện = có tính năng**: KHÔNG ship UI mock với button TODO. Mọi tương tác phải hoạt động end-to-end.
5. **Consistency = trust**: cùng action → cùng UI → cùng feedback. Save thành công luôn ra toast `success`. Xoá luôn qua confirm modal.

## Tokens (canonical)

Đặt tại `lib/design/tokens.dart`. Mọi widget import.

### Color

| Token | Hex | Mục đích |
|---|---|---|
| `RealCmColors.primary` | `#7C3AED` | Brand primary — tím phụng vụ |
| `RealCmColors.accent` | `#F59E0B` | Brand accent — vàng lễ trọng |
| `RealCmColors.info` | `#1D4ED8` | Info state · tượng trưng nam |
| `RealCmColors.success` | `#15803D` | Success state |
| `RealCmColors.danger` | `#DC2626` | Error · destructive · liturgical red |
| `RealCmColors.warning` | `#B45309` | Warning state |
| `RealCmColors.surface` | `#FFFFFF` | Card/dialog background |
| `RealCmColors.surfaceVariant` | `#F1F5F9` | Disabled bg, hover state |
| `RealCmColors.text` | `#0F172A` | Primary text |
| `RealCmColors.textMuted` | `#475569` | Secondary text |
| `RealCmColors.textDisabled` | `#94A3B8` | Disabled text only |
| `RealCmColors.overlay` | `rgba(15,23,42,.6)` | Modal backdrop |
| `RealCmColors.liturgicalWhite/Red/Green/Purple/Rose/Black` | varies | Mùa phụng vụ — chỉ dùng cho calendar |

### Spacing scale

`s1` = 4 · `s2` = 8 · `s3` = 12 · `s4` = 16 · `s5` = 24 · `s6` = 32 · `s8` = 48 (px)

CẤM padding/margin số khác (vd 13, 22). Phải dùng token.

### Radius

`sm` 6 · `md` 10 · `lg` 16 · `xl` 24 · `full` 9999

### Typography

`xs` 12 · `sm` 14 · `base` 16 · `lg` 18 · `xl` 20 · `xl2` 24 · `xl3` 30 (hero only)

1 màn hình ≤ 3 cấp text. Hero size chỉ cho landing/onboarding.

### Animation

`fast` 120ms · `normal` 200ms · `slow` 320ms · `hero` 500ms (chỉ landing/onboarding)

Easing: `RealCmEasing.standard = cubic-bezier(0.16, 1, 0.3, 1)`. CẤM bouncy/spring trừ user explicit.

### Z-index

dropdown 1000 · sticky 1020 · fixed 1030 · modalBackdrop 1040 · modal 1050 · toast 1060 · tooltip 1070

## Feedback abstractions

> **Mọi tương tác user → 1 trong 3 cấp feedback. CẤM `showDialog`/`SnackBar`/`alert` raw.**

### Toast — `realCmToast(context, message, type)`

| Khi dùng | Type |
|---|---|
| Lưu OK · upload xong · đăng nhập thành công | `success` (xanh) |
| Lỗi non-blocking (không tải được, ngăn submit) | `error` (đỏ) |
| Cảnh báo nhẹ (hết slot, sắp tới hạn) | `warning` (cam) |
| Info chung (đã copy link, đang đồng bộ...) | `info` (xanh dương) |

Auto-dismiss 4s. Bottom-floating, max width 600px. KHÔNG dùng cho action quan trọng cần confirm.

### Confirm modal — `realCmConfirm(context, title, body, danger)`

Dùng cho mọi action **destructive hoặc state-changing đáng kể**:
- Xoá record (danger=true → button đỏ)
- Đăng xuất (danger=false)
- Reset layout dashboard về mặc định
- Reset password user khác

Returns `Future<bool>`. KHÔNG bao giờ skip confirm cho destructive action.

### Modal — `realCmModal(context, title, body, buttons, size)`

Dùng cho:
- Form thêm/sửa entity (size `md` hoặc `lg`)
- Detail xem record (size `md`)
- Settings dialog (size `lg`)
- Multi-step wizard (size `lg` hoặc `fullscreen`)

Sizes: `sm` 400px · `md` 600px · `lg` 900px · `fullscreen`. Buttons style: `primary`/`secondary`/`ghost`/`danger`.

CẤM modal lồng modal >2 cấp — refactor sang multi-step wizard trong cùng 1 modal.

## Component patterns

### List screen pattern

Mọi list screen (member/family/sacrament/group/...) dùng cùng layout:

```
AppBar(title, actions: [refresh, search?, filter?, more])
SearchBar (if applicable)
ListView.separated với Divider height 1
  ListTile(leading: avatar/icon, title, subtitle, trailing: badge/chevron, onTap)
FloatingActionButton (chỉ user có quyền create)
```

Empty state: icon to + text "Chưa có dữ liệu" + button CTA.
Error state: icon error + text + button retry.

### Form screen pattern

```
AppBar(title: 'Thêm/Sửa <X>', actions: [save])
Form
  TextFormField/Dropdown/DatePicker với labelText i18n + validator
  spacing s3 giữa fields
  spacing s5 trước nút submit
ElevatedButton(submit)
TextButton(cancel)
```

CẤM `<input>` thủ công ngoài FieldRenderer (sẽ scaffold Phase 4).

### Detail screen pattern

```
AppBar(title: object name, actions: [edit, delete, more])
SingleChildScrollView
  Header: avatar/photo + name + subtitle
  Section: info chính (border + padding s4)
  Section: liên kết (sacraments, family members, ...)
ButtonBar / Actions ở bottom: edit, delete, print certificate (per role)
```

### Dashboard widget pattern

Tất cả widget dùng `DashboardWidgetShell` hoặc `DashboardStatsShell` từ `lib/features/dashboard/widgets/_shell.dart`. Cấu trúc:
- Border 1px outlineVariant
- Padding `s4`
- Header: icon trong rounded box (12% alpha của icon color) + title + actions
- Content: linh hoạt theo widget type

KHÔNG fork shell. Nếu cần variant → thêm prop vào shell.

## Icon system

Mọi icon qua `RealCmIcons.<name>` (semantic) — vd `RealCmIcons.member`, `RealCmIcons.baptism`. KHÔNG `Icons.person_outline` raw.

Khi cần icon mới: thêm vào `lib/design/icons.dart` với tên semantic, KHÔNG tên cụ thể (vd `RealCmIcons.delete` không `RealCmIcons.trashCan`).

## A11y baseline

- Mọi `IconButton` có `tooltip`.
- `TextFormField` có `labelText` (không placeholder thay label).
- Icon-only button có `tooltip` hoặc `Semantics(label: ...)`.
- Color không là info channel duy nhất — luôn pair icon + text cho status.
- `prefers-reduced-motion` được Flutter framework handle nếu OS bật.
- Touch target ≥48×48 logical px (Material 3 default).

## Ngôn ngữ

- Source: `lib/l10n/app_vi.arb` (tiếng Việt). LLM/dev viết string mới ở đây trước.
- Translation: `app_en.arb`. Update cùng commit khi thêm key mới.
- Key: `snake_case` namespace rõ — `member.form.full_name`, `dashboard.customize_title`.
- Plural: dùng ICU MessageFormat khi cần (`{count, plural, =0{Chưa có} =1{1 mục} other{# mục}}`).
- Domain glossary: xem `CLAUDE.md` (Catholic VN terminology).

## Anti-pattern (CẤM)

| Sai | Đúng |
|---|---|
| `padding: EdgeInsets.all(20)` | `padding: EdgeInsets.all(RealCmSpacing.s5)` |
| `color: Color(0xFF7C3AED)` | `color: RealCmColors.primary` |
| `Text('Lưu')` | `Text(t.commonSave)` |
| `showDialog(...)` | `realCmModal(...)` |
| `ScaffoldMessenger.of(ctx).showSnackBar(...)` | `realCmToast(ctx, msg, type)` |
| `Icons.person` | `RealCmIcons.member` |
| Modal lồng modal 3 cấp | Multi-step wizard 1 modal |
| `<input type=...>` thủ công | `FieldRenderer.render(schema)` (Phase 4) |
| Confirm xoá bằng toast | `realCmConfirm(...)` |

## Review checklist (PR)

- [ ] Không hardcode color/spacing/duration
- [ ] Mọi chuỗi user-facing qua i18n
- [ ] Action destructive qua `realCmConfirm`
- [ ] Action thành công ra `realCmToast` success
- [ ] Form qua FieldRenderer (Phase 4+) hoặc TextFormField với labelText
- [ ] Dashboard widget mới dùng `DashboardWidgetShell`
- [ ] List/Detail/Form pattern khớp standard trên
- [ ] Icon qua `RealCmIcons.*`
- [ ] Test trên macOS Release build pass

## Cross-reference

- `~/.claude/rules/ui-rules.md` — rule global ưu tiên cao nhất
- `apps/flutter_app/lib/design/tokens.dart` — token canonical
- `apps/flutter_app/lib/ui/{toast,modal}/service.dart` — feedback abstractions
- `apps/flutter_app/lib/design/icons.dart` — IconMap
