import 'package:flutter/material.dart';

/// 页面主标题：超粗白色大标题，可带灰色数量后缀（如「追剧 · 62」）。
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.actions = const [],
    this.count,
  });
  final String title;
  final List<Widget> actions;

  /// 显示在标题右侧的灰色数量，例如 `62`。
  final String? count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
      child: SizedBox(
        height: 62,
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                      ),
                    ),
                    if (count case final value?) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· $value',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}
