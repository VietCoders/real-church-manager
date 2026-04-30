// Connection screen — nhập backend URL trước khi login.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/icons.dart';
import '../../design/tokens.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../platform/pocketbase/auth.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController(text: 'http://127.0.0.1:8090');

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(realCmAuthProvider.notifier).setBackendUrl(_urlCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(RealCmSpacing.s5),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(RealCmIcons.wifi, size: 56, color: RealCmColors.primary),
                  const SizedBox(height: RealCmSpacing.s4),
                  Text(t.setupTitle, textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: RealCmSpacing.s3),
                  Text(t.setupDescription, textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: RealCmSpacing.s6),
                  TextFormField(
                    controller: _urlCtrl,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: t.setupBackendUrlLabel,
                      hintText: t.setupBackendUrlHint,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return t.setupInvalidUrl;
                      final uri = Uri.tryParse(v.trim());
                      if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
                        return t.setupInvalidUrl;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: RealCmSpacing.s5),
                  ElevatedButton(onPressed: _connect, child: Text(t.setupConnectButton)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
