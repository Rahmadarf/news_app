import 'package:flutter/material.dart';
import 'package:news_app/core/theme/newsline_tokens.dart';
import 'package:news_app/l10n/app_localizations.dart';

/// Rounded search field from the Discover design.
///
/// Owns its [TextEditingController] so it is disposed with the field, and
/// accepts an external value so a tapped recent term can populate it.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onSubmitted,
    required this.onCleared,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCleared;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.value,
  );
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only overwrite when the controller really is out of date, so typing is
    // never interrupted and the cursor does not jump.
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NewslineTokens tokens = NewslineTokens.of(context);

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: TextInputAction.search,
      // "search" keyboards omit a newline key, which is what we want here.
      keyboardType: TextInputType.text,
      onChanged: widget.onChanged,
      onSubmitted: (String value) {
        widget.onSubmitted(value);
        _focusNode.unfocus();
      },
      style: Theme.of(context).textTheme.bodySmall,
      decoration: InputDecoration(
        hintText: l10n.searchHint,
        prefixIcon: Icon(Icons.search, color: tokens.textSecondary, size: 20),
        suffixIcon: widget.value.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  widget.onCleared();
                  _focusNode.requestFocus();
                },
                tooltip: l10n.clearSearchAction,
                icon: const Icon(Icons.close, size: 20),
              ),
      ),
    );
  }
}
