// Login screen — email + password + role hiển thị sau khi login.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../platform/pocketbase/auth.dart';
import '../../ui/toast/service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(realCmAuthProvider.notifier).login(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
    } catch (e) {
      if (mounted) {
        realCmToast(context, AppLocalizations.of(context)!.authLoginFailed, type: RealCmToastType.error);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(RealCmSpacing.s5),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(RealCmIcons.parish, size: 64, color: RealCmColors.primary),
                  const SizedBox(height: RealCmSpacing.s5),
                  Text(t.appTitle, textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: RealCmSpacing.s2),
                  Text(t.authLoginTitle, textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: RealCmSpacing.s6),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: t.authEmailLabel,
                      prefixIcon: const Icon(RealCmIcons.user),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? t.authEmailRequired : null,
                  ),
                  const SizedBox(height: RealCmSpacing.s3),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: t.authPasswordLabel,
                      prefixIcon: const Icon(RealCmIcons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? RealCmIcons.visibility : RealCmIcons.visibilityOff),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? t.authPasswordRequired : null,
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
                        : Text(t.authLoginButton),
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
