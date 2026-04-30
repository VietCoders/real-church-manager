/// <reference path="../pb_data/types.d.ts" />
// Validate member trước khi save — kiểm birth_date < death_date, format saint_name VN.

onRecordCreate((e) => {
  validateMember(e.record);
  e.next();
}, 'members');

onRecordUpdate((e) => {
  validateMember(e.record);
  e.next();
}, 'members');

function validateMember(rec) {
  const birth = rec.get('birth_date');
  const death = rec.get('death_date');
  if (birth && death) {
    const b = new Date(birth);
    const d = new Date(death);
    if (b.getTime() > d.getTime()) {
      throw new BadRequestError('Ngày sinh không thể sau ngày qua đời.', {
        birth_date: { code: 'invalid_date_range', message: 'Ngày sinh phải trước ngày qua đời.' },
      });
    }
  }
  // Format tên Thánh: viết hoa chữ đầu, cho phép dấu Việt + dấu nháy (vd "Phêrô", "Maria", "Ven Vân")
  const saint = (rec.get('saint_name') || '').trim();
  if (saint && saint.length > 100) {
    throw new BadRequestError('Tên Thánh quá dài (max 100 ký tự).');
  }
  // Auto-set status = deceased nếu có death_date
  if (death && rec.get('status') !== 'deceased') {
    rec.set('status', 'deceased');
  }
}
