import 'package:flutter/material.dart';

typedef Widget AnimationValueBuilder<T>(BuildContext context, T value, Widget child);

/// This class takes an animation and a function that builds a widget based on the latest
/// value produced by the animation. Optionally, you can pass in a child not dependent
/// on the animation (and therefore can be built only once) and use it to build your widget
/// more efficiently.
class AnimationListenable<T> extends StatelessWidget {
  final Animation<T> animation;
  final AnimationValueBuilder<T> builder;
  final Widget staticChild;

  AnimationListenable({this.animation, this.builder, this.staticChild});

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
      animation: animation,
      builder: (context, child) => builder(context, animation.value, child),
      child: staticChild,
    );
  }
}
