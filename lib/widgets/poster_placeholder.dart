import 'package:flutter/material.dart';

/// Placeholder de pôster com efeito shimmer: um brilho que percorre o
/// retângulo continuamente. Usado enquanto a imagem carrega ou quando o
/// filme não possui pôster.
class PosterPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const PosterPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.radius = 4,
  });

  @override
  State<PosterPlaceholder> createState() => _PosterPlaceholderState();
}

class _PosterPlaceholderState extends State<PosterPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

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
        final dx = widget.width * (_controller.value * 2 - 1);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              colors: const [
                Color(0xFF2A2A2A),
                Color(0xFF3D3D3D),
                Color(0xFF2A2A2A),
              ],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideGradient(dx),
            ),
          ),
          child: child,
        );
      },
      child: const Center(child: Icon(Icons.movie, color: Colors.white24)),
    );
  }
}

/// Translada o gradiente horizontalmente para criar o varrimento do shimmer.
class _SlideGradient extends GradientTransform {
  final double dx;
  const _SlideGradient(this.dx);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(dx, 0, 0);
}
