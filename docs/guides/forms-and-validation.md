# Forms and validation

Build forms from the controls in `lib/shared/widgets/forms/` and the rules in `lib/core/forms/validators.dart`. That keeps behavior and error messages the same everywhere. To see every control running, open **Settings → Component gallery** in a dev build.

## Controls

| Widget | Use for |
|---|---|
| `AppTextField` | Any text. All other text inputs build on it |
| `AppEmailField` | Email, with keyboard, autofill and validation included |
| `AppPasswordField` | Show/hide toggle, optional strength meter |
| `AppPhoneField` | Phone number, optional unless `isRequired` |
| `AppOtpField` | One-time codes, with SMS autofill |
| `AppSearchField` | Search with debounce and a clear button |
| `AppDropdownField<T>` | Choosing from a long list |
| `AppChoiceField<T>` | Choosing from a few short options, shown as chips |
| `AppDateField` | Date picker |
| `AppCheckboxField` | Checkbox, such as accepting terms |
| `AppSwitchField` | On/off setting |
| `UnsavedChangesGuard` | Confirms before leaving a screen with unsaved edits |

## A complete form

```dart
final _formKey = GlobalKey<FormState>();
final _email = TextEditingController(); // dispose it in dispose()

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  final ok = await runGuarded(context, () => ref.read(myProvider.notifier).save(_email.text));
  if (ok && mounted) showAppSnack(context, 'Saved', type: SnackType.success);
}

Form(
  key: _formKey,
  child: Column(children: [
    AppEmailField(controller: _email),
    AppButton(label: 'Save', onPressed: _submit),
  ]),
)
```

`AppButton` shows a spinner and blocks repeat taps until `_submit` finishes. `runGuarded` shows any failure in a snackbar.

Create controllers as fields of a `State`, never inside `build`, or the text is lost on every rebuild.

## When errors appear

Errors stay hidden until the first submit. After that, they update as the user types and clear as soon as the value is fixed.

## Validation rules

Every rule except `required` accepts an empty value, so optional fields work without extra code. Combine rules with `compose`; the first failure is the one shown.

```dart
validator: Validators.compose([
  Validators.required('Enter your name'),
  Validators.minLength(2),
  Validators.maxLength(80),
]),
```

Available rules: `required`, `email`, `password`, `phone`, `name`, `url`, `numeric`, `integer`, `range`, `minLength`, `maxLength`, `pattern`, `match`, plus `requiredDate` and `mustBeTrue` for date and checkbox fields.

To change a rule for the whole app, such as the password policy, edit it in `validators.dart` and update `test/core/forms/validators_test.dart`.

## Errors from the server

A 400 or 422 response becomes a `ValidationException`. Its `fieldErrors` maps field names to messages. To show one on its field, as "email already taken" does in `register_screen.dart`:

1. Catch `ValidationException` and store the message in a variable.
2. Add `(_) => _serverEmailError` to that field's validators.
3. Call `validate()` again to display it, and clear the variable in `onChanged`.

## Other shared feedback

- `showAppSnack(context, message, type: ...)`: info, success or error message
- `showConfirmDialog(context, title: ..., destructive: true)`: returns true if confirmed
- `StatusView.empty/error/offline/notFound/forbidden/maintenance`: full-area states
- `AsyncValueView`: picks the right loading or status view for a provider automatically
