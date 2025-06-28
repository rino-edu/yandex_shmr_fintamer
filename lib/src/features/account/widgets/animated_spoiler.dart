import 'package:flutter/material.dart';

class AnimatedSpoiler extends StatefulWidget {
  final Widget child;
  final bool isRevealed;

  const AnimatedSpoiler({
    super.key,
    required this.child,
    required this.isRevealed,
  });

  @override
  State<AnimatedSpoiler> createState() => _AnimatedSpoilerState();
}

class _AnimatedSpoilerState extends State<AnimatedSpoiler>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (widget.isRevealed) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedSpoiler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealed != oldWidget.isRevealed) {
      if (widget.isRevealed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizeTransition(
        sizeFactor: _animation,
        axisAlignment: -1.0,
        child: widget.child,
      ),
    );
  }
}
