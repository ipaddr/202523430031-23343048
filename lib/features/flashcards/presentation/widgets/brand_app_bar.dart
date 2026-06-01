import 'package:flutter/material.dart';
import 'package:flashcard/core/theme/app_theme.dart';

class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const BrandAppBar({
    super.key,
    this.title = 'FlashMind',
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      leading: leading,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.auto_awesome, color: AppTheme.primary),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
