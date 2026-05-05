import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehbien_lotto_admin/core/utils/validators.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_colors.dart';
import 'package:ehbien_lotto_admin/shared/theme/app_spacing.dart';
import 'package:ehbien_lotto_admin/features/auth/presentation/providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});
  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    final err = await ref.read(authNotifierProvider.notifier).signIn(email: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (err != null && mounted) setState(() => _error = err);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;
    return Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), validator: Validators.email, enabled: !isLoading),
      const SizedBox(height: AppSpacing.md),
      TextFormField(
        controller: _passCtrl, obscureText: _obscure,
        decoration: InputDecoration(labelText: 'Mot de passe', prefixIcon: const Icon(Icons.lock_outlined), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscure = !_obscure))),
        validator: Validators.password, enabled: !isLoading,
        onFieldSubmitted: (_) => _submit(),
      ),
      if (_error != null) ...[
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.danger.withOpacity(0.4))),
          child: Row(children: [const Icon(Icons.error_outline, color: AppColors.danger, size: 16), const SizedBox(width: 8), Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)))]),
        ),
      ],
      const SizedBox(height: AppSpacing.lg),
      SizedBox(height: 48, child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Se connecter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      )),
    ]));
  }
}
