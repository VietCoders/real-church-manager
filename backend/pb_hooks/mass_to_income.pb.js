/// <reference path="../pb_data/types.d.ts" />
// Mass intention → Income: khi mass_intention.status chuyển sang 'done' VÀ donation_amount > 0,
// tự động tạo phiếu thu (donations type='mass_intention') để thống nhất tài chính.
// Idempotent: check meta linked_donation_id để không tạo trùng.

const _beforeStatus = new Map();

onRecordBeforeUpdateRequest((e) => {
  try {
    _beforeStatus.set(e.record.id, e.record.get('status') || '');
  } catch (_) {}
  e.next();
}, 'mass_intentions');

onRecordAfterUpdateRequest((e) => {
  try {
    const oldStatus = _beforeStatus.get(e.record.id) || '';
    _beforeStatus.delete(e.record.id);
    const newStatus = e.record.get('status') || '';
    if (oldStatus === newStatus) { e.next(); return; }
    if (newStatus !== 'done') { e.next(); return; }
    const amount = +(e.record.get('donation_amount') || 0);
    if (amount <= 0) { e.next(); return; }
    // Đã link rồi thì skip
    if (e.record.get('linked_donation_id')) { e.next(); return; }

    const dao = new Dao(e.app.dao().db());
    const donCol = dao.findCollectionByNameOrId('donations');
    const don = new Record(donCol);
    const massDate = e.record.get('mass_date');
    don.set('date', massDate ? new Date(massDate).toISOString().slice(0, 10) : new Date().toISOString().slice(0, 10));
    don.set('type', 'mass_intention');
    don.set('amount', amount);
    don.set('payment_method', 'cash');
    don.set('donor_name', e.record.get('requester_name') || 'Khuyết danh');
    don.set('description', `Lễ ý: ${e.record.get('intention_text') || ''}`.slice(0, 200));
    don.set('receipt_no', `LE-${e.record.id.slice(-6)}`);
    dao.saveRecord(don);

    // Lưu link để idempotent
    e.record.set('linked_donation_id', don.id);
    dao.saveRecord(e.record);

    console.log(`mass_to_income: tạo donation ${don.id} cho mass ${e.record.id}`);
  } catch (err) {
    console.log('mass_to_income err: ' + err);
  }
  e.next();
}, 'mass_intentions');
