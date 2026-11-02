import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/forms/validators.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_feedback.dart';
import '../../../shared/widgets/feedback/status_view.dart';
import '../../../shared/widgets/forms/app_password_field.dart';
import '../../../shared/widgets/forms/app_search_field.dart';
import '../../../shared/widgets/forms/app_selection_fields.dart';
import '../../../shared/widgets/forms/app_text_field.dart';

/// Developer catalog of every shared component. Hidden in prod (see the router).
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _openStatus(StatusView view) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(appBar: AppBar(), body: view),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gap = Gap(AppSpacing.md);
    return Scaffold(
      appBar: AppBar(title: const Text('Component gallery')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const _Heading('Buttons'),
            AppButton(label: 'Primary', onPressed: () {}),
            const Gap(AppSpacing.xs),
            AppButton(
              label: 'Secondary (async)',
              variant: AppButtonVariant.secondary,
              onPressed: () => Future<void>.delayed(const Duration(seconds: 2)),
            ),
            const Gap(AppSpacing.xs),
            AppButton(
              label: 'Destructive',
              variant: AppButtonVariant.destructive,
              onPressed: () {},
            ),
            const Gap(AppSpacing.xs),
            const AppButton(label: 'Disabled', onPressed: null),
            const _Heading('Form controls'),
            AppSearchField(onChanged: (_) {}),
            gap,
            AppEmailField(controller: _email),
            gap,
            AppPasswordField(
              controller: _password,
              showStrength: true,
              validator: Validators.compose([Validators.required(), Validators.password()]),
            ),
            gap,
            const AppPhoneField(isRequired: true),
            gap,
            const AppOtpField(),
            gap,
            AppDropdownField<String>(
              label: 'Dropdown',
              hint: 'Choose one',
              items: const ['One', 'Two', 'Three'],
              itemLabel: (item) => item,
              onChanged: (_) {},
              validator: (value) => value == null ? 'Choose an option' : null,
            ),
            gap,
            AppChoiceField<String>(
              label: 'Choice',
              options: const ['Small', 'Medium', 'Large'],
              optionLabel: (option) => option,
              validator: (value) => value == null ? 'Choose a size' : null,
            ),
            gap,
            AppDateField(
              label: 'Date',
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              validator: Validators.requiredDate(),
            ),
            gap,
            AppSwitchField(title: 'Switch', subtitle: 'With a subtitle'),
            AppCheckboxField(
              label: 'I accept',
              validator: Validators.mustBeTrue('Please accept to continue'),
            ),
            gap,
            AppButton(
              label: 'Validate form',
              onPressed: () {
                _formKey.currentState!.validate();
              },
            ),
            const _Heading('Feedback'),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final type in SnackType.values)
                  OutlinedButton(
                    onPressed: () => showAppSnack(context, 'A ${type.name} message', type: type),
                    child: Text(type.name.capitalized),
                  ),
                OutlinedButton(
                  onPressed: () => showConfirmDialog(
                    context,
                    title: 'Delete this?',
                    message: 'This cannot be undone.',
                    confirmLabel: 'Delete',
                    destructive: true,
                  ),
                  child: const Text('Dialog'),
                ),
              ],
            ),
            const _Heading('Status views'),
            for (final (name, view) in const [
              ('Empty', StatusView.empty()),
              ('Error', StatusView.error()),
              ('Offline', StatusView.offline()),
              ('Not found', StatusView.notFound()),
              ('No access', StatusView.forbidden()),
              ('Maintenance', StatusView.maintenance()),
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(name),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _openStatus(view),
              ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.md),
      child: Text(text, style: context.textTheme.titleLarge),
    );
  }
}
