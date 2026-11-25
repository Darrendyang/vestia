import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

class AiOrb extends StatefulWidget {
  const AiOrb({super.key, this.size = 72});
  final double size;

  @override
  State<AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final pulse = 1 + math.sin(controller.value * math.pi * 2) * 0.06;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Transform.scale(
            scale: pulse,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: controller.value * math.pi * 2,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: const [
                          Color(0xFF8EF2D0),
                          Color(0xFF8EA7FF),
                          Color(0xFFF2A68D),
                          Color(0xFF8EF2D0),
                        ],
                        stops: const [0, .35, .7, 1],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x668EF2D0),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(widget.size * .08),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF172E2A),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: widget.size * .38,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat(reverse: true);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = controller.value;
        return Stack(
          children: [
            Positioned(
              left: -90 + value * 45,
              top: -110 + value * 35,
              child: const Glow(color: Color(0xFF9ADBC2), size: 330),
            ),
            Positioned(
              right: -100 + value * 50,
              top: 180 - value * 60,
              child: const Glow(color: Color(0xFFE9B4A0), size: 300),
            ),
            Positioned(
              left: 180 - value * 40,
              bottom: -160 + value * 35,
              child: const Glow(color: Color(0xFFB7C5F2), size: 340),
            ),
          ],
        );
      },
    );
  }
}

class Glow extends StatelessWidget {
  const Glow({super.key, required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: .14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .18),
            blurRadius: 90,
            spreadRadius: 35,
          ),
        ],
      ),
    );
  }
}

class AiStatusBadge extends StatelessWidget {
  const AiStatusBadge({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0x338EF2D0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x668EF2D0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 6,
            height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF8EF2D0),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8EF2D0),
              fontSize: 10,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
