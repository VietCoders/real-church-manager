/// <reference path="../pb_data/types.d.ts" />
// Seed default admin user — chỉ tạo nếu chưa có user nào trong giáo xứ.
// Username: admin · Password: admin123 · role: priest_pastor · must_change_password: true.
// Sau khi đăng nhập lần đầu, user PHẢI đổi mật khẩu (xem flow Flutter app).

migrate((db) => {
  const dao = new Dao(db);
  const usersCol = dao.findCollectionByNameOrId('users');

  // Skip nếu đã có ít nhất 1 user.
  let count = 0;
  try {
    const records = dao.findRecordsByFilter('users', '', '', 1, 0);
    count = records.length;
  } catch (e) {
    count = 0;
  }
  if (count > 0) {
    console.log('seed_admin: bỏ qua, đã có ' + count + ' user');
    return;
  }

  const record = new Record(usersCol);
  record.set('username', 'admin');
  record.set('email', 'admin@parish.local');
  record.set('emailVisibility', false);
  record.set('verified', true);
  record.set('name', 'Quản trị giáo xứ');
  record.set('role', 'priest_pastor');
  record.set('must_change_password', true);
  record.setPassword('admin123');
  dao.saveRecord(record);
  console.log('seed_admin: tạo user mặc định admin/admin123 (force change password)');
}, (db) => {
  const dao = new Dao(db);
  try {
    const r = dao.findFirstRecordByData('users', 'username', 'admin');
    if (r) dao.deleteRecord(r);
  } catch (e) {}
});
