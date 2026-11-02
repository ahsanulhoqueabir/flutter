import 'package:flutter/material.dart';

import '../../../core/utils/debouncer.dart';

/// Search box with debounced [onChanged] and a clear button.
class AppSearchField extends StatefulWidget {
  const AppSearchField({super.key, required this.onChanged, this.hint = 'Search'});

  final ValueChanged<String> onChanged;
  final String hint;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  final _controller = TextEditingController();
  final _debouncer = Debouncer();

  @override
  void dispose() {
    _debouncer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    _debouncer.dispose();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: (value) => _debouncer.run(() => widget.onChanged(value.trim())),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (_, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: _clear,
                ),
        ),
      ),
    );
  }
}
