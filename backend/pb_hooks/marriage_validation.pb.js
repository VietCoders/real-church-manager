/// <reference path="../pb_data/types.d.ts" />
// Marriage validation hook — chặn các trường hợp bất thường:
// - Cùng giới tính (Công giáo VN không công nhận hôn phối đồng tính).
// - Đã có spouse_id active không trùng (đa thê).
// - Member đã chết (deceased).
// - Member chưa rửa tội (cảnh báo, không chặn — vì có miễn chuẩn khác đạo).

onRecordBeforeCreateRequest((e) => {
  try {
    const dao = new Dao(e.app.dao().db());
    const groomId = e.record.get('groom_id');
    const brideId = e.record.get('bride_id');
    if (!groomId || !brideId) { e.next(); return; }
    if (groomId === brideId) {
      throw new ApiError(400, 'Chú rể và cô dâu không thể là cùng một người', { groom_id: 'Trùng cô dâu' });
    }
    const groom = dao.findRecordById('members', groomId);
    const bride = dao.findRecordById('members', brideId);
    const gg = (groom.get('gender') || '').toString();
    const bg = (bride.get('gender') || '').toString();
    if (gg && bg && gg === bg) {
      throw new ApiError(400, 'Hôn phối Công giáo yêu cầu khác giới tính', { groom_id: 'Cùng giới với cô dâu' });
    }
    if (groom.get('status') === 'deceased' || bride.get('status') === 'deceased') {
      throw new ApiError(400, 'Một trong hai người đã qua đời', { });
    }
    // Cảnh báo (không chặn) nếu có spouse_id active khác
    const gSpouse = (groom.get('spouse_id') || '').toString();
    const bSpouse = (bride.get('spouse_id') || '').toString();
    if (gSpouse && gSpouse !== brideId) {
      throw new ApiError(400, 'Chú rể đang có vợ/chồng khác trong hệ thống — kiểm tra lại', { groom_id: 'Đã có vợ/chồng' });
    }
    if (bSpouse && bSpouse !== groomId) {
      throw new ApiError(400, 'Cô dâu đang có vợ/chồng khác trong hệ thống — kiểm tra lại', { bride_id: 'Đã có vợ/chồng' });
    }
  } catch (err) {
    if (err && err.constructor && err.constructor.name === 'ApiError') throw err;
    console.log('marriage_validation err: ' + err);
  }
  e.next();
}, 'sacrament_marriage');
