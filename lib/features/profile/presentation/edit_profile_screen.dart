import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/forms/validators.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_feedback.dart';
import '../../../shared/widgets/forms/app_selection_fields.dart';
import '../../../shared/widgets/forms/app_text_field.dart';
import '../../../shared/widgets/forms/unsaved_changes_guard.dart';
import '../../auth/auth_providers.dart';
import '../../auth/domain/user.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  // Read once: a background user update must not overwrite what is being typed.
  late final User? _user = ref.read(authProvider).value;
  late final _name = TextEditingController(text: _user?.name);
  late final _phone = TextEditingController(text: _user?.phone);
  late DateTime? _birthDate = _user?.birthDate;
  bool _dirty = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = _user;
    if (user == null || !_formKey.currentState!.validate()) return;
    final phone = _phone.text.trim();
    final ok = await runGuarded(
      context,
      () => ref
          .read(authProvider.notifier)
          .updateProfile(
            User(
              id: user.id,
              email: user.email,
              name: _name.text.trim(),
              phone: phone.isEmpty ? null : phone,
              birthDate: _birthDate,
            ),
          ),
    );
    if (!ok || !mounted) return;
    setState(() => _dirty = false);
    showAppSnack(context, 'Profile updated', type: SnackType.success);
    // Wait a frame so the guard sees the saved state before popping.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.canPop() ? context.pop() : context.go(Routes.profile);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return UnsavedChangesGuard(
      hasChanges: _dirty,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit profile')),
        body: Form(
          key: _formKey,
          onChanged: () {
            if (!_dirty) setState(() => _dirty = true);
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              AppTextField(
                label: 'Full name',
                requiredMark: true,
                controller: _name,
                prefixIcon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validators.compose([
                  Validators.required('Enter your name'),
                  Validators.minLength(2),
                  Validators.maxLength(80),
                  Validators.name(),
                ]),
              ),
              const Gap(AppSpacing.md),
              AppTextField(
                label: 'Email',
                initialValue: _user?.email,
                prefixIcon: Icons.mail_outline_rounded,
                enabled: false,
                helper: 'Contact support to change your email.',
              ),
              const Gap(AppSpacing.md),
              AppPhoneField(controller: _phone),
              const Gap(AppSpacing.md),
              AppDateField(
                label: 'Birthday',
                initialValue: _birthDate,
                firstDate: DateTime(1900),
                lastDate: now,
                onChanged: (value) => _birthDate = value,
              ),
              const Gap(AppSpacing.xl),
              AppButton(label: 'Save changes', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
