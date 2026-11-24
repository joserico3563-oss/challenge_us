import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../theme/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';

/// Configuracion del bonche: nombre, retos al dia, horas y duracion.
/// Se usa al crear el bonche (isSetup) y despues para editarlo.
class BoncheConfigScreen extends StatefulWidget {
  const BoncheConfigScreen({super.key, required this.isSetup});

  final bool isSetup;

  @override
  State<BoncheConfigScreen> createState() => _BoncheConfigScreenState();
}

class _BoncheConfigScreenState extends State<BoncheConfigScreen> {
  static const int _minWindow = 60;

  late final TextEditingController _name;
  late List<TimeOfDay> _times;
  int _count = 3;
  int _window = 90;
  bool _saving = false;
  String? _error;

  int get _maxWindow => 180 - (_count - 2) * 20;

  @override
  void initState() {
    super.initState();
    final group = AppScope.read(context).group;
    _name = TextEditingController(text: group?.name ?? '');
    if (group != null && group.configured && group.schedules.length >= 2) {
      _count = group.schedules.length.clamp(2, 5).toInt();
      _window = group.windowMinutes;
      _times = [
        for (final s in group.schedules.take(_count))
          TimeOfDay(hour: s.hour, minute: s.minute),
      ];
    } else {
      _times = _defaultTimes(_count);
    }
    _window = ((_window / 10).round() * 10)
        .clamp(_minWindow, _maxWindow)
        .toInt();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  static TimeOfDay _fromMinutes(int total) =>
      TimeOfDay(hour: total ~/ 60, minute: total % 60);

  static List<TimeOfDay> _defaultTimes(int count) {
    const first = 8 * 60;
    const last = 21 * 60;
    final step = (last - first) / (count - 1);
    return [
      for (var i = 0; i < count; i++)
        _fromMinutes(((first + step * i) / 15).round() * 15),
    ];
  }

  void _setCount(int count) {
    setState(() {
      _count = count;
      _times = _defaultTimes(count);
      _window = _window.clamp(_minWindow, _maxWindow).toInt();
      _error = null;
    });
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
      helpText: 'Hora de inicio del reto ${index + 1}',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _times[index] = picked;
      _error = null;
    });
  }

  String _endLabel(int index) {
    final end = _times[index].hour * 60 + _times[index].minute + _window;
    return '${two((end ~/ 60) % 24)}:${two(end % 60)}';
  }

  String? _validate() {
    if (_name.text.trim().length < 3) {
      return 'Ponle un nombre de al menos 3 letras.';
    }
    final mins = _times.map((t) => t.hour * 60 + t.minute).toList()..sort();
    for (var i = 0; i < mins.length - 1; i++) {
      if (mins[i] + _window > mins[i + 1]) {
        return 'Dos retos se cruzan. Sepáralos o acorta la duración.';
      }
    }
    if (mins.last + _window > 1440) {
      return 'El último reto debe terminar antes de medianoche.';
    }
    return null;
  }

  Future<void> _save() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }
    final app = AppScope.read(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final sorted = [..._times]
      ..sort(
        (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
      );
    final error = await app.saveGroupConfig(
      name: _name.text.trim(),
      challengesPerDay: _count,
      windowMinutes: _window,
      times: [for (final t in sorted) '${two(t.hour)}:${two(t.minute)}'],
    );
    if (!mounted) return;
    if (error == null) {
      if (!widget.isSetup) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listo. Los cambios aplican desde mañana.'),
          ),
        );
      }
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (app.group != null && !app.isLeader) {
      return RecochaScaffold(
        appBar: ccAppBar('Editar bonche'),
        body: const EmptyStateView(
          icon: Icons.lock_rounded,
          title: 'Solo el líder puede editar',
          message: 'Pídele al líder del bonche que cambie los horarios.',
        ),
      );
    }

    return RecochaScaffold(
      appBar: ccAppBar(
        widget.isSetup ? 'Configura tus retos' : 'Editar bonche',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          TextField(
            controller: _name,
            maxLength: 40,
            decoration: ccInputDecoration(
              label: 'Nombre del bonche',
              icon: Icons.groups_rounded,
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('Retos al día'),
          SegmentedTabs(
            labels: const ['2', '3', '4', '5'],
            selected: _count - 2,
            onChanged: (i) => _setCount(i + 2),
          ),
          const SizedBox(height: 8),
          Text(
            'Con $_count retos, cada uno puede durar hasta ${windowLabel(_maxWindow)}.',
            style: AppText.bodyMuted,
          ),
          const SizedBox(height: 24),
          const SectionTitle('Duración de cada reto'),
          CCCard(
            child: Column(
              children: [
                Text(windowLabel(_window), style: AppText.title),
                Slider(
                  value: _window.toDouble(),
                  min: _minWindow.toDouble(),
                  max: _maxWindow.toDouble(),
                  divisions: (_maxWindow - _minWindow) ~/ 10,
                  label: windowLabel(_window),
                  onChanged: (v) => setState(() {
                    _window = (v / 10).round() * 10;
                    _error = null;
                  }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(windowLabel(_minWindow), style: AppText.label),
                    Text(windowLabel(_maxWindow), style: AppText.label),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Hora de inicio de cada reto'),
          for (var i = 0; i < _count; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CCCard(
                onTap: () => _pickTime(i),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded, color: AppColors.yellow),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RETO ${i + 1}', style: AppText.label),
                          const SizedBox(height: 2),
                          Text(
                            '${two(_times[i].hour)}:${two(_times[i].minute)}',
                            style: AppText.heading,
                          ),
                          Text(
                            'Termina a las ${_endLabel(i)}',
                            style: AppText.bodyMuted,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),
          const Text(
            'Las horas son de tu zona horaria. Tus amigos en otros países las verán convertidas a su hora.',
            style: AppText.bodyMuted,
          ),
          if (!widget.isSetup) ...[
            const SizedBox(height: 6),
            const Text(
              'Los retos de hoy no se tocan: los cambios aplican desde mañana.',
              style: AppText.bodyMuted,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: AppText.body.copyWith(color: AppColors.error)),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: widget.isSetup ? 'Guardar y continuar' : 'Guardar cambios',
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
