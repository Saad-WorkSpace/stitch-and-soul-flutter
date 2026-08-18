import 'package:flutter/material.dart';

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
  String? _submitted;

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
      child: SsPageScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: SsSpace.lg),
            const SsSectionHeading(
              eyebrow: 'Get in touch',
              title: 'A short note is the best start.',
              subtitle:
                  'We respond within two business days. For urgent alterations, please call.',
            ),
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
                      flex: 3,
                      child: _Form(
                        formKey: _formKey,
                        name: _name,
                        email: _email,
                        subject: _subject,
                        message: _message,
                        submitted: _submitted,
                        onSubmit: () => _onSubmit(context),
                      ),
                    ),
                    SizedBox(
                      width: isWide ? SsSpace.xxl : 0,
                      height: isWide ? 0 : SsSpace.xl,
                    ),
                    SsFlexItem(
                      expand: isWide,
                      flex: 2,
                      child: const _StudioInfo(),
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

  void _onSubmit(BuildContext context) {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    setState(() => _submitted = 'Thank you — we will be in touch shortly.');
    _name.clear();
    _email.clear();
    _subject.clear();
    _message.clear();
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.formKey,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.submitted,
    required this.onSubmit,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController subject;
  final TextEditingController message;
  final String? submitted;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (submitted != null) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SsColors.surface,
                border: Border.all(
                  color: SsColors.success.withValues(alpha: 0.4),
                ),
                borderRadius: BorderRadius.circular(SsRadii.sm),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.check_circle,
                    color: SsColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      submitted!,
                      style: const TextStyle(
                        color: SsColors.success,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Your name'),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please share your name.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please share an email.';
              if (!v.contains('@') || !v.contains('.')) {
                return 'That email looks off.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: subject,
            decoration: const InputDecoration(labelText: 'Subject'),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please add a short subject.'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: message,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Message',
              alignLabelWithHint: true,
            ),
            validator: (v) => (v == null || v.trim().length < 12)
                ? 'A few sentences helps us reply well.'
                : null,
          ),
          const SizedBox(height: 8),
          const Text(
            'Demo only — nothing is sent or stored.',
            style: TextStyle(color: SsColors.inkMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text('SEND MESSAGE'),
          ),
        ],
      ),
    );
  }
}

class _StudioInfo extends StatelessWidget {
  const _StudioInfo();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('STUDIO', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        const Text(
          'Stitch & Soul Atelier\n'
          '14 Rue des Tisserands\n'
          'Studio 3, second floor\n'
          'By appointment only',
          style: TextStyle(height: 1.7, fontSize: 15),
        ),
        const SizedBox(height: 16),
        Text('HOURS', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        const Text(
          'Tuesday — Friday · 10:00 — 18:00\n'
          'Saturday · by appointment\n'
          'Closed Sunday and Monday',
          style: TextStyle(height: 1.7, fontSize: 15),
        ),
        const SizedBox(height: 16),
        Text('DIRECT', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        const Text(
          'hello@stitchandsoul.demo\n'
          '+1 555 0144',
          style: TextStyle(height: 1.7, fontSize: 15),
        ),
      ],
    );
  }
}
