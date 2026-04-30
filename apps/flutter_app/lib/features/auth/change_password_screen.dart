// Change password screen — bắt buộc đổi mật khẩu khi must_change_password = true.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../platform/pocketbase/auth.dart';
import '../../ui/toast/service.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(realCmAuthProvider.notifier).changePassword(
            oldPassword: _oldCtrl.text,
            newPassword: _newCtrl.text,
          );
      if (mounted) {
        realCmToast(context, AppLocalizations.of(context)!.changePasswordSuccess,
            type: RealCmToastType.success);
      }
    } catch (e) {
      if (mounted) {
        realCmToast(context, AppLocalizations.of(context)!.changePasswordFailed,
            type: RealCmToastType.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.changePasswordTitle),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Padding(
            padding: const EdgeInsets.all(RealCmSpacing.s5),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(RealCmIcons.lock, size: 56, color: RealCmColors.primary),
                  const SizedBox(height: RealCmSpacing.s4),
                  Text(t.changePasswordHeading,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: RealCmSpacing.s3),
                  Text(t.changePasswordDescription,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: RealCmSpacing.s6),
                  TextFormField(
                    controller: _oldCtrl,
                    obscureText: _obscureOld,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: t.changePasswordOldLabel,
                      prefixIcon: const Icon(RealCmIcons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureOld ? RealCmIcons.visibility : RealCmIcons.visibilityOff),
                        onPressed: () => setState(() => _obscureOld = !_obscureOld),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? t.changePasswordOldRequired : null,
                  ),
                  const SizedBox(height: RealCmSpacing.s3),
                  TextFormField(
                    controller: _newCtrl,
                    obscureText: _obscureNew,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: t.changePasswordNewLabel,
                      prefixIcon: const Icon(RealCmIcons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? RealCmIcons.visibility : RealCmIcons.visibilityOff),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      helperText: t.changePasswordRules,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return t.changePasswordNewRequired;
                      if (v.length < 6) return t.changePasswordTooShort;
                      if (v == _oldCtrl.text) return t.changePasswordSameAsOld;
                      return null;
                    },
                  ),
                  const SizedBox(height: RealCmSpacing.s3),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: t.changePasswordConfirmLabel,
                      prefixIcon: const Icon(RealCmIcons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? RealCmIcons.visibility : RealCmIcons.visibilityOff),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return t.changePasswordConfirmRequired;
                      if (v != _newCtrl.text) return t.changePasswordConfirmMismatch;
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: RealCmSpacing.s5),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(t.changePasswordSubmit),
                  ),
                  const SizedBox(height: RealCmSpacing.s3),
                  TextButton(
                    onPressed: () async {
                      await ref.read(realCmAuthProvider.notifier).logout();
                    },
                    child: Text(t.authLogoutButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
