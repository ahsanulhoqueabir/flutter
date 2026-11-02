import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/forms/validators.dart';
import 'field_label.dart';

/// Base text input. Label sits above the field; errors appear after the first
/// submit attempt and clear as the user fixes them.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.validator,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.requiredMark = false,
  });

  final String? label;
  final String? hint;
  final String? helper;
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final Validator? validator;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool requiredMark;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      requiredMark: requiredMark,
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        focusNode: focusNode,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteractionIfError,
        obscureText: obscureText,
        enableSuggestions: !obscureText,
        autocorrect: !obscureText,
        enabled: enabled,
        readOnly: readOnly,
        autofocus: autofocus,
        minLines: minLines,
        maxLines: obscureText ? 1 : maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        autofillHints: autofillHints,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        onTap: onTap,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: InputDecoration(
          hintText: hint,
          helperText: helper,
          helperMaxLines: 2,
          errorMaxLines: 3,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}

/// Email input with the right keyboard, autofill and validation built in.
class AppEmailField extends StatelessWidget {
  const AppEmailField({
    super.key,
    required this.controller,
    this.label = 'Email',
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hint: 'you@example.com',
      enabled: enabled,
      prefixIcon: Icons.mail_outline_rounded,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
      onSubmitted: onSubmitted,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      validator: Validators.compose([Validators.required('Enter your email'), Validators.email()]),
    );
  }
}

/// Phone input. Optional unless [isRequired].
class AppPhoneField extends StatelessWidget {
  const AppPhoneField({
    super.key,
    this.controller,
    this.label = 'Phone',
    this.isRequired = false,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController? controller;
  final String label;
  final bool isRequired;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hint: '+1 555 000 1234',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      requiredMark: isRequired,
      autofillHints: const [AutofillHints.telephoneNumber],
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\s+\-()]'))],
      validator: Validators.compose([if (isRequired) Validators.required(), Validators.phone()]),
    );
  }
}

/// One-time code input with a numeric keyboard and SMS autofill.
class AppOtpField extends StatelessWidget {
  const AppOtpField({
    super.key,
    this.controller,
    this.length = 6,
    this.label = 'Verification code',
    this.onCompleted,
  });

  final TextEditingController? controller;
  final int length;
  final String label;
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hint: '0' * length,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ],
      onChanged: (value) {
        if (value.length == length) onCompleted?.call(value);
      },
      validator: Validators.compose([
        Validators.required('Enter the code'),
        Validators.minLength(length, 'Enter all $length digits'),
      ]),
    );
  }
}
