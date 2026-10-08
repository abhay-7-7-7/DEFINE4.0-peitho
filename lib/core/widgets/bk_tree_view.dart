import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';

class BkTreeNode {
  BkTreeNode({
    required this.label,
    this.icon,
    this.children = const [],
    this.isExpanded = false,
    this.data,
  });

  final String label;
  final IconData? icon;
  final List<BkTreeNode> children;
  bool isExpanded;
  final dynamic data;
}

/// A neubrutalist tree view component with expand/collapse hierarchy and guides.
class BkTreeView extends StatefulWidget {
  const BkTreeView({
    super.key,
    required this.nodes,
    this.onNodeTap,
  });

  final List<BkTreeNode> nodes;
  final ValueChanged<BkTreeNode>? onNodeTap;

  @override
  State<BkTreeView> createState() => _BkTreeViewState();
}

class _BkTreeViewState extends State<BkTreeView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.nodes.map((node) => _buildNode(node, 0)).toList(),
    );
  }

  Widget _buildNode(BkTreeNode node, int depth) {
    final t = BkTokens.of(context);
    final hasChildren = node.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            BkMotion.hapticClick();
            if (hasChildren) {
              setState(() => node.isExpanded = !node.isExpanded);
            }
            widget.onNodeTap?.call(node);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: EdgeInsets.fromLTRB(12.0 + depth * 20.0, 8, 12, 8),
            decoration: BoxDecoration(
              color: node.isExpanded && hasChildren
                  ? t.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              border: Border(
                  left: BorderSide(color: t.border, width: depth > 0 ? 2 : 0)),
            ),
            child: Row(
              children: [
                if (hasChildren)
                  AnimatedRotation(
                    turns: node.isExpanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child:
                        Icon(Icons.arrow_right, size: 20, color: t.foreground),
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 4),
                Icon(
                  node.icon ??
                      (hasChildren
                          ? (node.isExpanded ? Icons.folder_open : Icons.folder)
                          : Icons.insert_drive_file),
                  size: 18,
                  color: hasChildren ? t.primary : t.foreground,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.label.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight:
                          hasChildren ? FontWeight.w800 : FontWeight.w600,
                      color: t.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasChildren && node.isExpanded)
          ...node.children.map((child) => _buildNode(child, depth + 1)),
      ],
    );
  }
}
