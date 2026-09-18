import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/controller_element.dart';

class EditableLayoutElement extends StatelessWidget {
  final ControllerElement element;
  final bool selected;

  final double width;
  final double height;

  final VoidCallback onTap;

  final void Function(double dx, double dy) onDrag;

  final void Function(double deltaWidth, double deltaHeight)
      onResize;

  const EditableLayoutElement({
    super.key,
    required this.element,
    required this.selected,
    required this.width,
    required this.height,
    required this.onTap,
    required this.onDrag,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    if (!element.visible) {
      return const SizedBox.shrink();
    }

    final double left =
        element.x * width;

    final double top =
        element.y * height;

    final double elementWidth =
        element.width * width;

    final double elementHeight =
        element.height * height;

    return Positioned(
      left: left,
      top: top,
      width: elementWidth,
      height: elementHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onPanUpdate: (details) {
          onDrag(
            details.delta.dx / width,
            details.delta.dy / height,
          );
        },
        child: Transform.rotate(
          angle: element.rotation *
              math.pi /
              180.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(
                            alpha: 0.08,
                          )
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(
                              alpha: 0.20,
                            ),
                      width: selected ? 2 : 1,
                    ),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _ElementPreview(
                      id: element.id,
                    ),
                  ),
                ),
              ),

              if (selected)
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: _ResizeHandle(
                    onResize: (
                      dx,
                      dy,
                    ) {
                      onResize(
                        dx / width,
                        dy / height,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  final void Function(
    double dx,
    double dy,
  ) onResize;

  const _ResizeHandle({
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) {
        onResize(
          details.delta.dx,
          details.delta.dy,
        );
      },
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(6),
          border: Border.all(
            color: const Color(
              0xFF151515,
            ),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.open_in_full_rounded,
          size: 12,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _ElementPreview
    extends StatelessWidget {
  final String id;

  const _ElementPreview({
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    if (id == 'left_stick' ||
        id == 'right_stick') {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(
              0xFFE91B23,
            ),
            width: 3,
          ),
        ),
        child: Center(
          child: Container(
            width: 42,
            height: 42,
            decoration:
                const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(
                0xFF151515,
              ),
            ),
          ),
        ),
      );
    }

    if (id == 'dpad') {
      return Container(
        decoration: BoxDecoration(
          color: const Color(
            0xFF151515,
          ),
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(
            Icons.gamepad_rounded,
            color: Colors.white70,
            size: 38,
          ),
        ),
      );
    }

    if (id == 'a' ||
        id == 'b' ||
        id == 'x' ||
        id == 'y') {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(
            0xFF101010,
          ),
          border: Border.all(
            color:
                _faceButtonColor(id),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            id.toUpperCase(),
            style: TextStyle(
              color:
                  _faceButtonColor(id),
              fontSize: 20,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (id == 'settings') {
      return const Icon(
        Icons.settings_rounded,
        color: Colors.white,
        size: 30,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(
          0xFF151515,
        ),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: const Color(
            0xFF353535,
          ),
        ),
      ),
      child: Center(
        child: Text(
          _displayName(id),
          textAlign:
              TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static Color _faceButtonColor(
    String id,
  ) {
    switch (id) {
      case 'a':
        return const Color(
          0xFF43C95A,
        );
      case 'b':
        return const Color(
          0xFFE72B2B,
        );
      case 'x':
        return const Color(
          0xFF2796E8,
        );
      case 'y':
        return const Color(
          0xFFFFD21C,
        );
      default:
        return Colors.white;
    }
  }

  static String _displayName(
    String id,
  ) {
    switch (id) {
      case 'lt':
        return 'LT';
      case 'lb':
        return 'LB';
      case 'rt':
        return 'RT';
      case 'rb':
        return 'RB';
      case 'back':
        return 'BACK';
      case 'start':
        return 'START';
      case 'settings':
        return 'SETTINGS';
      case 'left_stick':
        return 'LS';
      case 'right_stick':
        return 'RS';
      default:
        return id.toUpperCase();
    }
  }
}