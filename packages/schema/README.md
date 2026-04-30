# Schema Package — Source of Truth

> Định nghĩa schema 16 collection cho PocketBase backend. **File này là source-of-truth duy nhất**. Backend migrations + Frontend Dart entities (qua codegen) đều derive từ đây.

## Files

- `collections.json` — PocketBase collections schema (import-able qua admin UI hoặc migration JSON)

## Sử dụng

### Import vào PocketBase (Phase 3)

```bash
# Cách 1: qua admin UI
# 1. Khởi động PocketBase: ./pocketbase serve
# 2. Mở http://localhost:8090/_/
# 3. Settings → Import collections → upload collections.json

# Cách 2: qua migration (recommended)
# Mỗi collection có file migration riêng trong backend/pb_migrations/
# Migration file generate từ collections.json bằng script
node scripts/schema-to-migrations.js  # (Phase 3 sẽ viết script này)
```

### Generate Dart entities (Phase 2)

```bash
# Từ collections.json → lib/domain/<concept>/entity.dart (Freezed)
dart run packages/schema/codegen.dart  # (Phase 2 sẽ viết)
```

## Convention

- Collection name: `snake_case`
- Field name: `snake_case`
- Field type: PocketBase types — `text`, `email`, `number`, `bool`, `date`, `select`, `relation`, `file`, `json`, `editor` (rich text)
- Required: theo PocketBase `required: true` trong field options
- Indexed: thêm `unique: true` hoặc dùng PB index API
- Soft delete: thêm field `deleted_at` (date, nullable) thay vì DELETE

## Schema version

Hiện tại: **v1.0.0** (Phase 1 — schema khởi tạo).

Mỗi thay đổi major (thêm/xoá collection, đổi field type) tăng version. Migration script sẽ skip nếu file đã import.

## Quan hệ

Xem `docs/data-model.md` cho ER diagram + mô tả từng collection.
