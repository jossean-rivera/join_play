import 'package:flutter/material.dart';

/// A filled button that animates from left to right with a callback when pressed or completed.
class AnimatedFilledButton extends StatefulWidget {
  final double width;
  final double height;
  final Duration duration;
  final Widget buttonChild;
  final Color progressColor;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final VoidCallback onPressedOrCompleted;

  AnimatedFilledButton(
      {super.key,
      double? width,
      double? height,
      Duration? duration,
      Color? progressColor,
      Color? backgroundColor,
      BorderRadius? borderRadius,
      required this.buttonChild,
      required this.onPressedOrCompleted})
      : duration = duration ?? const Duration(seconds: 5),
        width = width ?? 100,
        height = height ?? 50,
        progressColor = progressColor ?? Colors.blueAccent,
        backgroundColor = backgroundColor ?? Colors.blueAccent.withOpacity(0.5),
        borderRadius = borderRadius ?? BorderRadius.circular(32);

  @override
  State<AnimatedFilledButton> createState() {
    return _AnimatedFilledButtonState();
  }
}

class _AnimatedFilledButtonState extends State<AnimatedFilledButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  late double height;
  late double maxWidth = 150;
  late double minWidth = 1;

  // Animated width value
  double currentWidth = 0;

  // Determines if we have invoked the callback
  bool _invokedCallback = false;

  @override
  void initState() {
    super.initState();

    // Get height and width from the parameters
    maxWidth = widget.width;
    height = widget.height;

    // Create animation controller
    _animationController =
        AnimationController(vsync: this, duration: widget.duration);

    // Create tween to interpolate the animation into the width of the growing container
    _widthAnimation = Tween<double>(begin: minWidth, end: maxWidth).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    // Route the user once the button is filled
    _animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        // Invoke the callback
        if (!_invokedCallback) {
          widget.onPressedOrCompleted();
          _invokedCallback = true;
        }
      }
    });

    // Update the width of the animated continer and render as the animation progresses.
    _animationController.addListener(() {
      setState(() => currentWidth = _widthAnimation.value);
    });

    // Start animation right away.
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap everything on a dector for when the user has click the button invoke the callback.
    return GestureDetector(
      onTap: () {
        if (!_invokedCallback) {
          widget.onPressedOrCompleted();
          _invokedCallback = true;
        }
      },
      // We need to clip the extra outside the border.
      // Use the ClipRRect component to cut what it outside the border of the button.
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Stack(
          children: [
            // Filled container with the ligher color
            Container(
              width: maxWidth,
              height: height,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: widget.borderRadius,
              ),
            ),

            // Anamited container with the darker color
            Container(
              width: currentWidth,
              height: height,
              decoration: BoxDecoration(
                color: widget.progressColor,
              ),
            ),

            // Clear container with the label of the button
            SizedBox(
              width: maxWidth,
              height: height,
              child: Center(child: widget.buttonChild),
            ),
          ],
        ),
      ),
    );
  }
}
