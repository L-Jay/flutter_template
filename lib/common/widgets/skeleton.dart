import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// 骨架屏基础块，透明度在 0.35~0.75 之间循环。
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = AppSpacing.radiusSm,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.35 + _controller.value * 0.4,
          child: child,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: context.colors.divider,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// 文本行骨架，宽度按父级比例。
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, this.widthFactor = 1.0, this.height = 12});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: SkeletonBox(height: height, radius: height / 2),
      ),
    );
  }
}

/// 卡片骨架，用于列表首次加载。
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.lines = 2, this.showImage = true});

  final int lines;
  final bool showImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              SkeletonBox(width: 36, height: 36, radius: AppSpacing.radiusPill),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(widthFactor: 0.35, height: 12),
                    SizedBox(height: AppSpacing.sm),
                    SkeletonLine(widthFactor: 0.2, height: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (int i = 0; i < lines; i++) ...[
            SkeletonLine(widthFactor: i == lines - 1 ? 0.6 : 1),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (showImage) ...[
            const SizedBox(height: AppSpacing.xs),
            const SkeletonBox(height: 160, radius: AppSpacing.radiusSm),
          ],
        ],
      ),
    );
  }
}
