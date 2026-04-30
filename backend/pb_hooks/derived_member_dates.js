/// <reference path="../pb_data/types.d.ts" />
// Auto-update member.<sacrament>_date + <sacrament>_id khi tạo/update sacrament record.
// Cập nhật ngược lại khi xoá để giữ data consistency.

const sacramentMap = {
  sacrament_baptism: { dateField: 'baptism_date', idField: 'baptism_id', sourceDate: 'baptism_date' },
  sacrament_confirmation: { dateField: 'confirmation_date', idField: 'confirmation_id', sourceDate: 'confirmation_date' },
  sacrament_marriage: { dateField: 'marriage_date', idField: 'marriage_id', sourceDate: 'marriage_date' },
  sacrament_funeral: { dateField: null, idField: 'funeral_id', sourceDate: 'death_date' },
};

for (const colName of Object.keys(sacramentMap)) {
  const cfg = sacramentMap[colName];

  onRecordAfterCreateSuccess((e) => {
    syncMemberFromSacrament(e.app, e.record, cfg, false);
    e.next();
  }, colName);

  onRecordAfterUpdateSuccess((e) => {
    syncMemberFromSacrament(e.app, e.record, cfg, false);
    e.next();
  }, colName);

  onRecordAfterDeleteSuccess((e) => {
    syncMemberFromSacrament(e.app, e.record, cfg, true);
    e.next();
  }, colName);
}

// Marriage: cập nhật cả groom + bride.
onRecordAfterCreateSuccess((e) => syncMarriagePair(e.app, e.record, false), 'sacrament_marriage');
onRecordAfterUpdateSuccess((e) => syncMarriagePair(e.app, e.record, false), 'sacrament_marriage');
onRecordAfterDeleteSuccess((e) => syncMarriagePair(e.app, e.record, true), 'sacrament_marriage');

// Funeral: set member.death_date + status=deceased.
onRecordAfterCreateSuccess((e) => syncFuneralToMember(e.app, e.record, false), 'sacrament_funeral');
onRecordAfterUpdateSuccess((e) => syncFuneralToMember(e.app, e.record, false), 'sacrament_funeral');

function syncMemberFromSacrament(app, rec, cfg, isDelete) {
  const memberId = rec.get('member_id');
  if (!memberId) return;
  try {
    const member = app.findRecordById('members', memberId);
    if (isDelete) {
      member.set(cfg.idField, '');
      if (cfg.dateField) member.set(cfg.dateField, null);
    } else {
      member.set(cfg.idField, rec.id);
      if (cfg.dateField) member.set(cfg.dateField, rec.get(cfg.sourceDate));
    }
    app.save(member);
  } catch (e) {
    console.log('syncMemberFromSacrament err:', e);
  }
}

function syncMarriagePair(app, rec, isDelete) {
  for (const role of ['groom_id', 'bride_id']) {
    const memberId = rec.get(role);
    if (!memberId) continue;
    try {
      const member = app.findRecordById('members', memberId);
      if (isDelete) {
        member.set('marriage_id', '');
        member.set('marriage_date', null);
      } else {
        member.set('marriage_id', rec.id);
        member.set('marriage_date', rec.get('marriage_date'));
        // Set spouse_id chéo
        const spouseId = role === 'groom_id' ? rec.get('bride_id') : rec.get('groom_id');
        if (spouseId) member.set('spouse_id', spouseId);
      }
      app.save(member);
    } catch (e) {
      console.log('syncMarriagePair err:', e);
    }
  }
}

function syncFuneralToMember(app, rec, isDelete) {
  const memberId = rec.get('member_id');
  if (!memberId) return;
  try {
    const member = app.findRecordById('members', memberId);
    member.set('funeral_id', rec.id);
    member.set('death_date', rec.get('death_date'));
    member.set('status', 'deceased');
    app.save(member);
  } catch (e) {
    console.log('syncFuneralToMember err:', e);
  }
}
