import 'package:flutter/material.dart';

import '../../../../core/utils/file_size_formatter.dart';
import '../../../../providers/cleaning_provider.dart';

class JunkCategoryCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int size;
  final List<JunkFile> files;
  final Function(JunkFile) onToggle;

  const JunkCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.size,
    required this.files,
    required this.onToggle,
  });

  @override
  State<JunkCategoryCard> createState() => _JunkCategoryCardState();
}

class _JunkCategoryCardState extends State<JunkCategoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = widget.files.where((f) => f.isSelected).length;
    final allSelected = selectedCount == widget.files.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.files.length} items • ${FileSizeFormatter.format(widget.size)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: allSelected,
                    tristate: true,
                    onChanged: (value) {
                      for (final file in widget.files) {
                        if (file.isSelected != (value ?? false)) {
                          widget.onToggle(file);
                        }
                      }
                    },
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Column(
              children: widget.files.map((file) {
                return ListTile(
                  leading: Checkbox(
                    value: file.isSelected,
                    onChanged: (_) => widget.onToggle(file),
                  ),
                  title: Text(
                    file.name,
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    file.path,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    FileSizeFormatter.format(file.size),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
