import 'package:flutter/material.dart';

class SectionHeaderRow extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  const SectionHeaderRow({super.key, required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(children: [
        Expanded(child: Text(title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
        if (actionText != null && onAction != null)
          TextButton(
            onPressed: onAction, 
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Row(children: [
              Text(actionText!, style: TextStyle(color: scheme.primary, fontSize: 15, fontWeight: FontWeight.w500)), 
              const SizedBox(width: 2),
              Icon(Icons.chevron_right, color: scheme.primary, size: 22),
            ]),
          ),
      ]),
    );
  }
}
