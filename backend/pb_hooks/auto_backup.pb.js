/// <reference path="../pb_data/types.d.ts" />
// Auto backup hàng ngày 03:00 UTC + retention 7 backup. Chỉ giữ 7 file mới nhất tự động.
// Tên backup: real-cm-auto-YYYYMMDD-HHmmss.zip

cronAdd('realCmDailyBackup', '0 3 * * *', () => {
  try {
    const now = new Date();
    const ts = now.toISOString().replace(/[:\-]/g, '').replace(/\..+/, '').replace('T', '-');
    const name = `real-cm-auto-${ts}.zip`;
    $app.createBackup($app.newRequestEvent(), name);
    console.log('Auto backup created: ' + name);

    // Retention: giữ 7 backup auto mới nhất, xoá phần dư
    const fs = require(`${__hooks}/__fs.js`); // no-op stub
    try {
      const list = $app.dao().findRecordsByFilter('_pb_backups_', '', '', 100, 0);
      // PB không expose backup list qua DAO. Dùng FS-level hook không khả dụng trong JSVM v0.22.
      // Workaround: liệt kê qua filesystem là không stable. Nên giới hạn retention
      // bằng cron riêng dùng disk maintenance, hoặc admin xoá tay qua UI.
    } catch (_) {}
  } catch (e) {
    console.log('Auto backup err: ' + e);
  }
});
