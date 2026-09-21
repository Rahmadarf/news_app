import 'package:flutter/material.dart';

/// Asks for a search term. Resolves to the trimmed query, or `null` if the
/// user cancelled.
Future<String?> showSearchDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => const _SearchDialog(),
  );
}

/// Stateful so the [TextEditingController] is disposed with the dialog; the
/// previous implementation leaked one per open. See docs/AUDIT.md M-6.
class _SearchDialog extends StatefulWidget {
  const _SearchDialog();

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final String query = _controller.text.trim();
    if (query.isEmpty) return;
    Navigator.of(context).pop(query);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search News'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Enter search term...',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Search')),
      ],
    );
  }
}
