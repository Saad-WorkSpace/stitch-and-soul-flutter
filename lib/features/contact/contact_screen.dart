import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/motion.dart';
import '../../app/tokens.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/responsive.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  String _interest = 'Made to measure';
  bool _sending = false;
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height - 84,
        ),
        child: Container(
          color: const Color(0xFF172019),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              const Positioned(
                top: -260,
                right: -160,
                child: SsAnimatedOrb(color: SsColors.rose, size: 650),
              ),
              const Positioned(
                bottom: -300,
                left: -180,
                child: SsAnimatedOrb(color: SsColors.sage, size: 620),
              ),
              SsPageScaffold(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: SsSpace.xxxl),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 900;
                      return Flex(
                        direction: wide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SsFlexItem(
                            expand: wide,
                            flex: 5,
                            child: const _ContactInvitation(),
                          ),
                          SizedBox(
                            width: wide ? 72 : 0,
                            height: wide ? 0 : SsSpace.xxl,
                          ),
                          SsFlexItem(
                            expand: wide,
                            flex: 6,
                            child: _ContactFormPanel(
                              formKey: _formKey,
                              name: _name,
                              email: _email,
                              subject: _subject,
                              message: _message,
                              interest: _interest,
                              sending: _sending,
                              submitted: _submitted,
                              onInterestChanged: (value) {
                                setState(() {
                                  _interest = value;
                                  _submitted = false;
                                });
                              },
                              onSubmit: _onSubmit,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate() || _sending) return;
    setState(() {
      _sending = true;
      _submitted = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 720));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _submitted = true;
    });
    _name.clear();
    _email.clear();
    _subject.clear();
    _message.clear();
  }
}

class _ContactInvitation extends StatelessWidget {
  const _ContactInvitation();

  @override
  Widget build(BuildContext context) {
    return SsStaggeredReveal(
      stagger: const Duration(milliseconds: 85),
      children: <Widget>[
        const _ContactSectionLabel(),
        const SizedBox(height: SsSpace.xl),
        Text(
          'Let’s make something\nworth keeping.',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: SsColors.ivory,
                fontFamily: 'serif',
                fontWeight: FontWeight.w400,
                height: 1.02,
                letterSpacing: -1.4,
              ),
        ),
        const SizedBox(height: SsSpace.lg),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: const Text(
            'Tell us about the garment, the occasion, or the piece already in '
            'your wardrobe. A real person from the atelier replies — never a bot, '
            'never a sales script.',
            style: TextStyle(
              color: Color(0xFFBDBBB3),
              fontSize: 16,
              height: 1.65,
            ),
          ),
        ),
        const SizedBox(height: SsSpace.lg),
        const _AvailabilityPill(),
        const SizedBox(height: SsSpace.xl),
        const _ContactRouteCard(
          number: '01',
          icon: Icons.location_on_outlined,
          title: 'Visit the atelier',
          value: '14 Rue des Tisserands · Studio 3',
          detail: 'By appointment · Tuesday to Saturday',
        ),
        const SizedBox(height: 10),
        const _ContactRouteCard(
          number: '02',
          icon: Icons.alternate_email_rounded,
          title: 'Write directly',
          value: 'hello@elise.demo',
          detail: 'Replies within two business days',
        ),
        const SizedBox(height: 10),
        const _ContactRouteCard(
          number: '03',
          icon: Icons.phone_outlined,
          title: 'Urgent alteration',
          value: '+1 555 0144',
          detail: 'Tuesday–Friday · 10:00–18:00',
        ),
      ],
    );
  }
}

class _ContactSectionLabel extends StatelessWidget {
  const _ContactSectionLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Text(
          '02',
          style: TextStyle(
            color: SsColors.claySoft,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 58,
          height: 1,
          color: Colors.white.withValues(alpha: 0.22),
        ),
        const SizedBox(width: 14),
        const Text(
          'CONTACT THE ATELIER',
          style: TextStyle(
            color: Color(0xFFA9A79F),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.9,
          ),
        ),
      ],
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(SsRadii.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _PulseDot(),
          SizedBox(width: 9),
          Text(
            'OPEN FOR AUTUMN COMMISSIONS',
            style: TextStyle(
              color: SsColors.ivory,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (prefersReducedMotion(context)) {
      return const _Dot(opacity: 1, size: 8);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => _Dot(
        opacity: 0.55 + _controller.value * 0.45,
        size: 8 + _controller.value * 2,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.opacity, required this.size});
  final double opacity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF99D69A).withValues(alpha: opacity),
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF99D69A).withValues(alpha: opacity * 0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _ContactRouteCard extends StatefulWidget {
  const _ContactRouteCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
  });

  final String number;
  final IconData icon;
  final String title;
  final String value;
  final String detail;

  @override
  State<_ContactRouteCard> createState() => _ContactRouteCardState();
}

class _ContactRouteCardState extends State<_ContactRouteCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: SsDurations.short,
        curve: SsCurves.emphasized,
        transform: Matrix4.translationValues(_hovered ? 5 : 0, 0, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hovered
              ? SsColors.clay.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.045),
          border: Border.all(
            color: _hovered
                ? SsColors.claySoft.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.12),
          ),
          borderRadius: BorderRadius.circular(SsRadii.md),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 28,
              child: Text(
                widget.number,
                style: const TextStyle(
                  color: SsColors.claySoft,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _hovered
                    ? SsColors.clay
                    : Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: SsColors.ivory, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.title.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFA9A79F),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.value,
                    style: const TextStyle(
                      color: SsColors.ivory,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.detail,
                    style: const TextStyle(
                      color: Color(0xFFAAA89F),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactFormPanel extends StatelessWidget {
  const _ContactFormPanel({
    required this.formKey,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.interest,
    required this.sending,
    required this.submitted,
    required this.onInterestChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController subject;
  final TextEditingController message;
  final String interest;
  final bool sending;
  final bool submitted;
  final ValueChanged<String> onInterestChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFD),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
          BoxShadow(
            color: SsColors.clay.withValues(alpha: 0.12),
            blurRadius: 48,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'YOUR NOTE',
                        style: TextStyle(
                          color: SsColors.clay,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        'Tell us what you have in mind.',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: SsColors.ink,
                              fontFamily: 'serif',
                              height: 1.12,
                            ),
                      ),
                    ],
                  ),
                ),
                const _FormThreadMark(),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'A few useful details help us give you an honest first answer.',
              style: TextStyle(color: SsColors.inkMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            const Text(
              'I’M INTERESTED IN',
              style: TextStyle(
                color: SsColors.inkMuted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final option in const <String>[
                  'Made to measure',
                  'Alterations',
                  'Something else',
                ])
                  _InterestChip(
                    label: option,
                    selected: interest == option,
                    onTap: () => onInterestChanged(option),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, constraints) {
                final paired = constraints.maxWidth >= 500;
                final nameField = _ContactField(
                  controller: name,
                  label: 'Your name',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please share your name.'
                      : null,
                );
                final emailField = _ContactField(
                  controller: email,
                  label: 'Email address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please share an email.';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'That email looks off.';
                    }
                    return null;
                  },
                );

                if (!paired) {
                  return Column(
                    children: <Widget>[
                      nameField,
                      const SizedBox(height: 12),
                      emailField,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(child: nameField),
                    const SizedBox(width: 12),
                    Expanded(child: emailField),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            _ContactField(
              controller: subject,
              label: 'What is the piece or occasion?',
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please add a short subject.'
                  : null,
            ),
            const SizedBox(height: 12),
            _ContactField(
              controller: message,
              label: 'Tell us a little more',
              maxLines: 5,
              alignLabelWithHint: true,
              validator: (value) => value == null || value.trim().length < 12
                  ? 'A few sentences helps us reply well.'
                  : null,
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: SsDurations.medium,
              child: submitted
                  ? const _SuccessNote(key: ValueKey<String>('success'))
                  : const Row(
                      key: ValueKey<String>('privacy'),
                      children: <Widget>[
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: SsColors.inkMuted,
                        ),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Demo only — nothing is sent or stored.',
                            style: TextStyle(
                              color: SsColors.inkMuted,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            _ContactSubmitButton(
              sending: sending,
              submitted: submitted,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormThreadMark extends StatelessWidget {
  const _FormThreadMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        color: SsColors.ink,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.gesture_rounded, color: SsColors.claySoft),
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SsRadii.pill),
        child: AnimatedContainer(
          duration: SsDurations.short,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? SsColors.ink : Colors.white,
            borderRadius: BorderRadius.circular(SsRadii.pill),
            border: Border.all(
              color: selected ? SsColors.ink : SsColors.divider,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? SsColors.ivory : SsColors.ink,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactField extends StatelessWidget {
  const _ContactField({
    required this.controller,
    required this.label,
    required this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.alignLabelWithHint = false,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool alignLabelWithHint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: SsColors.ink, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: alignLabelWithHint,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.82),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 17, vertical: 17),
        labelStyle: const TextStyle(color: SsColors.inkMuted, fontSize: 13),
        floatingLabelStyle: const TextStyle(
          color: SsColors.clay,
          fontWeight: FontWeight.w700,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: SsColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: SsColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: SsColors.clay, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: SsColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: SsColors.error, width: 1.6),
        ),
      ),
      validator: validator,
    );
  }
}

class _SuccessNote extends StatelessWidget {
  const _SuccessNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F2E5),
        borderRadius: BorderRadius.circular(SsRadii.md),
        border: Border.all(color: SsColors.success.withValues(alpha: 0.35)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.check_circle_rounded, color: SsColors.success, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Message noted — this demo has not transmitted any data.',
              style: TextStyle(
                color: SsColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSubmitButton extends StatefulWidget {
  const _ContactSubmitButton({
    required this.sending,
    required this.submitted,
    required this.onPressed,
  });

  final bool sending;
  final bool submitted;
  final VoidCallback onPressed;

  @override
  State<_ContactSubmitButton> createState() => _ContactSubmitButtonState();
}

class _ContactSubmitButtonState extends State<_ContactSubmitButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = !widget.sending;
    final background = widget.submitted ? SsColors.success : SsColors.ink;
    return Semantics(
      button: true,
      label: widget.sending
          ? 'Sending message'
          : widget.submitted
              ? 'Message noted'
              : 'Send message',
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: _hovered && enabled ? 1.008 : 1,
          duration: SsDurations.micro,
          child: AnimatedContainer(
            duration: SsDurations.short,
            width: double.infinity,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(SsRadii.pill),
              boxShadow: <BoxShadow>[
                if (_hovered && enabled)
                  BoxShadow(
                    color: SsColors.clay.withValues(alpha: 0.30),
                    blurRadius: 22,
                    offset: const Offset(0, 9),
                  ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? widget.onPressed : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 17,
                  ),
                  child: AnimatedSwitcher(
                    duration: SsDurations.short,
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.75),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: widget.sending
                        ? const Row(
                            key: ValueKey<String>('sending'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: SsColors.ivory,
                                ),
                              ),
                              SizedBox(width: 10),
                              _SubmitLabel('PREPARING YOUR NOTE'),
                            ],
                          )
                        : widget.submitted
                            ? const Row(
                                key: ValueKey<String>('submitted'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 9),
                                  _SubmitLabel('MESSAGE NOTED'),
                                ],
                              )
                            : Row(
                                key: const ValueKey<String>('idle'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  _SubmitLabel(
                                    _hovered ? 'LET’S BEGIN' : 'SEND MESSAGE',
                                  ),
                                  const SizedBox(width: 10),
                                  AnimatedSlide(
                                    offset: _hovered
                                        ? const Offset(0.22, 0)
                                        : Offset.zero,
                                    duration: SsDurations.short,
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: SsColors.ivory,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitLabel extends StatelessWidget {
  const _SubmitLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: SsColors.ivory,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.55,
      ),
    );
  }
}
