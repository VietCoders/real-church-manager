/// <reference path="../pb_data/types.d.ts" />
// Auto sinh book_number theo format <PREFIX>-<YYYY>-<seq04> nếu user không nhập.
// PREFIX: RT (Rửa Tội), TS (Thêm Sức), HP (Hôn Phối), AT (An Táng).

const prefixMap = {
  sacrament_baptism: { prefix: 'RT', dateField: 'baptism_date' },
  sacrament_confirmation: { prefix: 'TS', dateField: 'confirmation_date' },
  sacrament_marriage: { prefix: 'HP', dateField: 'marriage_date' },
  sacrament_funeral: { prefix: 'AT', dateField: 'funeral_date' },
};

for (const colName of Object.keys(prefixMap)) {
  const cfg = prefixMap[colName];
  onRecordCreate((e) => {
    if (!e.record.get('book_number')) {
      const yr = yearOf(e.record.get(cfg.dateField)) || new Date().getFullYear();
      const seq = nextSeq(e.app, colName, cfg.prefix, yr);
      e.record.set('book_number', `${cfg.prefix}-${yr}-${pad4(seq)}`);
    }
    e.next();
  }, colName);
}

function yearOf(date) {
  if (!date) return null;
  const d = new Date(date);
  return isNaN(d) ? null : d.getFullYear();
}

function pad4(n) {
  return String(n).padStart(4, '0');
}

function nextSeq(app, colName, prefix, year) {
  const filter = `book_number ~ "${prefix}-${year}-"`;
  let max = 0;
  try {
    const records = app.findRecordsByFilter(colName, filter, '-book_number', 1, 0);
    if (records && records.length > 0) {
      const last = records[0].get('book_number');
      const m = last.match(/-(\d+)$/);
      if (m) max = parseInt(m[1], 10);
    }
  } catch (e) {
    console.log('nextSeq err:', e);
  }
  return max + 1;
}
