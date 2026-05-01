/// <reference path="../pb_data/types.d.ts" />
// Sacrament → Member cross-update: khi tạo bản ghi Bí Tích, tự cập nhật field tương ứng
// trên record member để dashboard/list hiển thị nhanh không cần JOIN runtime.
// - sacrament_baptism → members.baptism_date + baptism_id
// - sacrament_confirmation → members.confirmation_date + confirmation_id
// - sacrament_marriage → members.marriage_date + marriage_id (cả groom + bride)
// - sacrament_anointing → không update member (có thể nhiều lần)
// - sacrament_funeral → members.death_date + funeral_id + status='deceased'

function safeSetMember(dao, memberId, fields) {
  if (!memberId) return;
  try {
    const m = dao.findRecordById('members', memberId);
    let dirty = false;
    for (const k of Object.keys(fields)) {
      const cur = m.get(k);
      const nv = fields[k];
      if (cur !== nv && nv !== undefined && nv !== null) {
        m.set(k, nv);
        dirty = true;
      }
    }
    if (dirty) dao.saveRecord(m);
  } catch (e) {
    console.log(`sacrament_member_sync: lỗi update member ${memberId}: ${e}`);
  }
}

onRecordAfterCreateRequest((e) => {
  try {
    const dao = new Dao(e.app.dao().db());
    const memberId = e.record.get('member_id');
    safeSetMember(dao, memberId, {
      baptism_date: e.record.get('baptism_date'),
      baptism_id: e.record.id,
    });
  } catch (err) { console.log('baptism sync err: ' + err); }
  e.next();
}, 'sacrament_baptism');

onRecordAfterCreateRequest((e) => {
  try {
    const dao = new Dao(e.app.dao().db());
    const memberId = e.record.get('member_id');
    safeSetMember(dao, memberId, {
      confirmation_date: e.record.get('confirmation_date'),
      confirmation_id: e.record.id,
    });
  } catch (err) { console.log('confirmation sync err: ' + err); }
  e.next();
}, 'sacrament_confirmation');

onRecordAfterCreateRequest((e) => {
  try {
    const dao = new Dao(e.app.dao().db());
    const groomId = e.record.get('groom_id');
    const brideId = e.record.get('bride_id');
    const date = e.record.get('marriage_date');
    safeSetMember(dao, groomId, { marriage_date: date, marriage_id: e.record.id, spouse_id: brideId });
    safeSetMember(dao, brideId, { marriage_date: date, marriage_id: e.record.id, spouse_id: groomId });
  } catch (err) { console.log('marriage sync err: ' + err); }
  e.next();
}, 'sacrament_marriage');

onRecordAfterCreateRequest((e) => {
  try {
    const dao = new Dao(e.app.dao().db());
    const memberId = e.record.get('member_id');
    safeSetMember(dao, memberId, {
      death_date: e.record.get('death_date'),
      funeral_id: e.record.id,
      status: 'deceased',
    });
  } catch (err) { console.log('funeral sync err: ' + err); }
  e.next();
}, 'sacrament_funeral');
