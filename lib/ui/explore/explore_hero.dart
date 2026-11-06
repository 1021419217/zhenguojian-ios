import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models.dart';
import '../app_scope.dart';
import '../widgets/cover_backdrop.dart';
import '../widgets/cover_image.dart';
import '../widgets/drama_grid.dart';
import '../widgets/focus_ring.dart';

const _shade = Color(0xFF0A0A0C);

typedef _HeroMetrics = ({
  double design,
  double height,
  double radius,
  EdgeInsets padding,
  Size cover,
  double coverRadius,
  double gap,
  double? width,
  double title,
  double meta,
  double button,
  bool detail,
});

_HeroMetrics _scale(_HeroMetrics base, double k) => (
  design: base.design,
  height: base.height * k,
  radius: base.radius * k,
  padding: base.padding * k,
  cover: base.cover * k,
  coverRadius: base.coverRadius * k,
  gap: base.gap * k,
  width: switch (base.width) {
    final width? => width * k,
    null => null,
  },
  title: base.title * k,
  meta: base.meta * k,
  button: base.button * k,
  detail: base.detail,
);

class ExploreHero extends StatelessWidget {
  const ExploreHero({
    super.key,
    required this.drama,
    required this.kicker,
    required this.meta,
    required this.action,
    required this.onPlay,
    required this.onDetail,
    this.progress,
    this.carousel = const <Drama>[],
    this.onOpen,
  });
  final Drama drama;
  final String kicker;
  final String meta;
  final String action;
  final VoidCallback onPlay;
  final VoidCallback onDetail;
  final double? progress;
  final List<Drama> carousel;
  final ValueChanged<Drama>? onOpen;

  _HeroMetrics _metrics(BuildContext context) =>
      switch (AppScope.formFactorOf(context)) {
        FormFactor.phone => (
          design: 358,
          height: 196,
          radius: 20,
          padding: const EdgeInsets.all(16),
          cover: const Size(109, 164),
          coverRadius: 12,
          gap: 16,
          width: null,
          title: 20,
          meta: 13,
          button: 40,
          detail: false,
        ),
        FormFactor.window => (
          design: 1312,
          height: 232,
          radius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          cover: const Size(128, 192),
          coverRadius: 14,
          gap: 24,
          width: 520,
          title: 28,
          meta: 14,
          button: 40,
          detail: true,
        ),
        FormFactor.pad => (
          design: 914,
          height: 224,
          radius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          cover: const Size(123, 184),
          coverRadius: 14,
          gap: 24,
          width: 440,
          title: 26,
          meta: 14,
          button: 44,
          detail: true,
        ),
        FormFactor.television => (
          design: 844,
          height: 196,
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          cover: const Size(107, 160),
          coverRadius: 12,
          gap: 22,
          width: 420,
          title: 26,
          meta: 14,
          button: 40,
          detail: true,
        ),
      };

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      // 手机端：沉浸式真轮播，清晰封面铺满 + 左右滑动 + 分页点联动。
      if (AppScope.formFactorOf(context) == FormFactor.phone) {
        return _PhoneCarousel(
          drama: drama,
          carousel: carousel,
          kicker: kicker,
          meta: meta,
          action: action,
          onPlay: onPlay,
          onOpen: onOpen,
        );
      }
      final base = _metrics(context);
      final k = math.max(
        1.0,
        dramaTileWidth(context, constraints.maxWidth) /
            dramaTileWidth(context, base.design),
      );
      return _hero(context, _scale(base, k), k);
    },
  );

  Widget _hero(BuildContext context, _HeroMetrics metrics, double k) {
    final colors = Theme.of(context).colorScheme;
    final television = AppScope.of(context).television;
    final muted = Colors.white.withValues(alpha: 0.78);
    final buttonSize = Size(0, metrics.button);
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6 * k,
      children: [
        Text(
          kicker,
          style: TextStyle(
            fontSize: metrics.meta - 1,
            fontWeight: FontWeight.w500,
            height: 1.3,
            color: muted,
          ),
        ),
        Text(
          drama.title,
          maxLines: metrics.detail ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: metrics.title,
            fontWeight: FontWeight.w800,
            height: 1.3,
            color: Colors.white,
          ),
        ),
        Text(
          meta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: metrics.meta, height: 1.3, color: muted),
        ),
        if (progress case final progress?)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 4,
              color: colors.primaryFixedDim,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
              stopIndicatorColor: Colors.transparent,
            ),
          ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              spacing: 12 * k,
              children: [
                FocusRing(
                  radius: 999,
                  child: FilledButton.icon(
                    autofocus: television,
                    onPressed: onPlay,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primaryFixedDim,
                      foregroundColor: colors.onPrimaryFixed,
                      minimumSize: buttonSize,
                      padding: EdgeInsets.fromLTRB(14 * k, 0, 20 * k, 0),
                      iconSize: 18 * k,
                      textStyle: TextStyle(
                        fontSize: metrics.meta,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(action),
                  ),
                ),
                if (metrics.detail)
                  FocusRing(
                    radius: 999,
                    child: FilledButton(
                      onPressed: onDetail,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.16),
                        foregroundColor: Colors.white,
                        minimumSize: buttonSize,
                        padding: EdgeInsets.symmetric(horizontal: 20 * k),
                        textStyle: TextStyle(fontSize: metrics.meta),
                      ),
                      child: const Text('详情'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
    return Semantics(
      container: true,
      label: kicker,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(metrics.radius),
        child: SizedBox(
          height: metrics.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: _shade.withValues(alpha: 0.9)),
              CoverBackdrop(
                drama: drama,
                sigma: 40,
                overlay: LinearGradient(
                  stops: metrics.detail ? const [0, 0.55, 1] : const [0, 1],
                  colors: metrics.detail
                      ? [
                          _shade.withValues(alpha: 0.9),
                          _shade.withValues(alpha: 0.7),
                          _shade.withValues(alpha: 0.2),
                        ]
                      : [
                          _shade.withValues(alpha: 0.88),
                          _shade.withValues(alpha: 0.55),
                        ],
                ),
              ),
              Padding(
                padding: metrics.padding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: metrics.gap,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          metrics.coverRadius,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x59000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SizedBox.fromSize(
                        size: metrics.cover,
                        child: DramaCover(
                          drama: drama,
                          radius: metrics.coverRadius,
                          details: false,
                        ),
                      ),
                    ),
                    if (metrics.width case final width?)
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: width),
                          child: info,
                        ),
                      )
                    else
                      Expanded(child: info),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 手机端沉浸式轮播：清晰封面铺满，可左右滑动，分页点跟随真实页数联动。
class _PhoneCarousel extends StatefulWidget {
  const _PhoneCarousel({
    required this.drama,
    required this.carousel,
    required this.kicker,
    required this.meta,
    required this.action,
    required this.onPlay,
    required this.onOpen,
  });
  final Drama drama;
  final List<Drama> carousel;
  final String kicker;
  final String meta;
  final String action;
  final VoidCallback onPlay;
  final ValueChanged<Drama>? onOpen;

  @override
  State<_PhoneCarousel> createState() => _PhoneCarouselState();
}

class _PhoneCarouselState extends State<_PhoneCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.carousel.isNotEmpty
        ? widget.carousel
        : <Drama>[widget.drama];
    return Semantics(
      container: true,
      label: widget.kicker,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 372,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: items.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) =>
                    _slide(context, items[index], index),
              ),
              Positioned(
                left: 20,
                bottom: 26,
                child: Row(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.only(right: 5),
                        width: i == _page ? 20 : 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? Colors.white
                              : const Color(0x55FFFFFF),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slide(BuildContext context, Drama d, int index) {
    final repository = AppScope.of(context).repository;
    final first = index == 0;
    final label = first
        ? widget.kicker
        : (d.category.isNotEmpty ? d.category : '推荐');
    final meta = first
        ? widget.meta
        : [
            if (d.category.isNotEmpty) d.category,
            if (d.episodes > 0) '共 ${d.episodes} 集',
          ].join(' · ');
    return GestureDetector(
      onTap: () {
        final onOpen = widget.onOpen;
        if (onOpen != null) {
          onOpen(d);
        } else {
          widget.onPlay();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: _shade),
          if (!DramaCover.imagesDisabled && d.id.isNotEmpty)
            CoverImage(
              key: ValueKey('hero-${d.id}-${d.cover}'),
              drama: d,
              repository: repository,
              placeholder: const ColoredBox(color: _shade),
              retryable: false,
            ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.38, 1.0],
                  colors: [
                    Color(0x330A0A0C),
                    Color(0x220A0A0C),
                    Color(0xF20A0A0C),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  d.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                    letterSpacing: -0.6,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                if (meta.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xB21A1A20),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Text(
                      meta,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          first ? widget.action : '立即观看',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Icon(
                          Icons.play_arrow_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
