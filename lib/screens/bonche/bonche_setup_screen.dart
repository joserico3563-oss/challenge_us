import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../navigation/app_routes.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

enum _Step { choose, create, join, created }

/// Se muestra tras iniciar sesion cuando el usuario aun no tiene bonche.
class BoncheSetupScreen extends StatefulWidget {
  const BoncheSetupScreen({super.key});

  @override
  State<BoncheSetupScreen> createState() => _BoncheSetupScreenState();
}

class _BoncheSetupScreenState extends State<BoncheSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  _Step _step = _Step.choose;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _go(_Step step) {
    setState(() {
      _step = step;
      _error = null;
    });
  }

  void _enterMain() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.main);
  }

  Future<void> _logout() async {
    final app = AppScope.read(context);
    final navigator = Navigator.of(context);
    await app.signOut();
    navigator.pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.length < 3) {
      setState(() => _error = 'Ponle un nombre de al menos 3 letras.');
      return;
    }
    final app = AppScope.read(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await app.createGroup(
      name: name,
      description: _descriptionController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (error == null) {
        _step = _Step.created;
        WidgetsBinding.instance.addPostFrameCallback((_) => _openConfig());
      } else {
        _error = error;
      }
    });
  }

    Future<void> _openConfig() async {
    if (!mounted) return;
    await Navigator.of(context).pushNamed(
      AppRoutes.boncheConfig,
      arguments: true,
    );
  }

  Future<void> _join() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Escribe el código de invitación.');
      return;
    }
    final app = AppScope.read(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await app.joinGroup(code);
    if (!mounted) return;
    if (error == null) {
      _enterMain();
    } else {
      setState(() {
        _busy = false;
        _error = error;
      });
    }
  }

  Future<void> _copy(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: switch (_step) {
                _Step.choose => _buildChoose(),
                _Step.create => _buildCreate(),
                _Step.join => _buildJoin(),
                _Step.created => _buildCreated(),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, {Color color = AppColors.yellow}) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 42, color: color),
    );
  }

  Widget _errorText() {
    final error = _error;
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        error,
        textAlign: TextAlign.center,
        style: AppText.body.copyWith(color: AppColors.error),
      ),
    );
  }

  Widget _buildChoose() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _badge(Icons.groups_rounded),
        const SizedBox(height: 24),
        const Text(
          'Aún no estás en ningún bonche',
          textAlign: TextAlign.center,
          style: AppText.title,
        ),
        const SizedBox(height: 8),
        const Text(
          'Crea uno y comparte el código con tu parche, o únete al de un amigo.',
          textAlign: TextAlign.center,
          style: AppText.bodyMuted,
        ),
        const SizedBox(height: 36),
        PrimaryButton(
          label: 'Crear mi bonche',
          icon: Icons.add_rounded,
          onPressed: () => _go(_Step.create),
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Unirme con un código',
          icon: Icons.vpn_key_rounded,
          onPressed: () => _go(_Step.join),
        ),
        const SizedBox(height: 20),
        TextButton(onPressed: _logout, child: const Text('Cerrar sesión')),
      ],
    );
  }

  Widget _buildCreate() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Crea tu bonche', style: AppText.title),
        const SizedBox(height: 6),
        const Text(
          'Será privado: solo entra quien tenga tu código.',
          style: AppText.bodyMuted,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          maxLength: 40,
          decoration: ccInputDecoration(
            label: 'Nombre del bonche',
            icon: Icons.groups_rounded,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 2,
          maxLength: 120,
          decoration: ccInputDecoration(
            label: 'Descripción (opcional)',
            icon: Icons.notes_rounded,
          ),
        ),
        _errorText(),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Crear bonche',
          loading: _busy,
          onPressed: _create,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Volver',
          onPressed: _busy ? null : () => _go(_Step.choose),
        ),
      ],
    );
  }

  Widget _buildJoin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Únete a un bonche', style: AppText.title),
        const SizedBox(height: 6),
        const Text(
          'Pega el código que te compartió el líder del bonche.',
          style: AppText.bodyMuted,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _codeController,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _join(),
          decoration: ccInputDecoration(
            label: 'Código de invitación',
            icon: Icons.vpn_key_rounded,
          ),
        ),
        _errorText(),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Unirme', loading: _busy, onPressed: _join),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Volver',
          onPressed: _busy ? null : () => _go(_Step.choose),
        ),
      ],
    );
  }

  Widget _buildCreated() {
    final group = AppScope.of(context).group;
    final code = group?.inviteCode ?? '';
    final name = group?.name ?? 'tu bonche';
    final invitation =
        'Únete a mi bonche "$name" en La Recocha con el código $code';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: _badge(Icons.check_circle_rounded, color: AppColors.success)),
        const SizedBox(height: 24),
        const Text(
          '¡Tu bonche está listo!',
          textAlign: TextAlign.center,
          style: AppText.title,
        ),
        const SizedBox(height: 6),
        Text(name, textAlign: TextAlign.center, style: AppText.bodyMuted),
        const SizedBox(height: 24),
        CCCard(
          highlight: true,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('CÓDIGO DE INVITACIÓN', style: AppText.label),
              const SizedBox(height: 8),
              Text(
                code,
                style: AppText.display.copyWith(letterSpacing: 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Quien tenga este código puede unirse desde la app, aunque todavía no haya retos.',
          textAlign: TextAlign.center,
          style: AppText.bodyMuted,
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: 'Copiar invitación',
          icon: Icons.share_rounded,
          onPressed: () => _copy(invitation, 'Invitación copiada. ¡Pégala en tu chat!'),
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Copiar solo el código',
          icon: Icons.content_copy_rounded,
          onPressed: () => _copy(code, 'Código copiado.'),
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Entrar al bonche',
          icon: Icons.arrow_forward_rounded,
          onPressed: _enterMain,
        ),
      ],
    );
  }
}