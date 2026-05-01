/// <reference path="../pb_data/types.d.ts" />
// Sample data seed — chỉ chạy nếu DB rỗng (chưa có giáo dân nào).
// Tạo: parish_settings + 3 districts + 5 families + 15 members + 1-2/sacrament + 5 mass + 10 donations.

migrate((db) => {
  const dao = new Dao(db);

  // Skip nếu đã có giáo dân
  let memberCount = 0;
  try {
    const ms = dao.findRecordsByFilter('members', '', '', 1, 0);
    memberCount = ms.length;
  } catch (e) {}
  if (memberCount > 0) {
    console.log('seed_sample: bỏ qua, đã có ' + memberCount + ' giáo dân');
    return;
  }

  // ─── parish_settings ─────────────────────────────────────
  try {
    const psCol = dao.findCollectionByNameOrId('parish_settings');
    const psList = dao.findRecordsByFilter('parish_settings', '', '', 1, 0);
    if (psList.length === 0) {
      const ps = new Record(psCol);
      ps.set('name', 'Giáo xứ Mẫu');
      ps.set('address', '123 Đường Phụng Vụ, Phường Hoà Bình, Quận 1, TP.HCM');
      ps.set('diocese', 'Tổng Giáo phận TP.HCM');
      ps.set('pastor_name', 'Lm. Phêrô Nguyễn Văn A');
      ps.set('phone', '028.1234.5678');
      ps.set('email', 'giaoxu@mau.local');
      dao.saveRecord(ps);
    }
  } catch (e) { console.log('seed parish_settings err: ' + e); }

  // ─── 3 districts ─────────────────────────────────────────
  const districtIds = ['rcm_d_thienloc', 'rcm_d_phuocthi', 'rcm_d_anhsang0'];
  const districtNames = ['Giáo họ Thiên Lộc', 'Giáo họ Phước Thịnh', 'Giáo họ Ánh Sáng'];
  const dsCol = dao.findCollectionByNameOrId('districts');
  for (let i = 0; i < 3; i++) {
    try {
      const r = new Record(dsCol);
      r.set('id', districtIds[i]);
      r.set('name', districtNames[i]);
      r.set('code', 'GH' + (i + 1));
      r.set('address', 'Khu vực ' + (i + 1));
      dao.saveRecord(r);
    } catch (e) { console.log('seed district ' + i + ': ' + e); }
  }

  // ─── 15 members ──────────────────────────────────────────
  const mCol = dao.findCollectionByNameOrId('members');
  const memberIds = [];
  const memberSeed = [
    { saint: 'Phêrô',  full: 'Nguyễn Văn An',     gender: 'male',   birth: '1965-03-15', dist: 0 },
    { saint: 'Maria',  full: 'Trần Thị Bình',     gender: 'female', birth: '1968-07-22', dist: 0 },
    { saint: 'Giuse',  full: 'Nguyễn Văn Cường',  gender: 'male',   birth: '1992-11-05', dist: 0 },
    { saint: 'Anna',   full: 'Nguyễn Thị Diệu',   gender: 'female', birth: '1995-04-18', dist: 0 },
    { saint: 'Phaolô', full: 'Lê Văn Em',         gender: 'male',   birth: '2010-01-30', dist: 0 },

    { saint: 'Gioan',  full: 'Phạm Văn Phúc',     gender: 'male',   birth: '1958-09-12', dist: 1 },
    { saint: 'Têrêsa', full: 'Phạm Thị Giang',    gender: 'female', birth: '1962-12-03', dist: 1 },
    { saint: 'Tôma',   full: 'Phạm Văn Hùng',     gender: 'male',   birth: '1990-06-20', dist: 1 },
    { saint: 'Maria',  full: 'Phạm Thị Inh',      gender: 'female', birth: '2002-08-14', dist: 1 },
    { saint: 'Phêrô',  full: 'Phạm Văn Khang',    gender: 'male',   birth: '2015-02-09', dist: 1 },

    { saint: 'Anrê',   full: 'Đỗ Văn Long',       gender: 'male',   birth: '1972-05-25', dist: 2 },
    { saint: 'Maria',  full: 'Đỗ Thị Mai',        gender: 'female', birth: '1975-10-08', dist: 2 },
    { saint: 'Giacôbê',full: 'Đỗ Văn Nam',        gender: 'male',   birth: '2000-03-17', dist: 2 },
    { saint: 'Anna',   full: 'Đỗ Thị Oanh',       gender: 'female', birth: '2008-12-29', dist: 2 },
    { saint: 'Stêphanô',full:'Đỗ Văn Phú',        gender: 'male',   birth: '2018-07-11', dist: 2 },
  ];

  for (let i = 0; i < memberSeed.length; i++) {
    const s = memberSeed[i];
    try {
      const r = new Record(mCol);
      const id = 'rcm_m_' + ('0000000' + i).slice(-7) + '00';
      r.set('id', id.slice(0, 15));
      r.set('saint_name', s.saint);
      r.set('full_name', s.full);
      r.set('gender', s.gender);
      r.set('birth_date', s.birth);
      r.set('district_id', districtIds[s.dist]);
      r.set('status', 'active');
      dao.saveRecord(r);
      memberIds.push(r.get('id'));
    } catch (e) { console.log('seed member ' + i + ': ' + e); }
  }

  // ─── 5 families ──────────────────────────────────────────
  const fCol = dao.findCollectionByNameOrId('families');
  const familySeed = [
    { name: 'Gia đình ô. Phêrô Nguyễn Văn An', head: 0, dist: 0, addr: '12 Đường Số 1', phone: '0901111001' },
    { name: 'Gia đình a. Giuse Nguyễn Văn Cường', head: 2, dist: 0, addr: '34 Đường Số 1', phone: '0901111002' },
    { name: 'Gia đình ô. Gioan Phạm Văn Phúc', head: 5, dist: 1, addr: '56 Đường Số 2', phone: '0902222001' },
    { name: 'Gia đình a. Tôma Phạm Văn Hùng', head: 7, dist: 1, addr: '78 Đường Số 2', phone: '0902222002' },
    { name: 'Gia đình ô. Anrê Đỗ Văn Long', head: 10, dist: 2, addr: '90 Đường Số 3', phone: '0903333001' },
  ];
  for (let i = 0; i < familySeed.length; i++) {
    const f = familySeed[i];
    try {
      const r = new Record(fCol);
      r.set('family_name', f.name);
      r.set('head_id', memberIds[f.head]);
      r.set('district_id', districtIds[f.dist]);
      r.set('address', f.addr);
      r.set('phone', f.phone);
      dao.saveRecord(r);
    } catch (e) { console.log('seed family ' + i + ': ' + e); }
  }

  // ─── 5 sacrament records (1 mỗi sổ) ──────────────────────
  try {
    const bapCol = dao.findCollectionByNameOrId('sacrament_baptism');
    const r = new Record(bapCol);
    r.set('book_number', 'RT-2024-0001');
    r.set('baptism_date', '2024-04-13');
    r.set('baptism_place', 'Nhà thờ giáo xứ');
    r.set('priest_name', 'Lm. Phêrô Nguyễn Văn A');
    r.set('member_id', memberIds[14]);
    r.set('father_name', 'Đỗ Văn Long');
    r.set('mother_name', 'Đỗ Thị Mai');
    r.set('godfather_name', 'Phạm Văn Hùng');
    r.set('godmother_name', 'Phạm Thị Giang');
    dao.saveRecord(r);
  } catch (e) { console.log('seed baptism: ' + e); }

  try {
    const conCol = dao.findCollectionByNameOrId('sacrament_confirmation');
    const r = new Record(conCol);
    r.set('book_number', 'TS-2024-0001');
    r.set('confirmation_date', '2024-05-26');
    r.set('confirmation_place', 'Nhà thờ giáo xứ');
    r.set('bishop_name', 'ĐGM Giuse Đỗ Mạnh Hùng');
    r.set('member_id', memberIds[8]);
    r.set('confirmation_saint_name', 'Maria');
    r.set('sponsor_name', 'Phạm Thị Giang');
    dao.saveRecord(r);
  } catch (e) { console.log('seed confirmation: ' + e); }

  try {
    const marCol = dao.findCollectionByNameOrId('sacrament_marriage');
    const r = new Record(marCol);
    r.set('book_number', 'HP-2024-0001');
    r.set('marriage_date', '2024-08-17');
    r.set('marriage_place', 'Nhà thờ giáo xứ');
    r.set('priest_name', 'Lm. Phêrô Nguyễn Văn A');
    r.set('groom_id', memberIds[2]);
    r.set('bride_id', memberIds[3]);
    r.set('groom_father_name', 'Nguyễn Văn An');
    r.set('groom_mother_name', 'Trần Thị Bình');
    r.set('bride_father_name', 'Nguyễn Văn An');
    r.set('bride_mother_name', 'Trần Thị Bình');
    r.set('witness_1_name', 'Phaolô Lê Văn Em');
    r.set('witness_2_name', 'Maria Đỗ Thị Mai');
    dao.saveRecord(r);
  } catch (e) { console.log('seed marriage: ' + e); }

  try {
    const anCol = dao.findCollectionByNameOrId('sacrament_anointing');
    const r = new Record(anCol);
    r.set('anointing_date', '2024-11-02');
    r.set('priest_name', 'Lm. Phêrô Nguyễn Văn A');
    r.set('anointing_place', 'Bệnh viện Chợ Rẫy');
    r.set('member_id', memberIds[5]);
    r.set('condition', 'Bệnh nặng, già yếu');
    dao.saveRecord(r);
  } catch (e) { console.log('seed anointing: ' + e); }

  try {
    const fnCol = dao.findCollectionByNameOrId('sacrament_funeral');
    const r = new Record(fnCol);
    r.set('book_number', 'AT-2024-0001');
    r.set('priest_name', 'Lm. Phêrô Nguyễn Văn A');
    r.set('member_id', memberIds[5]);
    r.set('death_date', '2024-11-10');
    r.set('funeral_date', '2024-11-12');
    r.set('death_cause', 'Bệnh tuổi già');
    r.set('burial_place', 'Nghĩa trang giáo xứ');
    dao.saveRecord(r);
  } catch (e) { console.log('seed funeral: ' + e); }

  // ─── 5 mass intentions ───────────────────────────────────
  try {
    const miCol = dao.findCollectionByNameOrId('mass_intentions');
    const intentions = [
      { req: 'Anna Trần Thị Bình', text: 'Cầu cho linh hồn ông Phêrô', status: 'done', date: '2024-11-15', amt: 200000 },
      { req: 'Giuse Nguyễn Văn Cường', text: 'Tạ ơn Chúa nhân dịp 25 năm hôn phối', status: 'scheduled', date: '2025-01-15', amt: 500000 },
      { req: 'Maria Đỗ Thị Mai', text: 'Xin ơn bình an cho gia đình', status: 'pending', date: '', amt: 100000 },
      { req: 'Tôma Phạm Văn Hùng', text: 'Cầu cho con đỗ đại học', status: 'pending', date: '', amt: 150000 },
      { req: 'Khuyết danh', text: 'Cầu cho các đẳng linh hồn nơi luyện ngục', status: 'done', date: '2024-11-02', amt: 300000 },
    ];
    for (const it of intentions) {
      const r = new Record(miCol);
      r.set('requester_name', it.req);
      r.set('intention_text', it.text);
      r.set('status', it.status);
      if (it.date) r.set('mass_date', it.date);
      r.set('donation_amount', it.amt);
      dao.saveRecord(r);
    }
  } catch (e) { console.log('seed mass_intentions: ' + e); }

  // ─── 10 donations (8 thu + 2 chi) ────────────────────────
  try {
    const dnCol = dao.findCollectionByNameOrId('donations');
    const donations = [
      { date: '2024-11-03', type: 'sunday_offering', amount: 1500000, donor: 'Cộng đoàn', desc: 'Dâng Chúa Nhật 03/11', no: 'PT-001' },
      { date: '2024-11-10', type: 'sunday_offering', amount: 1800000, donor: 'Cộng đoàn', desc: 'Dâng Chúa Nhật 10/11', no: 'PT-002' },
      { date: '2024-11-17', type: 'sunday_offering', amount: 1650000, donor: 'Cộng đoàn', desc: 'Dâng Chúa Nhật 17/11', no: 'PT-003' },
      { date: '2024-11-24', type: 'sunday_offering', amount: 2100000, donor: 'Cộng đoàn', desc: 'Dâng Chúa Nhật 24/11', no: 'PT-004' },
      { date: '2024-11-01', type: 'feast_offering', amount: 3200000, donor: 'Cộng đoàn', desc: 'Lễ Các Thánh', no: 'PT-005' },
      { date: '2024-11-15', type: 'building_fund', amount: 5000000, donor: 'Ô. bà Phêrô An', desc: 'Quỹ tu sửa nhà thờ', no: 'PT-006' },
      { date: '2024-11-20', type: 'mass_intention', amount: 500000, donor: 'A. Giuse Cường', desc: 'Lễ tạ ơn', no: 'PT-007' },
      { date: '2024-11-25', type: 'other_in', amount: 1000000, donor: 'Khuyết danh', desc: 'Hỗ trợ giáo họ Phước Thịnh', no: 'PT-008' },
      { date: '2024-11-05', type: 'expense',  amount: 800000,  donor: 'Cty Điện lực', desc: 'Tiền điện T10/2024', no: 'PC-001' },
      { date: '2024-11-12', type: 'expense',  amount: 2500000, donor: 'Cửa hàng VPP', desc: 'Mua nến + sách lễ', no: 'PC-002' },
    ];
    for (const d of donations) {
      const r = new Record(dnCol);
      r.set('date', d.date);
      r.set('type', d.type);
      r.set('amount', d.amount);
      r.set('donor_name', d.donor);
      r.set('description', d.desc);
      r.set('receipt_no', d.no);
      dao.saveRecord(r);
    }
  } catch (e) { console.log('seed donations: ' + e); }

  console.log('seed_sample: hoàn tất — 3 giáo họ, 15 giáo dân, 5 gia đình, 5 bí tích, 5 lễ ý, 10 phiếu thu chi');
}, (db) => {
  // Down: best-effort cleanup. Không strict.
  console.log('seed_sample: down (no-op)');
});
