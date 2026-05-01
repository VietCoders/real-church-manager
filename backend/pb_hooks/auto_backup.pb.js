/// <reference path="../pb_data/types.d.ts" />
// Auto backup hàng ngày 03:00 UTC. Tên: real-cm-auto-YYYYMMDD-HHmmss.zip
// Retention 7 file: PB JSVM v0.22 không có API list+delete backup tự động;
// admin có thể xoá tay trong settings/backups, hoặc dùng cron OS riêng.

cronAdd('realCmDailyBackup', '0 3 * * *', () => {
  try {
    const now = new Date();
    const pad = (n) => (n < 10 ? '0' + n : '' + n);
    const ts = now.getUTCFullYear()
      + pad(now.getUTCMonth() + 1)
      + pad(now.getUTCDate())
      + '-'
      + pad(now.getUTCHours())
      + pad(now.getUTCMinutes())
      + pad(now.getUTCSeconds());
    const name = `real-cm-auto-${ts}.zip`;
    $app.createBackup($app.newRequestEvent(), name);
    console.log('Auto backup created: ' + name);
  } catch (e) {
    console.log('Auto backup err: ' + e);
  }
});
