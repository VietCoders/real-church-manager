/// <reference path="../pb_data/types.d.ts" />
// Auto-sync junction family_members khi member.family_id đổi.
// Logic:
// - onRecordCreate(members): nếu có family_id → tạo junction (role=child default).
// - onRecordBeforeUpdate(members): cache family_id cũ.
// - onRecordAfterUpdate(members): nếu family_id đổi → set left_date cho junction cũ + tạo junction mới.

const _beforeFamily = new Map();

function findActiveJunction(dao, familyId, memberId) {
  try {
    const rs = dao.findRecordsByFilter('family_members',
      `family_id = "${familyId}" && member_id = "${memberId}" && left_date = null`, '', 1, 0);
    return rs.length > 0 ? rs[0] : null;
  } catch (_) { return null; }
}

onRecordAfterCreateRequest((e) => {
  try {
    const familyId = e.record.get('family_id');
    if (!familyId) { e.next(); return; }
    const dao = new Dao(e.app.dao().db());
    if (findActiveJunction(dao, familyId, e.record.id)) { e.next(); return; }
    const col = dao.findCollectionByNameOrId('family_members');
    const j = new Record(col);
    j.set('family_id', familyId);
    j.set('member_id', e.record.id);
    j.set('role', 'child');
    j.set('joined_date', new Date().toISOString().slice(0, 10));
    dao.saveRecord(j);
    console.log('family_member_sync: tạo junction cho member ' + e.record.id);
  } catch (err) {
    console.log('family_member_sync create err: ' + err);
  }
  e.next();
}, 'members');

onRecordBeforeUpdateRequest((e) => {
  try {
    _beforeFamily.set(e.record.id, e.record.get('family_id') || '');
  } catch (_) {}
  e.next();
}, 'members');

onRecordAfterUpdateRequest((e) => {
  try {
    const oldFid = _beforeFamily.get(e.record.id) || '';
    _beforeFamily.delete(e.record.id);
    const newFid = e.record.get('family_id') || '';
    if (oldFid === newFid) { e.next(); return; }
    const dao = new Dao(e.app.dao().db());
    // Set left_date cho junction cũ
    if (oldFid) {
      const oldJ = findActiveJunction(dao, oldFid, e.record.id);
      if (oldJ) {
        oldJ.set('left_date', new Date().toISOString().slice(0, 10));
        dao.saveRecord(oldJ);
      }
    }
    // Tạo junction mới
    if (newFid && !findActiveJunction(dao, newFid, e.record.id)) {
      const col = dao.findCollectionByNameOrId('family_members');
      const j = new Record(col);
      j.set('family_id', newFid);
      j.set('member_id', e.record.id);
      j.set('role', 'child');
      j.set('joined_date', new Date().toISOString().slice(0, 10));
      dao.saveRecord(j);
    }
    console.log(`family_member_sync: member ${e.record.id} chuyển từ ${oldFid} → ${newFid}`);
  } catch (err) {
    console.log('family_member_sync update err: ' + err);
  }
  e.next();
}, 'members');
