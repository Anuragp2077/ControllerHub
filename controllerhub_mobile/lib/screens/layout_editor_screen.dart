import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/controller_element.dart';
import '../services/layout_controller.dart';
import '../widgets/editable_layout_element.dart';

class LayoutEditorScreen extends StatefulWidget {
  const LayoutEditorScreen({
    super.key,
  });

  @override
  State<LayoutEditorScreen> createState() =>
      _LayoutEditorScreenState();
}

class _LayoutEditorScreenState
    extends State<LayoutEditorScreen> {
  final LayoutController _layoutController =
      LayoutController();

  String? _selectedElementId;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    _loadLayout();
  }

  Future<void> _loadLayout() async {
    await _layoutController.load();

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });
  }

  ControllerElement? get _selectedElement {
    final id = _selectedElementId;

    if (id == null) {
      return null;
    }

    return _layoutController.getElement(id);
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedElementId == id) {
        _selectedElementId = null;
      } else {
        _selectedElementId = id;
      }
    });
  }

  void _clearSelection() {
    if (_selectedElementId == null) {
      return;
    }

    setState(() {
      _selectedElementId = null;
    });
  }

  void _moveElement(
    String id,
    double dx,
    double dy,
  ) {
    _layoutController.moveElement(
      id,
      dx: dx,
      dy: dy,
    );

    setState(() {});
  }

  void _resizeElement(
    String id,
    double deltaWidth,
    double deltaHeight,
  ) {
    _layoutController.resizeElement(
      id,
      deltaWidth: deltaWidth,
      deltaHeight: deltaHeight,
    );

    setState(() {});
  }

  void _rotateSelected(
    double degrees,
  ) {
    final id = _selectedElementId;

    if (id == null) {
      return;
    }

    _layoutController.rotateElement(
      id,
      degrees,
    );

    setState(() {});
  }

  void _setSelectedVisibility(
    bool visible,
  ) {
    final id = _selectedElementId;

    if (id == null) {
      return;
    }

    _layoutController.setElementVisibility(
      id,
      visible,
    );

    if (!visible) {
      setState(() {
        _selectedElementId = null;
      });
      return;
    }

    setState(() {});
  }

  void _setSelectedOpacity(
    double opacity,
  ) {
    final id = _selectedElementId;

    if (id == null) {
      return;
    }

    _layoutController.setElementOpacity(
      id,
      opacity,
    );

    setState(() {});
  }

  Future<void> _resetSelected() async {
    final id = _selectedElementId;

    if (id == null) {
      return;
    }

    await _layoutController.resetElement(id);

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    await _layoutController.save();

    if (!mounted) {
      return;
    }

    setState(() {
      _saving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Layout saved'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _done() async {
  if (_saving) {
    return;
  }

  setState(() {
    _saving = true;
  });

  await _layoutController.save();

  if (!mounted) {
    return;
  }

  setState(() {
    _saving = false;
  });

  await _close();
}

  Future<void> _reset() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Reset Layout?',
          ),
          content: const Text(
            'This will restore the default controller layout.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Reset',
              ),
            ),
          ],
        );
      },
    );

    if (shouldReset != true) {
      return;
    }

    await _layoutController.resetToDefault();

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedElementId = null;
    });
  }

  Future<void> _close() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  if (!mounted) {
    return;
  }

  Navigator.of(context).pop();
}

  Future<void> _showMoreOptions() async {
  final element = _selectedElement;

  if (element == null) {
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF15171C),
    barrierColor: Colors.black54,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height * 0.82,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                12,
                24,
                24,
              ),
              child: StatefulBuilder(
                builder: (
                  context,
                  setSheetState,
                ) {
                  final current =
                      _layoutController.getElement(
                    element.id,
                  );

                  if (current == null) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white24,
                            borderRadius:
                                BorderRadius
                                    .circular(4),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            color:
                                Colors.white70,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            current.id
                                .toUpperCase(),
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      const Text(
                        'Opacity',
                        style: TextStyle(
                          color:
                              Colors.white70,
                          fontSize: 13,
                        ),
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: current
                                  .opacity
                                  .clamp(
                                0.1,
                                1.0,
                              ),
                              min: 0.1,
                              max: 1.0,
                              divisions: 18,
                              onChanged:
                                  (value) {
                                _setSelectedOpacity(
                                  value,
                                );

                                setSheetState(
                                  () {},
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: 45,
                            child: Text(
                              '${(current.opacity * 100).round()}%',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      SwitchListTile(
                        contentPadding:
                            EdgeInsets.zero,
                        title: const Text(
                          'Visible',
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                          ),
                        ),
                        subtitle:
                            const Text(
                          'Show this control on the controller',
                          style:
                              TextStyle(
                            color:
                                Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        value:
                            current.visible,
                        onChanged:
                            (value) {
                          _setSelectedVisibility(
                            value,
                          );

                          setSheetState(
                            () {},
                          );
                        },
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            OutlinedButton
                                .icon(
                          onPressed:
                              () async {
                            await _resetSelected();

                            if (context
                                .mounted) {
                              Navigator.of(
                                context,
                              ).pop();
                            }
                          },
                          icon:
                              const Icon(
                            Icons
                                .restart_alt_rounded,
                          ),
                          label:
                              const Text(
                            'Reset Element',
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF050505),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (
        didPop,
        result,
      ) async {
        if (didPop) {
          return;
        }

        await _done();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF050505),
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0xFF050505),
                ),
              ),

              // =========================================================
              // HEADER
              // =========================================================

              Positioned(
                top: 8,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: _done,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 4),

                    const Text(
                      'Custom Layout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(
                        Icons.restart_alt_rounded,
                        size: 17,
                      ),
                      label: const Text(
                        'Reset',
                      ),
                    ),

                    const SizedBox(width: 8),

                    FilledButton.icon(
                      onPressed:
                          _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.save_rounded,
                              size: 17,
                            ),
                      label: const Text(
                        'Save',
                      ),
                    ),

                    const SizedBox(width: 8),

                    IconButton.filled(
                      tooltip: 'Done',
                      onPressed: _done,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // =========================================================
              // EDITOR
              // =========================================================

              Positioned(
                left: 20,
                right: 20,
                top: 68,
                bottom: 14,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0B0B),
                    borderRadius:
                        BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFF292929),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(22),
                    child: LayoutBuilder(
                      builder: (
                        context,
                        editorConstraints,
                      ) {
                        final editorWidth =
                            editorConstraints.maxWidth;

                        final editorHeight =
                            editorConstraints.maxHeight;

                        return GestureDetector(
                          behavior:
                              HitTestBehavior.opaque,
                          onTap: _clearSelection,
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: Size(
                                  editorWidth,
                                  editorHeight,
                                ),
                                painter:
                                    _GridPainter(),
                              ),

                              ..._layoutController
                                  .elements
                                  .map(
                                (element) {
                                  return EditableLayoutElement(
                                    element: element,
                                    selected:
                                        element.id ==
                                            _selectedElementId,
                                    width:
                                        editorWidth,
                                    height:
                                        editorHeight,
                                    onTap: () {
                                      _toggleSelection(
                                        element.id,
                                      );
                                    },
                                    onDrag: (
                                      dx,
                                      dy,
                                    ) {
                                      _moveElement(
                                        element.id,
                                        dx,
                                        dy,
                                      );
                                    },
                                    onResize: (
                                      deltaWidth,
                                      deltaHeight,
                                    ) {
                                      _resizeElement(
                                        element.id,
                                        deltaWidth,
                                        deltaHeight,
                                      );
                                    },
                                  );
                                },
                              ),

                              if (_selectedElementId ==
                                  null)
                                const Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 14,
                                  child: Center(
                                    child: _HintPill(),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // =========================================================
              // COMPACT TOOLBAR
              // =========================================================

              if (_selectedElement != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 26,
                  child: IgnorePointer(
                    ignoring: false,
                    child: Center(
                      child: _CompactToolbar(
                        element: _selectedElement!,
                        onRotateLeft: () {
                          _rotateSelected(-15);
                        },
                        onRotateRight: () {
                          _rotateSelected(15);
                        },
                        onMore: _showMoreOptions,
                        onDeselect: _clearSelection,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
void dispose() {
  _layoutController.dispose();

  super.dispose();
}
}

// =============================================================
// COMPACT TOOLBAR
// =============================================================

class _CompactToolbar extends StatelessWidget {
  final ControllerElement element;

  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onMore;
  final VoidCallback onDeselect;

  const _CompactToolbar({
    required this.element,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onMore,
    required this.onDeselect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF17191E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF343840),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            child: Text(
              element.id.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          _ToolbarButton(
            icon: Icons.rotate_left_rounded,
            tooltip: 'Rotate -15°',
            onPressed: onRotateLeft,
          ),

          _ToolbarButton(
            icon: Icons.rotate_right_rounded,
            tooltip: 'Rotate +15°',
            onPressed: onRotateRight,
          ),

          const SizedBox(width: 4),

          _ToolbarButton(
            icon: Icons.tune_rounded,
            tooltip: 'More options',
            onPressed: onMore,
          ),

          _ToolbarButton(
            icon: Icons.check_rounded,
            tooltip: 'Deselect',
            onPressed: onDeselect,
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: Colors.white70,
        size: 21,
      ),
    );
  }
}

// =============================================================
// HINT
// =============================================================

class _HintPill extends StatelessWidget {
  const _HintPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF17191E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF292C32),
        ),
      ),
      child: const Text(
        'Tap a control to edit • Drag to move',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
    );
  }
}

// =============================================================
// GRID
// =============================================================

class _GridPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    const double spacing = 40;

    final paint = Paint()
      ..color = Colors.white.withValues(
        alpha: 0.035,
      )
      ..strokeWidth = 1;

    for (
      double x = 0;
      x <= size.width;
      x += spacing
    ) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (
      double y = 0;
      y <= size.height;
      y += spacing
    ) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _GridPainter oldDelegate,
  ) {
    return false;
  }
}