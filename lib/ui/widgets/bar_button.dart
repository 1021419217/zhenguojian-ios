import 'package:flutter/material.dart';

import '../app_scope.dart';
import 'focus_ring.dart';

/// 顶栏操作按钮：统一为半透明磨砂圆形玻璃按钮（42×42），
/// 白色图标 + 极细白色描边，取代默认的透明方形 IconButton。
class BarButton extends StatelessWidget {
  const BarButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final television = AppScope.of(context).television;
    return FocusRing(
      radius: 999,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: television ? 20 : 20),
        style: IconButton.styleFrom(
          fixedSize: const Size.square(42),
          minimumSize: const Size.square(42),
          padding: EdgeInsets.zero,
          backgroundColor: television
              ? colors.surfaceContainerHigh
              : Colors.white.withValues(alpha: 0.10),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
          shape: CircleBorder(
            side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
          ),
        ),
      ),
    );
  }
}
