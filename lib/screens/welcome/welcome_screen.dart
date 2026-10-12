import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../navigation/app_routes.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _loginWithGoogle(BuildContext context) async {
    final app = AppScope.read(context);
    final ok = await app.signInWithGoogle();
    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.authError ?? 'No pudimos iniciar sesión.')),
      );
    }
  }

  Future<void> _openEmailSheet(BuildContext context) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _EmailSheet(),
    );
    if (ok == true && context.mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = AppScope.of(context).authBusy;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: 88, vertical: true),
                  const SizedBox(height: 24),
                  const Text(
                    'Pequeños retos. Grandes bonches.',
                    textAlign: TextAlign.center,
                    style: AppText.heading,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Retos diarios entre amigos. Compite sano, ríe y gana con tu parche.',
                    textAlign: TextAlign.center,
                    style: AppText.bodyMuted,
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    label: 'Continuar con Google',
                    icon: Icons.login_rounded,
                    loading: busy,
                    onPressed: () => _loginWithGoogle(context),
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Continuar con correo',
                    icon: Icons.mail_outline_rounded,
                    onPressed: busy ? null : () => _openEmailSheet(context),
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

class _EmailSheet extends StatefulWidget {
  const _EmailSheet();

  @override
  State<_EmailSheet> createState() => _EmailSheetState();
}

class _EmailSheetState extends State<_EmailSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _busy = false;
  String? _error;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final app = AppScope.read(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await app.signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _busy = false;
        _error = app.authError ?? 'No pudimos iniciar sesión.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Entra con tu correo', style: AppText.title),
            const SizedBox(height: 6),
            const Text('Usa tu correo y una contraseña.', style: AppText.bodyMuted),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: ccInputDecoration(
                label: 'Correo electrónico',
                icon: Icons.mail_outline_rounded,
              ),
              validator: (value) {
                final text = (value ?? '').trim();
                if (text.isEmpty) return 'Escribe tu correo';
                if (!_emailPattern.hasMatch(text)) return 'Correo no válido';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: ccInputDecoration(
                label: 'Contraseña',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if ((value ?? '').length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: AppText.body.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Entrar',
              loading: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}