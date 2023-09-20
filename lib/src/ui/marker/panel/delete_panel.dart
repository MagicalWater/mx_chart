import 'package:flutter/material.dart';

/// 刪除標記面板
class DeletePanel extends StatelessWidget {
  final VoidCallback onTap;

  const DeletePanel({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const Icon(Icons.delete, size: 20),
    );
  }
}
