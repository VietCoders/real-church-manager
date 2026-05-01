// Onboarding wizard — first-run sau login đầu tiên (priest_pastor, parish_settings rỗng).
// 3 bước: Tên giáo xứ + Địa chỉ → Cha xứ + Liên hệ → Hoàn tất.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../platform/pocketbase/client.dart';
import '../../ui/toast/service.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});
  @override
  ConsumerState<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends ConsumerState<OnboardingWizardScreen> {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: 'Giáo xứ ');
  final _address = TextEditingController();
  final _diocese = TextEditingController();
  final _pastor = TextEditingController(text: 'Lm. ');
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _diocese.dispose();
    _pastor.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final pb = RealCmPocketBase.instance();
      // Check exists
      final existing = await pb.collection('parish_settings').getList(page: 1, perPage: 1);
      final body = {
        'name': _name.text.trim(),
        'address': _address.text.trim(),
        'diocese': _diocese.text.trim(),
        'pastor_name': _pastor.text.trim(),
        'phone': _phone.text.trim(),
        'email': _email.text.trim(),
      };
      if (existing.items.isEmpty) {
        await pb.collection('parish_settings').create(body: body);
      } else {
        await pb.collection('parish_settings').update(existing.items.first.id, body: body);
      }
      if (mounted) {
        realCmToast(context, 'Đã lưu cấu hình giáo xứ. Chào mừng bạn!', type: RealCmToastType.success);
        context.go('/');
      }
    } catch (e) {
      if (mounted) realCmToast(context, 'Lỗi: $e', type: RealCmToastType.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(RealCmSpacing.s5),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(RealCmIcons.parish, size: 64, color: RealCmColors.primary),
                  const SizedBox(height: RealCmSpacing.s4),
                  const Text('Chào mừng tới Real Church Manager',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: RealCmSpacing.s2),
                  Text(
                    _step == 0
                        ? 'Bước 1/3 — Thông tin giáo xứ'
                        : _step == 1
                            ? 'Bước 2/3 — Cha xứ & liên hệ'
                            : 'Bước 3/3 — Hoàn tất',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: RealCmColors.textMuted),
                  ),
                  const SizedBox(height: RealCmSpacing.s2),
                  LinearProgressIndicator(value: (_step + 1) / 3),
                  const SizedBox(height: RealCmSpacing.s5),
                  if (_step == 0) ..._step1(),
                  if (_step == 1) ..._step2(),
                  if (_step == 2) _step3Summary(),
                  const SizedBox(height: RealCmSpacing.s5),
                  Row(children: [
                    if (_step > 0)
                      OutlinedButton(
                        onPressed: _saving ? null : () => setState(() => _step--),
                        child: const Text('← Quay lại'),
                      ),
                    const Spacer(),
                    if (_step < 2)
                      ElevatedButton(
                        onPressed: _saving ? null : () {
                          if (_step == 0 && _name.text.trim().isEmpty) {
                            realCmToast(context, 'Vui lòng nhập tên giáo xứ', type: RealCmToastType.warning);
                            return;
                          }
                          setState(() => _step++);
                        },
                        child: const Text('Tiếp theo →'),
                      )
                    else
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: Text(_saving ? 'Đang lưu...' : 'Hoàn tất'),
                        onPressed: _saving ? null : _submit,
                      ),
                  ]),
                  const SizedBox(height: RealCmSpacing.s2),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Bỏ qua — cấu hình sau'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _step1() => [
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Tên giáo xứ *', helperText: 'Vd: Giáo xứ Tân Bình'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
        ),
        const SizedBox(height: RealCmSpacing.s3),
        TextFormField(
          controller: _address,
          decoration: const InputDecoration(labelText: 'Địa chỉ', helperText: 'Số nhà, đường, quận/huyện, tỉnh/thành phố'),
          maxLines: 2,
        ),
        const SizedBox(height: RealCmSpacing.s3),
        TextFormField(
          controller: _diocese,
          decoration: const InputDecoration(labelText: 'Giáo phận', helperText: 'Vd: Tổng Giáo phận TP.HCM'),
        ),
      ];

  List<Widget> _step2() => [
        TextFormField(
          controller: _pastor,
          decoration: const InputDecoration(labelText: 'Cha xứ', helperText: 'Vd: Lm. Phêrô Nguyễn Văn A'),
        ),
        const SizedBox(height: RealCmSpacing.s3),
        TextFormField(
          controller: _phone,
          decoration: const InputDecoration(labelText: 'Điện thoại'),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: RealCmSpacing.s3),
        TextFormField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
      ];

  Widget _step3Summary() {
    return Container(
      padding: const EdgeInsets.all(RealCmSpacing.s4),
      decoration: BoxDecoration(
        color: RealCmColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(RealCmRadius.md),
        border: Border.all(color: RealCmColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Xác nhận thông tin', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: RealCmSpacing.s2),
        _row('Tên', _name.text),
        if (_address.text.isNotEmpty) _row('Địa chỉ', _address.text),
        if (_diocese.text.isNotEmpty) _row('Giáo phận', _diocese.text),
        if (_pastor.text.isNotEmpty) _row('Cha xứ', _pastor.text),
        if (_phone.text.isNotEmpty) _row('SĐT', _phone.text),
        if (_email.text.isNotEmpty) _row('Email', _email.text),
        const SizedBox(height: RealCmSpacing.s2),
        const Text('Có thể chỉnh sửa sau trong "Cấu hình giáo xứ".',
            style: TextStyle(fontSize: 12, color: RealCmColors.textMuted)),
      ]),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, color: RealCmColors.textMuted))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ]),
      );
}
