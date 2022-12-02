import 'package:flutter/material.dart';

class FlashPoint extends StatefulWidget {
  final bool active;
  final double width;
  final double height;
  final List<Color> flastColors;

  const FlashPoint({
    Key? key,
    required this.active,
    required this.flastColors,
    this.width = 10,
    this.height = 10,
  }) : super(key: key);

  @override
  _FlashPointState createState() => _FlashPointState();
}

class _FlashPointState extends State<FlashPoint>
    with SingleTickerProviderStateMixin {
  /// 最右側最新價格的動畫
  late final AnimationController _rightRealPriceAnimationController;

  @override
  void initState() {
    // 最右側最新價格的動畫
    _rightRealPriceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0,
      upperBound: 1,
    );
    _syncAnimationStatus();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FlashPoint oldWidget) {
    _syncAnimationStatus();
    super.didUpdateWidget(oldWidget);
  }

  /// 同步動畫狀態
  void _syncAnimationStatus() {
    if (widget.active && !_rightRealPriceAnimationController.isAnimating) {
      _rightRealPriceAnimationController.repeat(reverse: true);
    } else if (!widget.active &&
        _rightRealPriceAnimationController.isAnimating) {
      _rightRealPriceAnimationController.stop();
    }
  }

  @override
  void dispose() {
    _rightRealPriceAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rightRealPriceAnimationController,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: widget.active ? _rightRealPriceAnimationController.value : 0,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: widget.flastColors,
              ),
            ),
          ),
        );
      },
    );
  }
}
