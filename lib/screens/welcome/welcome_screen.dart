import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../navigation/app_routes.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// Tras entrar: al inicio si ya tiene bonche; si no, a crear o unirse.
  void _enter(BuildContext context) {
    final app = AppScope.read(context);
    Navigator.of(context).pushReplacementNamed(
      app.group != null ? AppRoutes.main : AppRoutes.boncheSetup,
    );
  }

  void _openEmailSheet(BuildContext context) {
    // La hoja se cierra con `true` cuando el usuario entra o crea su cuenta.
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _EmailSheet(),
    ).then((success) {
      if (success == true && context.mounted) {
        _enter(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final busy = AppScope.of(context).authBusy;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 54,
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(height: 24),
              const Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(text: 'La '),
                    TextSpan(
                      text: 'Recocha',
                      style: TextStyle(color: AppColors.yellow),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pequeños retos. Grandes bonches.',
                style: AppText.heading,
              ),
              const SizedBox(height: 6),
              const Text(
                'Retos diarios entre amigos. Compite sano, ríe y gana con tu parche.',
                textAlign: TextAlign.center,
                style: AppText.bodyMuted,
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Continuar con correo',
                icon: Icons.mail_outline_rounded,
                loading: busy,
                onPressed: () => _openEmailSheet(context),
              ),
            ],
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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _register = false;
  bool _hidePassword = true;
  bool _busy = false;
  String? _error;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _nameController.dispose();
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

    final email = _emailController.text.trim();
    final ok = _register
        ? await app.registerWithEmail(
            email: email,
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
          )
        : await app.signInWithEmail(
            email: email,
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
            Text(
              _register ? 'Crea tu cuenta' : 'Entra con tu correo',
              style: AppText.title,
            ),
            const SizedBox(height: 6),
            Text(
              _register
                  ? 'Elige tu nombre, tu correo y una contraseña.'
                  : 'Usa tu correo y tu contraseña.',
              style: AppText.bodyMuted,
            ),
            const SizedBox(height: 20),
            if (_register) ...[
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: ccInputDecoration(
                  label: 'Tu nombre',
                  icon: Icons.person_outline_rounded,
                ),
                validator: (value) {
                  if ((value ?? '').trim().length < 2) return 'Escribe tu nombre';
                  return null;
                },
              ),
              const SizedBox(height: 14),
            ],
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
              label: _register ? 'Crear cuenta' : 'Entrar',
              loading: _busy,
              onPressed: _submit,
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                          _register = !_register;
                          _error = null;
                        }),
                child: Text(
                  _register
                      ? '¿Ya tienes cuenta? Entra'
                      : '¿Primera vez? Crea tu cuenta',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}