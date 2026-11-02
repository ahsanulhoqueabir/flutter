/// A form field validator: returns an error message, or `null` when valid.
typedef Validator = String? Function(String? value);

/// Centralized validation rules. Every form in the app uses these so messages
/// and rules stay consistent.
///
/// All rules except [required] treat an empty value as valid, so optional
/// fields work naturally. Combine rules with [compose]:
///
/// ```dart
/// validator: Validators.compose([Validators.required(), Validators.email()]),
/// ```
abstract final class Validators {
  static final _emailRegex = RegExp(r'^[\w.+-]+@[a-zA-Z\d-]+(\.[a-zA-Z\d-]+)*\.[a-zA-Z]{2,}$');
  static final _phoneRegex = RegExp(r'^\+?[\d\s\-()]{7,20}$');
  static final _nameRegex = RegExp(r"^[\p{L}\p{M}' .-]+$", unicode: true);

  /// Runs [validators] in order and returns the first error.
  static Validator compose(List<Validator> validators) => (value) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  };

  static Validator required([String message = 'This field is required']) =>
      (value) => (value == null || value.trim().isEmpty) ? message : null;

  static Validator email([String message = 'Enter a valid email address']) =>
      _optional((v) => _emailRegex.hasMatch(v) ? null : message);

  static Validator minLength(int min, [String? message]) =>
      _optional((v) => v.length >= min ? null : message ?? 'Must be at least $min characters');

  static Validator maxLength(int max, [String? message]) =>
      _optional((v) => v.length <= max ? null : message ?? 'Must be at most $max characters');

  static Validator phone([String message = 'Enter a valid phone number']) => _optional(
    (v) => _phoneRegex.hasMatch(v) && v.replaceAll(RegExp(r'\D'), '').length >= 7 ? null : message,
  );

  static Validator name([String message = 'Use letters, spaces, hyphens or apostrophes']) =>
      _optional((v) => _nameRegex.hasMatch(v) ? null : message);

  static Validator numeric([String message = 'Enter a valid number']) =>
      _optional((v) => num.tryParse(v) != null ? null : message);

  static Validator integer([String message = 'Enter a whole number']) =>
      _optional((v) => int.tryParse(v) != null ? null : message);

  static Validator range(num min, num max, [String? message]) => _optional((v) {
    final n = num.tryParse(v);
    if (n == null) return 'Enter a valid number';
    return n >= min && n <= max ? null : message ?? 'Must be between $min and $max';
  });

  static Validator url([String message = 'Enter a valid URL']) => _optional((v) {
    final uri = Uri.tryParse(v);
    final ok =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    return ok ? null : message;
  });

  static Validator pattern(RegExp regex, String message) =>
      _optional((v) => regex.hasMatch(v) ? null : message);

  /// Must equal the value returned by [other] (e.g. confirm password).
  static Validator match(String? Function() other, [String message = 'Values do not match']) =>
      (value) => value == other() ? null : message;

  /// Password policy: 8+ chars, upper, lower and digit.
  static Validator password() => _optional((v) {
    if (v.length < 8) return 'Use at least 8 characters';
    if (!v.contains(RegExp('[A-Z]'))) return 'Add an uppercase letter';
    if (!v.contains(RegExp('[a-z]'))) return 'Add a lowercase letter';
    if (!v.contains(RegExp(r'\d'))) return 'Add a number';
    return null;
  });

  /// For date fields that store their value as ISO text, or use [AppDateField.validator].
  static String? Function(DateTime?) requiredDate([String message = 'Select a date']) =>
      (value) => value == null ? message : null;

  /// For checkboxes such as "I accept the terms".
  static String? Function(bool?) mustBeTrue(String message) =>
      (value) => value == true ? null : message;

  static Validator _optional(String? Function(String value) rule) => (value) {
    final v = value?.trim() ?? '';
    return v.isEmpty ? null : rule(v);
  };
}

enum PasswordStrength {
  empty(0, ''),
  weak(0.25, 'Weak'),
  fair(0.5, 'Fair'),
  good(0.75, 'Good'),
  strong(1, 'Strong');

  const PasswordStrength(this.progress, this.label);

  final double progress;
  final String label;

  static PasswordStrength of(String password) {
    if (password.isEmpty) return empty;
    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp('[A-Z]')) && password.contains(RegExp('[a-z]'))) score++;
    if (password.contains(RegExp(r'\d'))) score++;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    return switch (score) {
      <= 1 => weak,
      2 => fair,
      3 || 4 => good,
      _ => strong,
    };
  }
}
