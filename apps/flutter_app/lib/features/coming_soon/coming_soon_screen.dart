// Coming soon — placeholder consistent cho module chưa implement full CRUD.
// Hiển thị: icon + tiêu đề + danh sách tính năng dự kiến + roadmap version.
import 'package:flutter/material.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../ui/scaffold/app_shell.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.appBarTitle,
    required this.icon,
    required this.heading,
    required this.description,
    required this.features,
    this.targetVersion = 'v1.0',
  });

  final String appBarTitle;
  final IconData icon;
  final String heading;
  final String description;
  final List<String> features;
  final String targetVersion;

  @override
  Widget build(BuildContext context) {
    return RealCmAppShell(
      title: appBarTitle,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(RealCmSpacing.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(RealCmSpacing.s5),
                  decoration: BoxDecoration(
                    color: RealCmColors.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 56, color: RealCmColors.primary),
                ),
                const SizedBox(height: RealCmSpacing.s4),
                Text(
                  heading,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: RealCmSpacing.s2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: RealCmSpacing.s3, vertical: RealCmSpacing.s1),
                  decoration: BoxDecoration(
                    color: RealCmColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(RealCmRadius.full),
                  ),
                  child: Text(
                    'Đang phát triển · $targetVersion',
                    style: const TextStyle(fontSize: 12, color: RealCmColors.warning, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: RealCmSpacing.s4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: RealCmColors.textMuted, height: 1.5),
                ),
                const SizedBox(height: RealCmSpacing.s6),
                Container(
                  padding: const EdgeInsets.all(RealCmSpacing.s4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(RealCmRadius.lg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(RealCmIcons.info, size: 18, color: RealCmColors.info),
                          SizedBox(width: RealCmSpacing.s2),
                          Text('Tính năng dự kiến',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: RealCmSpacing.s3),
                      ...features.map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: RealCmSpacing.s2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(RealCmIcons.done, size: 16, color: RealCmColors.success),
                                ),
                                const SizedBox(width: RealCmSpacing.s2),
                                Expanded(child: Text(f, style: const TextStyle(fontSize: 14, height: 1.4))),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: RealCmSpacing.s4),
                Text(
                  'Đóng góp công sức, ý tưởng tại github.com/VietCoders/real-church-manager',
                  style: TextStyle(fontSize: 12, color: RealCmColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Catalog tất cả module chưa làm — config tập trung 1 chỗ.
class ComingSoonCatalog {
  ComingSoonCatalog._();

  static const Map<String, ComingSoonConfig> all = {
    '/families': ComingSoonConfig(
      title: 'Gia đình',
      icon: RealCmIcons.family,
      heading: 'Quản lý Gia đình',
      description: 'Quản lý hộ gia đình giáo xứ với gia trưởng, vợ/chồng, con cháu và cây gia phả.',
      features: [
        'Tạo/sửa/xoá gia đình với gia trưởng + vợ/chồng + con cháu',
        'Liên kết Member: chọn gia trưởng từ danh sách giáo dân',
        'Cây gia phả visual (tree view) cho 3 thế hệ',
        'Lịch sử thay đổi: ai vào gia đình khi nào, lý do',
        'Phân vùng theo giáo họ',
        'Xuất báo cáo danh sách gia đình theo giáo họ',
      ],
    ),
    '/sacrament/confirmation': ComingSoonConfig(
      title: 'Sổ Thêm Sức',
      icon: RealCmIcons.confirmation,
      heading: 'Sổ Thêm Sức (Confirmation)',
      description: 'Quản lý sổ Bí Tích Thêm Sức theo chuẩn giáo phận.',
      features: [
        'CRUD record Thêm Sức với số sổ tự động (TS-YYYY-NNNN)',
        'Liên kết giáo dân + đức Giám mục chủ sự + người đỡ đầu',
        'Tên Thánh Thêm Sức (có thể khác Tên Thánh Rửa Tội)',
        'Tự động cập nhật Member.confirmation_date',
        'In chứng chỉ Thêm Sức PDF A4 layout chuẩn VN',
        'Tìm kiếm theo số sổ, năm, tên người',
      ],
    ),
    '/sacrament/marriage': ComingSoonConfig(
      title: 'Sổ Hôn Phối',
      icon: RealCmIcons.marriage,
      heading: 'Sổ Hôn Phối (Marriage)',
      description: 'Quản lý sổ Bí Tích Hôn Phối với chú rể, cô dâu, người chứng và miễn chuẩn.',
      features: [
        'CRUD record Hôn Phối với số sổ tự động (HP-YYYY-NNNN)',
        'Liên kết 2 giáo dân (chú rể + cô dâu) + 2 người chứng',
        'Cha mẹ 2 bên + cha chủ sự',
        'Miễn chuẩn (kết hôn khác đạo, miễn chuẩn cản trở)',
        'Tự cập nhật spouse_id chéo cho cả 2 member',
        'In chứng chỉ Hôn Phối PDF A4',
      ],
    ),
    '/sacrament/anointing': ComingSoonConfig(
      title: 'Sổ Xức Dầu',
      icon: RealCmIcons.anointing,
      heading: 'Sổ Xức Dầu Bệnh Nhân',
      description: 'Ghi nhận lễ xức dầu bệnh nhân tại nhà, bệnh viện hoặc nhà thờ.',
      features: [
        'CRUD record Xức Dầu',
        'Tình trạng bệnh + nơi cử hành (nhà/bệnh viện/nhà thờ)',
        'Cha cử hành + ngày + giờ',
        'Lịch sử xức dầu cho mỗi giáo dân',
        'Gắn với hồ sơ giáo dân để theo dõi sức khoẻ',
      ],
    ),
    '/sacrament/funeral': ComingSoonConfig(
      title: 'Sổ An Táng',
      icon: RealCmIcons.funeral,
      heading: 'Sổ An Táng (Linh Hồn)',
      description: 'Sổ tử của giáo xứ — ghi nhận thông tin người qua đời và lễ an táng.',
      features: [
        'CRUD record An Táng với số sổ tự động (AT-YYYY-NNNN)',
        'Ngày qua đời + ngày an táng + nguyên nhân + nơi an táng',
        'Cha cử hành + thông tin tang lễ',
        'Tự động đặt Member.status = deceased + cập nhật death_date',
        'Tưởng niệm: lịch giỗ hằng năm cho thân nhân',
        'In chứng chỉ An Táng PDF',
      ],
    ),
    '/groups': ComingSoonConfig(
      title: 'Đoàn thể',
      icon: RealCmIcons.group,
      heading: 'Đoàn thể / Hội đoàn',
      description: 'Hội Mân Côi, Legio Mariæ, Thiếu Nhi Thánh Thể, Ca đoàn, Giới Trẻ, ...',
      features: [
        'CRUD đoàn thể + loại (hội/giới trẻ/ca đoàn/mục vụ)',
        'Trưởng hội + phó hội + thư ký + thủ quỹ',
        'Quản lý thành viên: thêm/xoá member + role + ngày gia nhập',
        'Lịch họp/sinh hoạt định kỳ',
        'Báo cáo số thành viên + độ tuổi trung bình + thay đổi theo năm',
        'In danh sách thành viên hội',
      ],
    ),
    '/mass': ComingSoonConfig(
      title: 'Lễ ý cầu nguyện',
      icon: RealCmIcons.mass,
      heading: 'Đăng ký Lễ ý',
      description: 'Quản lý lễ ý cầu nguyện do giáo dân xin (cầu cho linh hồn, tạ ơn, xin ơn).',
      features: [
        'Đăng ký lễ ý: tên người xin + ý chỉ + tiền dâng',
        'Cha xứ duyệt + xếp lịch lễ',
        'Lịch lễ ý theo ngày, tự nhắc khi đến lượt',
        'Trạng thái: chờ duyệt / đã xếp / đã cử hành / huỷ',
        'Báo cáo lễ ý đã thực hiện theo tháng/quý',
        'In phiếu xác nhận cho người xin',
      ],
    ),
    '/calendar': ComingSoonConfig(
      title: 'Lịch phụng vụ',
      icon: RealCmIcons.calendar,
      heading: 'Lịch Phụng Vụ',
      description: 'Lịch Mass hàng tuần, lễ trọng, mùa phụng vụ Công giáo.',
      features: [
        'Lịch Mass thứ 2-CN (giờ lễ, cha cử hành)',
        'Lễ trọng / lễ kính / lễ nhớ',
        'Màu phụng vụ: trắng/đỏ/xanh/tím/hồng/đen',
        'Mùa: Vọng, Giáng Sinh, Thường Niên, Chay, Phục Sinh',
        'Lễ bổn mạng giáo dân (sinh nhật Thánh)',
        'Đồng bộ với lịch Công giáo VN',
        'Export ICS để import vào Google/Apple Calendar',
      ],
    ),
    '/donations': ComingSoonConfig(
      title: 'Sổ thu chi',
      icon: RealCmIcons.donation,
      heading: 'Sổ Thu Chi',
      description: 'Ghi nhận dâng cúng Chúa Nhật, lễ trọng, công đức xây dựng, xin lễ.',
      features: [
        'CRUD thu/chi với loại (Chúa Nhật/lễ trọng/xây dựng/xin lễ/khác)',
        'Liên kết người dâng (cá nhân hoặc gia đình hoặc khuyết danh)',
        'Số phiếu thu duy nhất, in phiếu cảm tạ',
        'Báo cáo thu/chi theo tháng/quý/năm',
        'Biểu đồ xu hướng dâng cúng',
        'Export Excel cho ban hành giáo',
      ],
    ),
    '/reports': ComingSoonConfig(
      title: 'Báo cáo',
      icon: RealCmIcons.report,
      heading: 'Báo cáo Thống kê',
      description: '8+ loại báo cáo về tình hình giáo dân và sinh hoạt phụng vụ.',
      features: [
        'Số giáo dân theo độ tuổi (0-12, 13-18, 19-30, 31-60, 60+)',
        'Phân bổ theo giới tính + giáo họ',
        'Số bí tích trong năm: rửa tội, thêm sức, hôn phối, an táng',
        'Số người mất + sinh trong năm',
        'Top giáo dân tích cực (đăng ký lễ, dâng cúng nhiều)',
        'Báo cáo tài chính tổng',
        'Export PDF cho giáo phận / Excel cho cha xứ',
      ],
    ),
  };
}

class ComingSoonConfig {
  const ComingSoonConfig({
    required this.title,
    required this.icon,
    required this.heading,
    required this.description,
    required this.features,
    this.targetVersion = 'v1.0',
  });

  final String title;
  final IconData icon;
  final String heading;
  final String description;
  final List<String> features;
  final String targetVersion;
}
