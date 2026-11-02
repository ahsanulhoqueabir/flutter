import 'package:flutter/material.dart';

import '../../../core/utils/extensions.dart';
import 'field_label.dart';

/// Dropdown bound to a [Form].
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    required this.itemLabel,
    this.label,
    this.hint,
    this.value,
    this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  final List<T> items;
  final String Function(T) itemLabel;
  final String? label;
  final String? hint;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      child: DropdownButtonFormField<T>(
        // A value missing from items would throw, e.g. after a server list changes.
        initialValue: items.contains(value) ? value : null,
        isExpanded: true,
        hint: hint == null ? null : Text(hint!),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteractionIfError,
        borderRadius: BorderRadius.circular(14),
        decoration: InputDecoration(
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
        ),
        items: [
          for (final item in items)
            DropdownMenuItem(
              value: item,
              child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

/// Checkbox bound to a [Form]. Use [labelWidget] for text containing links.
class AppCheckboxField extends FormField<bool> {
  AppCheckboxField({
    super.key,
    String? label,
    Widget? labelWidget,
    bool initialValue = false,
    ValueChanged<bool>? onChanged,
    super.validator,
  }) : super(
         initialValue: initialValue,
         autovalidateMode: AutovalidateMode.onUserInteractionIfError,
         builder: (state) {
           void toggle() {
             final next = !(state.value ?? false);
             state.didChange(next);
             onChanged?.call(next);
           }

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 children: [
                   Checkbox(
                     value: state.value ?? false,
                     isError: state.hasError,
                     onChanged: (_) => toggle(),
                   ),
                   Expanded(
                     child: labelWidget ?? GestureDetector(onTap: toggle, child: Text(label ?? '')),
                   ),
                 ],
               ),
               FieldError(state.errorText),
             ],
           );
         },
       );
}

/// Single choice shown as chips; a better fit than radios for a few short options.
class AppChoiceField<T> extends FormField<T> {
  AppChoiceField({
    super.key,
    required List<T> options,
    required String Function(T) optionLabel,
    String? label,
    super.initialValue,
    ValueChanged<T>? onChanged,
    super.validator,
  }) : super(
         autovalidateMode: AutovalidateMode.onUserInteractionIfError,
         builder: (state) => LabeledField(
           label: label,
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Wrap(
                 spacing: 8,
                 runSpacing: 8,
                 children: [
                   for (final option in options)
                     ChoiceChip(
                       label: Text(optionLabel(option)),
                       selected: state.value == option,
                       onSelected: (_) {
                         state.didChange(option);
                         onChanged?.call(option);
                       },
                     ),
                 ],
               ),
               FieldError(state.errorText),
             ],
           ),
         ),
       );
}

/// Switch row bound to a [Form].
class AppSwitchField extends FormField<bool> {
  AppSwitchField({
    super.key,
    required String title,
    String? subtitle,
    bool initialValue = false,
    ValueChanged<bool>? onChanged,
  }) : super(
         initialValue: initialValue,
         builder: (state) => SwitchListTile(
           contentPadding: EdgeInsets.zero,
           title: Text(title),
           subtitle: subtitle == null ? null : Text(subtitle),
           value: state.value ?? false,
           onChanged: (value) {
             state.didChange(value);
             onChanged?.call(value);
           },
         ),
       );
}

/// Date picker bound to a [Form].
class AppDateField extends FormField<DateTime> {
  AppDateField({
    super.key,
    String? label,
    String hint = 'Select a date',
    super.initialValue,
    required DateTime firstDate,
    required DateTime lastDate,
    ValueChanged<DateTime>? onChanged,
    super.validator,
  }) : super(
         autovalidateMode: AutovalidateMode.onUserInteractionIfError,
         builder: (state) {
           final context = state.context;
           final value = state.value;

           Future<void> pick() async {
             final now = DateTime.now();
             // The picker asserts if its starting date falls outside the range.
             final start = value ?? (now.isAfter(lastDate) ? lastDate : now);
             final picked = await showDatePicker(
               context: context,
               initialDate: start.isBefore(firstDate) ? firstDate : start,
               firstDate: firstDate,
               lastDate: lastDate,
             );
             if (picked == null) return;
             state.didChange(picked);
             onChanged?.call(picked);
           }

           return LabeledField(
             label: label,
             child: InkWell(
               onTap: pick,
               borderRadius: BorderRadius.circular(14),
               child: InputDecorator(
                 isEmpty: value == null,
                 decoration: InputDecoration(
                   hintText: hint,
                   errorText: state.errorText,
                   prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                 ),
                 child: value == null ? null : Text(value.formatted),
               ),
             ),
           );
         },
       );
}
