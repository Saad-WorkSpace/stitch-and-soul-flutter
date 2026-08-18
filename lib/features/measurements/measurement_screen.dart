import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/tokens.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/cart_notifier.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/responsive.dart';

/// Bounds for body measurements, in cm. Used both for validation and for
/// the "How to measure" copy. These are generous and inclusive.
class MeasurementBounds {
  static const Map<String, (double, double)> cm = <String, (double, double)>{
    'bust': (60, 160),
    'waist': (50, 140),
    'hips': (60, 170),
    'shoulder': (28, 60),
    'sleeve': (40, 80),
    'inseam': (55, 95),
    'height': (130, 210),
  };
}

/// Pure validation that takes the entered value in the chosen unit and
/// returns an error string or null. This is exposed at the top level
/// because tests target it directly.
String? validateMeasurement({
  required String field,
  required double? rawValue,
  required UnitSystem units,
}) {
  if (rawValue == null) return null;
  final cm = units == UnitSystem.cm ? rawValue : rawValue * 2.54;
  final bounds = MeasurementBounds.cm[field];
  if (bounds == null) return null;
  if (cm < bounds.$1 || cm > bounds.$2) {
    final inUnit = units == UnitSystem.cm
        ? '${bounds.$1.toStringAsFixed(0)}–${bounds.$2.toStringAsFixed(0)} cm'
        : '${(bounds.$1 / 2.54).toStringAsFixed(1)}–${(bounds.$2 / 2.54).toStringAsFixed(1)} in';
    return 'Please enter a value between $inUnit.';
  }
  return null;
}

class MeasurementScreen extends ConsumerStatefulWidget {
  const MeasurementScreen({super.key, this.productSlug});
  final String? productSlug;

  @override
  ConsumerState<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends ConsumerState<MeasurementScreen> {
  int _step = 0;
  late MeasurementProfile _profile;
  bool _saveProfileConsent = false;
  final Map<String, TextEditingController> _ctrls =
      <String, TextEditingController>{};
  final Map<String, String?> _errors = <String, String?>{};

  static const _steps = <String>[
    'Welcome',
    'Units',
    'Body',
    'Fit',
    'Notes',
    'Review',
  ];

  @override
  void initState() {
    super.initState();
    // Preload any saved profile.
    final repo = ref.read(measurementsRepositoryProvider);
    _profile = repo.load() ?? const MeasurementProfile(units: UnitSystem.cm);

    for (final f in MeasurementBounds.cm.keys) {
      _ctrls[f] = TextEditingController(text: _formatField(f, _profile));
    }
  }

  String? _formatField(String field, MeasurementProfile p) {
    double? cm;
    switch (field) {
      case 'bust':
        cm = p.bustCm;
        break;
      case 'waist':
        cm = p.waistCm;
        break;
      case 'hips':
        cm = p.hipsCm;
        break;
      case 'shoulder':
        cm = p.shoulderCm;
        break;
      case 'sleeve':
        cm = p.sleeveCm;
        break;
      case 'inseam':
        cm = p.inseamCm;
        break;
      case 'height':
        cm = p.heightCm;
        break;
    }
    if (cm == null) return null;
    final v = p.units == UnitSystem.cm ? cm : cm / 2.54;
    return v.toStringAsFixed(p.units == UnitSystem.cm ? 1 : 2);
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(productRepositoryProvider);
    final product =
        widget.productSlug != null ? repo.bySlug(widget.productSlug!) : null;

    return SingleChildScrollView(
      child: SsPageScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: SsSpace.lg),
            SsSectionHeading(
              eyebrow: 'Made to measure',
              title: 'A guided measurement form',
              subtitle: product != null
                  ? 'For your ${product.name} commission.'
                  : 'A short, calm form — five steps.',
            ),
            const SizedBox(height: SsSpace.lg),
            _Stepper(step: _step, steps: _steps),
            const SizedBox(height: SsSpace.xl),
            SsResponsive(
              builder: (context, device) {
                final isWide = device != SsDevice.phone;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SsFlexItem(
                      expand: isWide,
                      flex: 7,
                      child: _stepBody(context, product),
                    ),
                    SizedBox(
                      width: isWide ? SsSpace.xxl : 0,
                      height: isWide ? 0 : SsSpace.xl,
                    ),
                    SsFlexItem(
                      expand: isWide,
                      flex: 4,
                      child: const _HelpPanel(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: SsSpace.xxl),
          ],
        ),
      ),
    );
  }

  Widget _stepBody(BuildContext context, Product? product) {
    switch (_step) {
      case 0:
        return _WelcomeStep(onStart: () => setState(() => _step = 1));
      case 1:
        return _UnitsStep(
          units: _profile.units,
          onChanged: (u) {
            setState(() {
              _profile = _profile.copyWith(units: u);
              // Re-format existing values into the new unit.
              for (final f in MeasurementBounds.cm.keys) {
                _ctrls[f]!.text = _formatField(f, _profile) ?? '';
              }
            });
          },
          onNext: () => setState(() => _step = 2),
        );
      case 2:
        return _BodyStep(
          units: _profile.units,
          controllers: _ctrls,
          errors: _errors,
          onValidate: _validateAllBody,
          onBack: () => setState(() => _step = 1),
          onNext: () {
            if (_validateAllBody()) {
              setState(() => _step = 3);
            }
          },
        );
      case 3:
        return _FitStep(
          current: _profile.fit,
          onChanged: (f) =>
              setState(() => _profile = _profile.copyWith(fit: f)),
          onBack: () => setState(() => _step = 2),
          onNext: () => setState(() => _step = 4),
        );
      case 4:
        return _NotesStep(
          notes: _profile.notes ?? '',
          onChanged: (n) =>
              setState(() => _profile = _profile.copyWith(notes: n)),
          saveConsent: _saveProfileConsent,
          onConsentChanged: (v) => setState(() => _saveProfileConsent = v),
          onBack: () => setState(() => _step = 3),
          onNext: () => setState(() => _step = 5),
        );
      case 5:
        return _ReviewStep(
          profile: _profile,
          controllers: _ctrls,
          onBack: () => setState(() => _step = 4),
          onJump: (i) => setState(() => _step = i),
          onAddToCart: () async {
            // Persist (only if consent) and add a measurement-attached cart line.
            if (_saveProfileConsent) {
              await ref.read(measurementsRepositoryProvider).save(_profile);
            }
            if (product != null) {
              ref.read(_addingProvider.notifier).state = true;
              ref.read(cartProvider.notifier).addLine(
                    CartLine(
                      productId: product.id,
                      size: 'MTM',
                      colorName: 'As photographed',
                      quantity: 1,
                      madeToMeasure: true,
                      measurements: _profile,
                      notes: _profile.notes,
                    ),
                  );
              ref.read(_addingProvider.notifier).state = false;
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: SsColors.ink,
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    'Added to cart with your measurements.',
                    style: TextStyle(color: SsColors.ivory),
                  ),
                ),
              );
              context.go('/cart');
            } else {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: SsColors.ink,
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    'Profile saved to this device (consent).',
                    style: TextStyle(color: SsColors.ivory),
                  ),
                ),
              );
              context.go('/services');
            }
          },
          product: product,
        );
    }
    return const SizedBox.shrink();
  }

  /// Returns true if all body fields are valid (or empty). Empty fields
  /// are allowed at every step except the review.
  bool _validateAllBody() {
    bool ok = true;
    final parsed = <String, double?>{};
    final nextErrors = <String, String?>{};
    for (final f in MeasurementBounds.cm.keys) {
      final raw = double.tryParse(_ctrls[f]!.text.trim());
      final err = validateMeasurement(
        field: f,
        rawValue: raw,
        units: _profile.units,
      );
      parsed[f] = raw == null
          ? null
          : (_profile.units == UnitSystem.cm ? raw : raw * 2.54);
      nextErrors[f] = err;
      if (err != null) ok = false;
    }
    setState(() {
      _errors
        ..clear()
        ..addAll(nextErrors);
      if (ok) {
        _profile = MeasurementProfile(
          units: _profile.units,
          bustCm: parsed['bust'],
          waistCm: parsed['waist'],
          hipsCm: parsed['hips'],
          shoulderCm: parsed['shoulder'],
          sleeveCm: parsed['sleeve'],
          inseamCm: parsed['inseam'],
          heightCm: parsed['height'],
          fit: _profile.fit,
          notes: _profile.notes,
        );
      }
    });
    return ok;
  }
}

final _addingProvider = StateProvider<bool>((ref) => false);

// ── Step components ──────────────────────────────────────────────────────

class _Stepper extends StatelessWidget {
  const _Stepper({required this.step, required this.steps});
  final int step;
  final List<String> steps;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < steps.length; i++) ...<Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 2,
                  color: i <= step ? SsColors.ink : SsColors.divider,
                ),
                const SizedBox(height: 6),
                Text(
                  (i + 1).toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: SsColors.inkMuted,
                    fontSize: 11,
                    letterSpacing: 1.4,
                  ),
                ),
                Text(
                  steps[i],
                  style: TextStyle(
                    color: i == step ? SsColors.ink : SsColors.inkMuted,
                    fontSize: 12,
                    fontWeight: i == step ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (i < steps.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'A short form, a few minutes.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        const Text(
          'We need seven measurements, your fit preference, and a short note '
          'about what you have in mind. Everything is on-device — nothing is '
          'sent until you place an order.',
          style: TextStyle(color: SsColors.inkMuted, fontSize: 15, height: 1.6),
        ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onStart, child: const Text('BEGIN')),
      ],
    );
  }
}

class _UnitsStep extends StatelessWidget {
  const _UnitsStep({
    required this.units,
    required this.onChanged,
    required this.onNext,
  });
  final UnitSystem units;
  final ValueChanged<UnitSystem> onChanged;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Which unit would you like to use?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        for (final u in UnitSystem.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => onChanged(u),
              borderRadius: BorderRadius.circular(SsRadii.sm),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: units == u ? SsColors.ink : SsColors.surface,
                  border: Border.all(
                    color: units == u ? SsColors.ink : SsColors.divider,
                  ),
                  borderRadius: BorderRadius.circular(SsRadii.sm),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      units == u
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: units == u ? SsColors.ivory : SsColors.ink,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      u.longLabel,
                      style: TextStyle(
                        color: units == u ? SsColors.ivory : SsColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: onNext, child: const Text('CONTINUE')),
      ],
    );
  }
}

class _BodyStep extends StatelessWidget {
  const _BodyStep({
    required this.units,
    required this.controllers,
    required this.errors,
    required this.onValidate,
    required this.onBack,
    required this.onNext,
  });
  final UnitSystem units;
  final Map<String, TextEditingController> controllers;
  final Map<String, String?> errors;
  final bool Function() onValidate;
  final VoidCallback onBack;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Body measurements',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'All values in ${units.label}. Leave a field blank to skip.',
          style: const TextStyle(color: SsColors.inkMuted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        for (final entry in _fields)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FieldRow(
              label: entry.$1,
              hint: entry.$2,
              unit: units.label,
              controller: controllers[entry.$3]!,
              error: errors[entry.$3],
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            OutlinedButton(onPressed: onBack, child: const Text('BACK')),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: onNext, child: const Text('CONTINUE')),
          ],
        ),
      ],
    );
  }

  static const _fields = <(String, String, String)>[
    (
      'Bust / chest',
      'Around the fullest part of the chest, tape level.',
      'bust',
    ),
    ('Waist', 'Around the natural waist, just above the navel.', 'waist'),
    ('Hips', 'Around the fullest part of the hips, tape level.', 'hips'),
    (
      'Shoulder',
      'From one shoulder bone to the other, across the back.',
      'shoulder',
    ),
    ('Sleeve', 'From shoulder bone to wrist, arm slightly bent.', 'sleeve'),
    (
      'Inseam',
      'From crotch to ankle bone, on the inside of the leg.',
      'inseam',
    ),
    ('Height', 'Without shoes, head straight.', 'height'),
  ];
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.label,
    required this.hint,
    required this.unit,
    required this.controller,
    required this.error,
  });
  final String label;
  final String hint;
  final String unit;
  final TextEditingController controller;
  final String? error;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              unit,
              style: const TextStyle(color: SsColors.inkMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            errorText: error,
          ),
        ),
      ],
    );
  }
}

class _FitStep extends StatelessWidget {
  const _FitStep({
    required this.current,
    required this.onChanged,
    required this.onBack,
    required this.onNext,
  });
  final FitPreference current;
  final ValueChanged<FitPreference> onChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'How would you like it to fit?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        for (final f in FitPreference.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => onChanged(f),
              borderRadius: BorderRadius.circular(SsRadii.sm),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: current == f ? SsColors.ink : SsColors.surface,
                  border: Border.all(
                    color: current == f ? SsColors.ink : SsColors.divider,
                  ),
                  borderRadius: BorderRadius.circular(SsRadii.sm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      current == f
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: current == f ? SsColors.ivory : SsColors.ink,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            f.label,
                            style: TextStyle(
                              color:
                                  current == f ? SsColors.ivory : SsColors.ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _fitHint(f),
                            style: TextStyle(
                              color: current == f
                                  ? SsColors.ivory.withValues(alpha: 0.75)
                                  : SsColors.inkMuted,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            OutlinedButton(onPressed: onBack, child: const Text('BACK')),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: onNext, child: const Text('CONTINUE')),
          ],
        ),
      ],
    );
  }

  String _fitHint(FitPreference f) {
    switch (f) {
      case FitPreference.slim:
        return 'Close to the body, no ease. For a tailored silhouette.';
      case FitPreference.standard:
        return 'A relaxed, classic cut. The default for most pieces.';
      case FitPreference.relaxed:
        return 'Generous, easy through the body. For a draped, soft look.';
    }
  }
}

class _NotesStep extends StatelessWidget {
  const _NotesStep({
    required this.notes,
    required this.onChanged,
    required this.saveConsent,
    required this.onConsentChanged,
    required this.onBack,
    required this.onNext,
  });
  final String notes;
  final ValueChanged<String> onChanged;
  final bool saveConsent;
  final ValueChanged<bool> onConsentChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Anything we should know?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        TextField(
          maxLines: 5,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'The occasion, the season, anything you have in mind…',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: () => onConsentChanged(!saveConsent),
          borderRadius: BorderRadius.circular(SsRadii.sm),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SsColors.surface,
              border: Border.all(color: SsColors.divider),
              borderRadius: BorderRadius.circular(SsRadii.sm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  saveConsent ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 20,
                  color: saveConsent ? SsColors.ink : SsColors.inkMuted,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Save my profile on this device',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Optional. Stored locally only — used to pre-fill this '
                        'form next time. You can clear it from your device at any time.',
                        style: TextStyle(
                          color: SsColors.inkMuted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            OutlinedButton(onPressed: onBack, child: const Text('BACK')),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: onNext, child: const Text('REVIEW')),
          ],
        ),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.profile,
    required this.controllers,
    required this.onBack,
    required this.onJump,
    required this.onAddToCart,
    this.product,
  });
  final MeasurementProfile profile;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onBack;
  final ValueChanged<int> onJump;
  final VoidCallback onAddToCart;
  final Product? product;
  @override
  Widget build(BuildContext context) {
    final entries = <(String, String, String)>[
      ('bust', 'Bust', '1'),
      ('waist', 'Waist', '2'),
      ('hips', 'Hips', '3'),
      ('shoulder', 'Shoulder', '4'),
      ('sleeve', 'Sleeve', '5'),
      ('inseam', 'Inseam', '6'),
      ('height', 'Height', '7'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'A quick review',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SsColors.surface,
            border: Border.all(color: SsColors.divider),
            borderRadius: BorderRadius.circular(SsRadii.md),
          ),
          child: Column(
            children: <Widget>[
              _ReviewLine(
                'Units',
                profile.units.label,
                onEdit: () => onJump(1),
              ),
              const Divider(color: SsColors.divider, height: 24),
              for (final e in entries) ...<Widget>[
                _ReviewLine(
                  e.$2,
                  (controllers[e.$1]!.text.trim().isEmpty)
                      ? 'Skipped'
                      : '${controllers[e.$1]!.text.trim()} ${profile.units.label}',
                  onEdit: () => onJump(2),
                ),
                if (e != entries.last)
                  const Divider(color: SsColors.divider, height: 24),
              ],
              const Divider(color: SsColors.divider, height: 24),
              _ReviewLine('Fit', profile.fit.label, onEdit: () => onJump(3)),
              const Divider(color: SsColors.divider, height: 24),
              _ReviewLine(
                'Notes',
                (profile.notes ?? '').isEmpty ? 'None' : profile.notes!,
                onEdit: () => onJump(4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (product != null) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SsColors.surfaceMuted,
              borderRadius: BorderRadius.circular(SsRadii.sm),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.checkroom_outlined,
                  size: 18,
                  color: SsColors.inkMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Adding to cart: ${product!.name}, made to measure.',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          children: <Widget>[
            OutlinedButton(onPressed: onBack, child: const Text('BACK')),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onAddToCart,
              child: Text(product != null ? 'ADD TO CART' : 'SAVE PROFILE'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewLine extends StatelessWidget {
  const _ReviewLine(this.label, this.value, {this.onEdit});
  final String label;
  final String value;
  final VoidCallback? onEdit;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 110,
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: SsColors.inkMuted,
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 14, height: 1.4)),
        ),
        if (onEdit != null)
          TextButton(onPressed: onEdit, child: const Text('EDIT')),
      ],
    );
  }
}

class _HelpPanel extends StatelessWidget {
  const _HelpPanel();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SsColors.surfaceMuted,
        borderRadius: BorderRadius.circular(SsRadii.md),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'HOW TO MEASURE',
            style: TextStyle(
              color: SsColors.inkMuted,
              fontSize: 11,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Use a soft tape measure, snug but not tight. Stand relaxed — '
            'do not hold your breath. If you can, have someone help you, '
            'especially for shoulder and inseam.',
            style: TextStyle(color: SsColors.ink, fontSize: 13, height: 1.6),
          ),
          SizedBox(height: 12),
          Text(
            'If a number is off, we will adjust at the muslin fitting. '
            'These numbers are a starting point — not a contract.',
            style: TextStyle(
              color: SsColors.inkMuted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
