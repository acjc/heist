import 'package:flutter/material.dart';

Widget dynamicBackground(PageController controller) => Stack(
      children: [
        imageBackground('assets/graphics/background.png'),
        _ParallaxBackground(
          controller,
          'assets/graphics/moon.png',
          speedCoefficient: 0.2,
        ),
        _ParallaxBackground(
          controller,
          'assets/graphics/clouds.png',
          speedCoefficient: 0.6,
        ),
        _ParallaxBackground(
          controller,
          'assets/graphics/foreground.png',
          speedCoefficient: 0.9,
        ),
      ],
    );

Widget staticBackground() => Stack(
      children: [
        imageBackground('assets/graphics/background.png', alignment: Alignment.centerLeft),
        imageBackground('assets/graphics/moon.png', alignment: Alignment.centerLeft),
        imageBackground('assets/graphics/clouds.png', alignment: Alignment.centerLeft),
        imageBackground('assets/graphics/foreground.png', alignment: Alignment.centerLeft),
      ],
    );

Widget imageBackground(String imagePath, {Alignment alignment = Alignment.center}) => Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          alignment: alignment,
          fit: BoxFit.fitHeight,
        ),
      ),
    );

class _ParallaxBackground extends StatefulWidget {
  @required
  final ScrollController controller;
  @required
  final String imagePath;

  /// How far / fast the image should move while scrolling
  final double speedCoefficient;

  _ParallaxBackground(this.controller, this.imagePath, {this.speedCoefficient = 0.7});

  @override
  State<StatefulWidget> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<_ParallaxBackground> {
  /// Scroll offset when this widget is first ready
  double initialOffset;

  /// Width of the viewport
  double viewportSize;

  /// Offset of background image, must be in range [-1.0, 1.0].
  /// Offset '0.0' means the image is horizontally centered, '-1.0' means
  /// it's left-aligned and `1.0` it's right-aligned.
  double offset = 0.0;

  void _handleScroll() {
    if (initialOffset == null) {
      initialOffset = widget.controller.offset;
    }
    if (viewportSize == null) {
      viewportSize = widget.controller.position.viewportDimension;
    }

    /// Get the delta of the current scroll offset compared to our [initialOffset].
    /// This value would normally be less than the [viewportSize].
    final double delta = widget.controller.offset - initialOffset;

    /// Now we can calculate the distance travelled as a fraction of the [viewportSize]
    final double viewportFraction = (delta / viewportSize).clamp(-1.0, 1.0);

    /// Adjust by our [speedCoefficient]
    final double newOffset = widget.speedCoefficient * viewportFraction;

    /// Not every scroll notification will result in a different offset
    if (newOffset != offset) {
      setState(() {
        offset = newOffset;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Adjust alignment by [offset].
    Alignment alignment = Alignment.centerLeft.add(Alignment(offset, 0.0));
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            alignment: alignment, // Set alignment on the decoration image
            image: AssetImage(widget.imagePath),
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
    );
  }
}
