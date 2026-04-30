# Function Proposals — Real Church Manager

> Mọi function/class/hook/CSS root/JS event/DB key/option key MỚI phải qua block PROPOSE và **user approve TRƯỚC khi code**.

## Format

```
PROPOSE FUNCTION
- id: #N
- symbol: <FQN hoặc tên>
- signature: <args + return type>
- file: <path>
- reason: <vì sao cần>
- alternatives-checked: <maps/functions.md, framework API, template module đã check>
- side-effects: <hook emit / log / cache write / DB / network>
APPROVE? (y/n + comment)
```

## Pending

(none)

## Approved history

> Phase 1 chưa có function/class business mới. Foundation files (docs, schema, maps, license) không tạo Dart/Go symbol nên không cần proposal. Phase 2+ sẽ bắt đầu populate.

---

### Note cho Phase 2+

Khi scaffold Flutter và viết code thực thi, các nhóm symbol sau sẽ cần proposal trước khi tạo:

**Phase 2 (Flutter scaffold)**:
- `RealCmTokens` class (design tokens) — `lib/design/tokens.dart`
- `RealCmTheme` class (light/dark theme) — `lib/design/theme.dart`
- `RealCmIconMap` class — `lib/design/icons.dart`
- `PocketBaseClient` wrapper — `lib/platform/pocketbase/client.dart`
- `AuthService` — `lib/platform/pocketbase/auth.dart`
- `HiveAdapter` — `lib/platform/storage/adapter.dart`
- `realCmModal()` / `realCmToast()` / `realCmLightbox()` — `lib/ui/modal/service.dart`, `lib/ui/toast/service.dart`
- `FieldRenderer`, `FieldRegistry`, `FormBuilder` — `lib/ui/field/`, `lib/ui/form/`
- `realCmAppRouter` (go_router config) — `lib/app.dart`

**Phase 3 (PocketBase hooks)**:
- Hook `real_cm_member_created`
- Hook `real_cm_baptism_recorded`
- Hook `real_cm_marriage_recorded`
- Hook `real_cm_funeral_recorded`
- Hook `real_cm_book_number_generated`
- JS function `validateMember()`, `deriveMemberDates()`, `autoBookNumber()`, `auditLog()`

**Phase 4 (Member/Family/District)**:
- `MemberRepository`, `MemberService`, `MemberValidator`
- `FamilyRepository`, `FamilyService`, `FamilyTreeBuilder`
- `DistrictRepository`
- Riverpod providers: `memberListProvider`, `memberDetailProvider`, ...

**Phase 5 (Sacrament books)**:
- `BaptismRepository` + `BaptismCertificatePdfBuilder`
- `ConfirmationRepository` + ...
- `MarriageRepository` + ...
- `AnointingRepository`
- `FuneralRepository`
- Shared: `SacramentBookPrintService`

**Phase 6 (Group/Mass/Donation/Calendar/Report)**:
- `GroupRepository`, `MassIntentionRepository`, `DonationRepository`, `LiturgicalCalendarRepository`
- `ReportGenerator` + sub-class theo loại report

**Phase 7 (CI/CD)**:
- Không có Dart/Go symbol mới, chỉ workflow YAML.

→ Khi vào từng Phase, sẽ propose từng symbol với block format trên, không gộp.
