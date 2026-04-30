## Mô tả

<!-- Tóm tắt thay đổi: feat/fix/refactor/docs. Tham chiếu issue nếu có (#123). -->

## Loại thay đổi

- [ ] feat: thêm tính năng mới
- [ ] fix: sửa lỗi
- [ ] refactor: tái cấu trúc không đổi behavior
- [ ] docs: chỉ docs/comment
- [ ] chore: build/CI/dep
- [ ] test: thêm/sửa test

## Maps compliance (BẮT BUỘC)

- [ ] Đã đọc `maps/tree.md` + `maps/functions.md` trước khi code
- [ ] Mọi function/class/hook MỚI có proposal approved trong `maps/proposals.md`
- [ ] `maps/tree.md` updated trong PR này (nếu có file mới)
- [ ] `maps/functions.md` updated trong PR này (nếu có symbol mới)
- [ ] `maps/touched.log` có dòng cho commit này

## Test plan

<!-- Bullet checklist: bạn đã test gì? -->

- [ ] Build Win/Mac/Android local pass (nếu chạm Flutter)
- [ ] PocketBase migrate up/down chạy sạch (nếu chạm schema)
- [ ] Manual smoke: tạo + sửa + xoá entity liên quan
- [ ] Realtime sync giữa 2 thiết bị (nếu liên quan sync)

## Screenshot / video (nếu UI)

<!-- Drag drop ảnh hoặc video minh hoạ thay đổi UI. -->

## Checklist

- [ ] Code tuân `AGENTS.md` naming convention (Concept/Role, file 1 từ snake_case, prefix `realCm`)
- [ ] i18n: source string tiếng Việt (qua `app_vi.arb`)
- [ ] KHÔNG `alert()/confirm()/prompt()` native, dùng `realCmModal/realCmToast/realCmConfirm`
- [ ] KHÔNG `<input>` thủ công, qua FieldRenderer (khi Phase 2.x scaffold xong)
- [ ] KHÔNG hardcode color/spacing — dùng `RealCmColors`/`RealCmSpacing`
- [ ] CHANGELOG.md có entry (nếu user-facing change)
