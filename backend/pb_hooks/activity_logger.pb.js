/// <reference path="../pb_data/types.d.ts" />
// Activity logger — auto write activity_logs sau mỗi create/update/delete trên các collection nghiệp vụ.

const TRACKED = [
  'members',
  'families',
  'districts',
  'sacrament_baptism',
  'sacrament_confirmation',
  'sacrament_marriage',
  'sacrament_anointing',
  'sacrament_funeral',
  'donations',
  'mass_intentions',
  'groups',
  'liturgical_events',
  'parish_settings',
  'users',
];

function summarize(collection, record) {
  try {
    if (collection === 'members') {
      return `${record.get('saint_name') || ''} ${record.get('full_name') || ''}`.trim() || 'Giáo dân';
    }
    if (collection === 'families') return record.get('family_name') || 'Gia đình';
    if (collection === 'districts') return record.get('name') || 'Giáo họ';
    if (collection.startsWith('sacrament_')) {
      const num = record.get('book_number');
      return num ? `Số sổ ${num}` : collection;
    }
    if (collection === 'donations') {
      const amt = record.get('amount') || 0;
      return `${record.get('type') || 'Phiếu'} ${amt} đ`;
    }
    if (collection === 'mass_intentions') return record.get('intention_text') || 'Lễ ý';
    if (collection === 'groups') return record.get('name') || 'Đoàn thể';
    if (collection === 'liturgical_events') return record.get('title') || 'Sự kiện';
    if (collection === 'parish_settings') return 'Cấu hình giáo xứ';
    if (collection === 'users') return record.get('name') || record.get('username') || 'User';
  } catch (_) {}
  return collection;
}

// Cache trạng thái record trước update để diff
const _beforeCache = new Map();

function snapshotRecord(record) {
  try {
    const out = {};
    const data = record.publicExport ? record.publicExport() : {};
    for (const k of Object.keys(data)) {
      // Bỏ các field cồng kềnh hoặc auto
      if (['expand', 'collectionId', 'collectionName'].indexOf(k) >= 0) continue;
      out[k] = data[k];
    }
    return out;
  } catch (_) { return {}; }
}

function diffRecords(before, after) {
  const changes = {};
  const allKeys = new Set([...Object.keys(before || {}), ...Object.keys(after || {})]);
  for (const k of allKeys) {
    if (k === 'updated' || k === 'created') continue;
    const a = before ? before[k] : undefined;
    const b = after ? after[k] : undefined;
    const sa = JSON.stringify(a);
    const sb = JSON.stringify(b);
    if (sa !== sb) changes[k] = { from: a, to: b };
  }
  return changes;
}

function writeLog(app, op, collection, record, authId, changes) {
  try {
    const dao = new Dao(app.dao().db());
    const col = dao.findCollectionByNameOrId('activity_logs');
    const log = new Record(col);
    log.set('op', op);
    log.set('collection', collection);
    log.set('record_id', record.id);
    if (authId) log.set('user_id', authId);
    log.set('summary', `${op === 'create' ? '➕' : op === 'update' ? '✏️' : '🗑️'} ${summarize(collection, record)}`);
    const meta = { record_data: snapshotRecord(record) };
    if (changes && Object.keys(changes).length > 0) meta.changes = changes;
    log.set('meta', meta);
    dao.saveRecord(log);
  } catch (e) {
    console.log('activity_logger err: ' + e);
  }
}

for (const colName of TRACKED) {
  onRecordAfterCreateRequest((e) => {
    const auth = e.httpContext && e.httpContext.get('authRecord');
    writeLog(e.app, 'create', colName, e.record, auth ? auth.id : null);
    e.next();
  }, colName);

  onRecordAfterUpdateRequest((e) => {
    const auth = e.httpContext && e.httpContext.get('authRecord');
    writeLog(e.app, 'update', colName, e.record, auth ? auth.id : null);
    e.next();
  }, colName);

  onRecordAfterDeleteRequest((e) => {
    const auth = e.httpContext && e.httpContext.get('authRecord');
    writeLog(e.app, 'delete', colName, e.record, auth ? auth.id : null);
    e.next();
  }, colName);
}
