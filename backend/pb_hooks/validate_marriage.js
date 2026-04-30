/// <reference path="../pb_data/types.d.ts" />
// Validate marriage — groom != bride, dates valid.

onRecordCreate((e) => { validateMarriage(e.record); e.next(); }, 'sacrament_marriage');
onRecordUpdate((e) => { validateMarriage(e.record); e.next(); }, 'sacrament_marriage');

function validateMarriage(rec) {
  const groom = rec.get('groom_id');
  const bride = rec.get('bride_id');
  if (groom && bride && groom === bride) {
    throw new BadRequestError('Chú rể và cô dâu không thể là cùng một người.');
  }
  const date = rec.get('marriage_date');
  if (date) {
    const m = new Date(date);
    const now = new Date();
    if (m.getTime() > now.getTime() + 365 * 24 * 60 * 60 * 1000) {
      throw new BadRequestError('Ngày hôn phối không thể quá xa trong tương lai.');
    }
  }
}
