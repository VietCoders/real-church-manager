/// <reference path="../pb_data/types.d.ts" />
// Auto backup hàng ngày 03:00 UTC. Tên: real-cm-auto-YYYYMMDD-HHmmss.zip
// Retention 04:00 UTC: giữ 7 file `real-cm-auto-*` mới nhất, xoá phần dư.

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

cronAdd('realCmBackupRetention', '0 4 * * *', () => {
  try {
    const fs = require(`${__hooks}/_noop.js`); // safe noop fallback
  } catch (_) {}
  try {
    // PB JSVM v0.22: liệt kê backups qua filesystem.
    const dataDir = $os.getenv('PB_DATA_DIR') || './pb_data';
    const backupsDir = dataDir + '/backups';
    let files;
    try {
      files = $os.readDir(backupsDir);
    } catch (_) {
      files = [];
    }
    if (!files || files.length === 0) return;
    // Filter chỉ auto backup
    const autos = [];
    for (const f of files) {
      const name = (f.name && f.name()) || '';
      if (!name.startsWith('real-cm-auto-')) continue;
      autos.push({ name, mtime: f.modTime ? f.modTime() : null });
    }
    if (autos.length <= 7) return;
    // Sắp xếp giảm dần theo tên (timestamp trong tên = sortable)
    autos.sort((a, b) => (a.name < b.name ? 1 : -1));
    const toDelete = autos.slice(7);
    for (const f of toDelete) {
      try {
        $os.remove(backupsDir + '/' + f.name);
        console.log('retention: deleted ' + f.name);
      } catch (e) {
        console.log('retention delete err ' + f.name + ': ' + e);
      }
    }
  } catch (e) {
    console.log('Backup retention err: ' + e);
  }
});
