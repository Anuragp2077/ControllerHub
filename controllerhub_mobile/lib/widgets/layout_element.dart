import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/controller_element.dart';

class LayoutElement extends StatelessWidget {
  final ControllerElement element;

  final Widget child;

  final double containerWidth;
  final double containerHeight;

  final bool editing;

  final VoidCallback? onTap;

  const LayoutElement({
    super.key,
    required this.element,
    required this.child,
    required this.containerWidth,
    required this.containerHeight,
    this.editing = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!element.visible) {
      return const SizedBox.shrink();
    }

    final double left =
        element.x * containerWidth;

    final double top =
        element.y * containerHeight;

    final double width =
        element.width * containerWidth;

    final double height =
        element.height * containerHeight;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Transform.rotate(
        angle: element.rotation *
            math.pi /
            180.0,
        child: Opacity(
          opacity: element.opacity.clamp(
            0.0,
            1.0,
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                child,

                if (editing)
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white
                              .withValues(
                            alpha: 0.7,
                          ),
                          width: 1.5,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}