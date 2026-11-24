import '../../widgets/glass_card.dart';

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
      backgroundColor: const Color(0xF5101D30),
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
      backgroundColor: const Color(0xFF101D30),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/larecocha/backgrounds/1erapantalla.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),

          const ColoredBox(color: Color(0x40000000)),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(flex: 3),

                          Image.asset(
                            'assets/larecocha/branding/larechocha.png',
                            width: 220,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 12),

                          GlassCard(
                            opacity: 0.10,
                            blur: 3,
                            radius: 28,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 22,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Stack(
                                    children: [
                                      Text(
                                        'La Recocha',
                                        style: TextStyle(
                                          fontFamily: 'LilitaOne',
                                          fontSize: 52,
                                          letterSpacing: -1,
                                          foreground: Paint()
                                            ..style = PaintingStyle.stroke
                                            ..strokeWidth = 6
                                            ..strokeJoin = StrokeJoin.round
                                            ..color = const Color(0xFF101D30),
                                        ),
                                      ),
                                      const Text.rich(
                                        TextSpan(
                                          style: TextStyle(
                                            fontFamily: 'LilitaOne',
                                            fontSize: 52,
                                            letterSpacing: -1,
                                            color: Colors.white,
                                          ),
                                          children: [
                                            TextSpan(text: 'La '),
                                            TextSpan(
                                              text: 'Recocha',
                                              style: TextStyle(
                                                color: AppColors.yellow,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Pequeños retos. Grandes bonches.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Retos diarios entre amigos. Compite sano, ríe y gana con tu parche.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFF2F5FA),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(flex: 4),

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
              },
            ),
          ),
        ],
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
                  if ((value ?? '').trim().length < 2)
                    return 'Escribe tu nombre';
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
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
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
              Text(
                _error!,
                style: AppText.body.copyWith(color: AppColors.error),
              ),
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



