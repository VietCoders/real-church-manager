# Function Inventory — Real Church Manager

> Anti-duplicate registry. Mọi function/class/hook/event MỚI phải qua PROPOSE block trong `maps/proposals.md` trước khi viết.

> **Status**: Phase 1 (Foundation). Chưa có code thực thi. Sẽ populate dần qua Phase 2-7.

## Conventions

- **Dart top-level fn**: `realCm<Name>` camelCase nếu cần expose, ưu tiên đặt trong class/namespace folder.
- **Dart class**: 1 từ Role (vd `Repository`) trong namespace folder (`data/member/repository.dart` → class `MemberRepository`). Có thể dùng class name = Role-only nếu folder context rõ.
- **PocketBase hook event** (do project emit): `real_cm_<event>`.
- **Stream/event key**: `real-cm:<event>`.
- **Hive box name**: `real-cm:<purpose>`.

---

## Core utilities (Phase 2 sẽ populate)

| Symbol | Signature | File | Notes |
|---|---|---|---|
| _(none yet)_ | | | |

## Design tokens

| Symbol | Signature | File | Notes |
|---|---|---|---|
| _(none yet)_ | | | |

## PocketBase client

| Symbol | Signature | File | Notes |
|---|---|---|---|
| _(none yet)_ | | | |

## Member module

| Symbol | Signature | File | Notes |
|---|---|---|---|
| _(none yet)_ | | | |

## Family module

| Symbol | Signature | File | Notes |
|---|---|---|---|
| _(none yet)_ | | | |

## Sacrament modules (Baptism, Confirmation, Marriage, Anointing, Funeral)

| Symbol | Signature | File | Notes |
|---|---|---|---|
| _(none yet)_ | | | |

## Group / Mass / Donation / Calendar / Report

| Symbol | Signature | File | Notes |
|---|---|---|---|
| _(none yet)_ | | | |

---

## PocketBase hooks emitted (do project)

| Hook | Emit by | Args | Notes |
|---|---|---|---|
| _(none yet)_ | | | Phase 3 sẽ thêm: `real_cm_member_created`, `real_cm_baptism_recorded`, `real_cm_marriage_recorded`, ... |

## Events (Dart stream / Riverpod)

| Event | Emit by | Payload | Notes |
|---|---|---|---|
| _(none yet)_ | | | Phase 2-4 sẽ thêm: `real-cm:realtime:members`, `real-cm:auth:login`, `real-cm:offline:queue:flushed`, ... |

## Hive boxes

| Box | Stores | Notes |
|---|---|---|
| _(none yet)_ | | Phase 2 sẽ thêm: `real-cm:cache:members`, `real-cm:cache:families`, `real-cm:offline:queue`, `real-cm:auth:session` |

---

## Update protocol

Sau mỗi task có function/class mới được approve qua `proposals.md`:

1. Thêm dòng vào section tương ứng ở trên.
2. Append `maps/touched.log`.
3. Commit cùng code change.
