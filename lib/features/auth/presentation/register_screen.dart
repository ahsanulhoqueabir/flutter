import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/forms/validators.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/buttons/app_button.dart';
import '../../../shared/widgets/feedback/app_feedback.dart';
import '../../../shared/widgets/forms/app_password_field.dart';
import '../../../shared/widgets/forms/app_selection_fields.dart';
import '../../../shared/widgets/forms/app_text_field.dart';
import '../auth_providers.dart';
import 'widgets/auth_layout.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  late final _termsTap = TapGestureRecognizer()..onTap = () => context.push(Routes.terms);
  late final _privacyTap = TapGestureRecognizer()..onTap = () => context.push(Routes.privacy);
  bool _submitting = false;
  String? _serverEmailError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _serverEmailError = null;
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(authProvider.notifier)
          .register(name: _name.text, email: _email.text, password: _password.text);
    } on ValidationException catch (e) {
      // Example of showing a server rule on its field, e.g. "email already taken".
      _serverEmailError = e.fieldErrors['email'];
      if (_serverEmailError != null) {
        _formKey.currentState!.validate();
      } else if (mounted) {
        showAppSnack(context, e.message, type: SnackType.error);
      }
    } on Object catch (e) {
      if (mounted) showAppSnack(context, userMessage(e), type: SnackType.error);
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    return AuthLayout(
      title: 'Create your account',
      subtitle: 'It only takes a minute.',
      footer: AuthFooterLink(
        question: 'Already have an account?',
        action: 'Sign in',
        onTap: () => context.go(Routes.login),
      ),
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Full name',
                controller: _name,
                hint: 'Ada Lovelace',
                prefixIcon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
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
                controller: _email,
                hint: 'you@example.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: Validators.compose([
                  Validators.required('Enter your email'),
                  Validators.email(),
                  (_) => _serverEmailError,
                ]),
                onChanged: (_) => _serverEmailError = null,
              ),
              const Gap(AppSpacing.md),
              AppPasswordField(
                controller: _password,
                showStrength: true,
                isNewPassword: true,
                textInputAction: TextInputAction.next,
                validator: Validators.compose([
                  Validators.required('Choose a password'),
                  Validators.password(),
                ]),
              ),
              const Gap(AppSpacing.md),
              AppPasswordField(
                controller: _confirm,
                label: 'Confirm password',
                isNewPassword: true,
                onSubmitted: (_) => _submit(),
                validator: Validators.compose([
                  Validators.required('Confirm your password'),
                  Validators.match(() => _password.text, 'Passwords do not match'),
                ]),
              ),
              const Gap(AppSpacing.sm),
              AppCheckboxField(
                validator: Validators.mustBeTrue('Please accept to continue'),
                labelWidget: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    children: [
                      TextSpan(text: 'Terms', style: linkStyle, recognizer: _termsTap),
                      const TextSpan(text: ' and '),
                      TextSpan(text: 'Privacy Policy', style: linkStyle, recognizer: _privacyTap),
                    ],
                  ),
                ),
              ),
              const Gap(AppSpacing.md),
              AppButton(label: 'Create account', onPressed: _submit, isLoading: _submitting),
            ],
          ),
        ),
      ),
    );
  }
}
