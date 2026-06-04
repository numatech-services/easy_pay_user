import 'package:flutter/material.dart';
import 'dart:math' as math;
class AnimatedHologramWidget extends StatefulWidget {
  const AnimatedHologramWidget({Key? key}) : super(key: key);

  @override
  State<AnimatedHologramWidget> createState() => _AnimatedHologramWidgetState();
}

class _AnimatedHologramWidgetState extends State<AnimatedHologramWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: HologramPainter(_animation.value),
          child: Container(),
        );
      },
    );
  }
}

class HologramPainter extends CustomPainter {
  final double animationValue;

  HologramPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.cyan
              .withOpacity(0.15 * math.sin(animationValue * math.pi * 2)),
          Colors.blue.withOpacity(0.1),
          Colors.purple
              .withOpacity(0.15 * math.cos(animationValue * math.pi * 2)),
          Colors.white.withOpacity(0.05),
        ],
        stops: [
          0.0,
          0.25 + (0.1 * math.sin(animationValue * math.pi * 2)),
          0.5,
          0.75 + (0.1 * math.cos(animationValue * math.pi * 2)),
          1.0,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Cercles animés (globes ISIC)
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.2);

    final radius1 = 40 + (20 * math.sin(animationValue * math.pi * 2));
    final radius2 = 60 + (20 * math.cos(animationValue * math.pi * 2));

    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.3),
      radius1,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.7),
      radius2,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(HologramPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
