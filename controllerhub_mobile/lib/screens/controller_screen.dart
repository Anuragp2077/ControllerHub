import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/controller_element.dart';
import '../models/controller_layout.dart';
import '../services/controllerhub_socket.dart';
import '../services/layout_controller.dart';
import '../widgets/layout_element.dart';
import 'layout_editor_screen.dart';

class ControllerScreen extends StatefulWidget {
  final ControllerHubSocket socket;
  final int slot;

  const ControllerScreen({
    super.key,
    required this.socket,
    required this.slot,
  });

  @override
  State<ControllerScreen> createState() =>
      _ControllerScreenState();
}

class _ControllerScreenState
    extends State<ControllerScreen> {
  // =============================================================
  // LAYOUT
  // =============================================================

  final LayoutController _layoutController =
      LayoutController();

  ControllerLayout? _layout;

  bool _layoutLoading = true;

  // =============================================================
  // JOYSTICK SETTINGS
  // =============================================================

  bool _leftInvertX = false;
  bool _leftInvertY = false;

  bool _rightInvertX = false;
  bool _rightInvertY = false;

  // =============================================================
  // INIT
  // =============================================================

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
      _layout = _layoutController.layout;
      _layoutLoading = false;
    });
  }

  // =============================================================
  // INPUT
  // =============================================================

  void _button(
    String button,
    bool pressed,
  ) {
    if (!widget.socket.isConnected) {
      return;
    }

    widget.socket.sendButton(
      button: button,
      pressed: pressed,
    );
  }

  void _trigger(
    String trigger,
    double value,
  ) {
    if (!widget.socket.isConnected) {
      return;
    }

    widget.socket.sendTrigger(
      trigger: trigger,
      value: value,
    );
  }

  void _stick(
    String stick,
    double x,
    double y,
  ) {
    if (!widget.socket.isConnected) {
      return;
    }

    // Independent inversion for LEFT stick.
    if (stick == 'Left') {
      if (_leftInvertX) {
        x = -x;
      }

      if (_leftInvertY) {
        y = -y;
      }
    }

    // Independent inversion for RIGHT stick.
    if (stick == 'Right') {
      if (_rightInvertX) {
        x = -x;
      }

      if (_rightInvertY) {
        y = -y;
      }
    }

    widget.socket.sendStick(
      stick: stick,
      x: x,
      y: y,
    );
  }

  void _stickClick(
    String button,
  ) {
    _button(button, true);

    Future.delayed(
      const Duration(milliseconds: 70),
      () {
        if (mounted) {
          _button(button, false);
        }
      },
    );
  }

  // =============================================================
  // CLOSE CONTROLLER
  // =============================================================

  Future<void> _closeController() async {
    await widget.socket.disconnect();

    if (!mounted) {
      return;
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  // =============================================================
  // CUSTOM LAYOUT EDITOR
  // =============================================================

  Future<void> _openLayoutEditor() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const LayoutEditorScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    // Reload the layout after returning from the editor.
    await _layoutController.load();

    if (!mounted) {
      return;
    }

    setState(() {
      _layout = _layoutController.layout;
    });

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  // =============================================================
  // GET ELEMENT
  // =============================================================

  // =============================================================
  // SETTINGS
  // =============================================================

  void _showSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF15171C),
      barrierColor: Colors.black.withValues(
        alpha: 0.72,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            final double height =
                MediaQuery.sizeOf(context).height;

            return SafeArea(
              child: SizedBox(
                height: math.min(
                  height * 0.82,
                  620,
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 14,
                    ),

                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 28,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration:
                                const BoxDecoration(
                              color: Color(
                                0xFF20242C,
                              ),
                              shape:
                                  BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: Color(
                                0xFFE7E9ED,
                              ),
                              size: 24,
                            ),
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          const Expanded(
                            child: Text(
                              'Controller Settings',
                              style: TextStyle(
                                color: Color(
                                  0xFFE8E9EC,
                                ),
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Expanded(
                      child:
                          SingleChildScrollView(
                        physics:
                            const BouncingScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(
                          28,
                          0,
                          28,
                          30,
                        ),
                        child: Column(
                          children: [
                            // =================================================
                            // CUSTOM LAYOUT
                            // =================================================

                            _SettingsSection(
                              title:
                                  'Controller Layout',
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                                onTap: () {
                                  Navigator.of(
                                    sheetContext,
                                  ).pop();

                                  Future.delayed(
                                    const Duration(
                                      milliseconds: 180,
                                    ),
                                    () {
                                      if (mounted) {
                                        _openLayoutEditor();
                                      }
                                    },
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration:
                                            BoxDecoration(
                                          color:
                                              const Color(
                                            0xFF20242C,
                                          ),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            13,
                                          ),
                                        ),
                                        child:
                                            const Icon(
                                          Icons
                                              .dashboard_customize_rounded,
                                          color:
                                              Color(
                                            0xFFE7E9ED,
                                          ),
                                          size: 23,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 14,
                                      ),

                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              'Custom Layout',
                                              style:
                                                  TextStyle(
                                                color:
                                                    Color(
                                                  0xFFE8E9EC,
                                                ),
                                                fontSize:
                                                    16,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              'Move, resize and customize controls',
                                              style:
                                                  TextStyle(
                                                color:
                                                    Colors
                                                        .white54,
                                                fontSize:
                                                    12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const Icon(
                                        Icons
                                            .chevron_right_rounded,
                                        color:
                                            Colors.white54,
                                        size: 25,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // =================================================
                            // LEFT STICK
                            // =================================================

                            _SettingsSection(
                              title: 'Left Stick',
                              child: Column(
                                children: [
                                  _SettingsSwitch(
                                    title:
                                        'Invert X Axis',
                                    subtitle:
                                        'Reverse left / right movement',
                                    value:
                                        _leftInvertX,
                                    onChanged:
                                        (value) {
                                      setState(() {
                                        _leftInvertX =
                                            value;
                                      });

                                      setSheetState(
                                        () {},
                                      );
                                    },
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  _SettingsSwitch(
                                    title:
                                        'Invert Y Axis',
                                    subtitle:
                                        'Reverse up / down movement',
                                    value:
                                        _leftInvertY,
                                    onChanged:
                                        (value) {
                                      setState(() {
                                        _leftInvertY =
                                            value;
                                      });

                                      setSheetState(
                                        () {},
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // =================================================
                            // RIGHT STICK
                            // =================================================

                            _SettingsSection(
                              title: 'Right Stick',
                              child: Column(
                                children: [
                                  _SettingsSwitch(
                                    title:
                                        'Invert X Axis',
                                    subtitle:
                                        'Reverse left / right movement',
                                    value:
                                        _rightInvertX,
                                    onChanged:
                                        (value) {
                                      setState(() {
                                        _rightInvertX =
                                            value;
                                      });

                                      setSheetState(
                                        () {},
                                      );
                                    },
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  _SettingsSwitch(
                                    title:
                                        'Invert Y Axis',
                                    subtitle:
                                        'Reverse up / down movement',
                                    value:
                                        _rightInvertY,
                                    onChanged:
                                        (value) {
                                      setState(() {
                                        _rightInvertY =
                                            value;
                                      });

                                      setSheetState(
                                        () {},
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // =================================================
                            // CURRENT CONFIGURATION
                            // =================================================

                            _SettingsSection(
                              title:
                                  'Current Configuration',
                              child: Column(
                                children: [
                                  _SettingInfoRow(
                                    label:
                                        'Controller',
                                    value:
                                        'P${widget.slot}',
                                  ),
                                  _SettingInfoRow(
                                    label:
                                        'Left X',
                                    value:
                                        _leftInvertX
                                            ? 'Inverted'
                                            : 'Normal',
                                  ),
                                  _SettingInfoRow(
                                    label:
                                        'Left Y',
                                    value:
                                        _leftInvertY
                                            ? 'Inverted'
                                            : 'Normal',
                                  ),
                                  _SettingInfoRow(
                                    label:
                                        'Right X',
                                    value:
                                        _rightInvertX
                                            ? 'Inverted'
                                            : 'Normal',
                                  ),
                                  _SettingInfoRow(
                                    label:
                                        'Right Y',
                                    value:
                                        _rightInvertY
                                            ? 'Inverted'
                                            : 'Normal',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            SizedBox(
                              width:
                                  double.infinity,
                              height: 54,
                              child:
                                  OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _leftInvertX =
                                        false;
                                    _leftInvertY =
                                        false;
                                    _rightInvertX =
                                        false;
                                    _rightInvertY =
                                        false;
                                  });

                                  setSheetState(
                                    () {},
                                  );
                                },
                                icon:
                                    const Icon(
                                  Icons
                                      .restart_alt_rounded,
                                ),
                                label:
                                    const Text(
                                  'Reset Joystick Settings',
                                  style:
                                      TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 18,
                            ),

                            Text(
                              'Double-tap either joystick to press L3 / R3.',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                color:
                                    Colors.white
                                        .withValues(
                                  alpha: 0.38,
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =============================================================
  // CONTROL BUILDER
  // =============================================================

  Widget _buildControl(
    ControllerElement element,
    double width,
    double height,
  ) {
    final double elementWidth =
        element.width * width;

    final double elementHeight =
        element.height * height;

    switch (element.id) {
      // ===========================================================
      // LT
      // ===========================================================

      case 'lt':
        return _ControllerButton(
          label: 'LT',
          width: elementWidth,
          height: elementHeight,
          fontSize: math.min(
            elementWidth,
            elementHeight,
          ) *
              0.28,
          onDown: () {
            _trigger(
              'Left',
              1,
            );
          },
          onUp: () {
            _trigger(
              'Left',
              0,
            );
          },
        );

      // ===========================================================
      // LB
      // ===========================================================

      case 'lb':
        return _ControllerButton(
          label: 'LB',
          width: elementWidth,
          height: elementHeight,
          fontSize: math.min(
            elementWidth,
            elementHeight,
          ) *
              0.28,
          onDown: () {
            _button(
              'LeftBumper',
              true,
            );
          },
          onUp: () {
            _button(
              'LeftBumper',
              false,
            );
          },
        );

      // ===========================================================
      // RT
      // ===========================================================

      case 'rt':
        return _ControllerButton(
          label: 'RT',
          width: elementWidth,
          height: elementHeight,
          fontSize: math.min(
            elementWidth,
            elementHeight,
          ) *
              0.28,
          onDown: () {
            _trigger(
              'Right',
              1,
            );
          },
          onUp: () {
            _trigger(
              'Right',
              0,
            );
          },
        );

      // ===========================================================
      // RB
      // ===========================================================

      case 'rb':
        return _ControllerButton(
          label: 'RB',
          width: elementWidth,
          height: elementHeight,
          fontSize: math.min(
            elementWidth,
            elementHeight,
          ) *
              0.28,
          onDown: () {
            _button(
              'RightBumper',
              true,
            );
          },
          onUp: () {
            _button(
              'RightBumper',
              false,
            );
          },
        );

      // ===========================================================
      // LEFT STICK
      // ===========================================================

      case 'left_stick':
        return Center(
          child: SizedBox.square(
            dimension: math.min(
              elementWidth,
              elementHeight,
            ),
            child: _AnalogStick(
              size: math.min(
                elementWidth,
                elementHeight,
              ),
              label: 'LS',
              onChanged: (
                x,
                y,
              ) {
                _stick(
                  'Left',
                  x,
                  y,
                );
              },
              onDoubleTap: () {
                _stickClick(
                  'LeftStick',
                );
              },
            ),
          ),
        );

      // ===========================================================
      // RIGHT STICK
      // ===========================================================

      case 'right_stick':
        return Center(
          child: SizedBox.square(
            dimension: math.min(
              elementWidth,
              elementHeight,
            ),
            child: _AnalogStick(
              size: math.min(
                elementWidth,
                elementHeight,
              ),
              label: 'RS',
              onChanged: (
                x,
                y,
              ) {
                _stick(
                  'Right',
                  x,
                  y,
                );
              },
              onDoubleTap: () {
                _stickClick(
                  'RightStick',
                );
              },
            ),
          ),
        );

      // ===========================================================
      // D-PAD
      // ===========================================================

      case 'dpad':
        return Center(
          child: SizedBox.square(
            dimension: math.min(
              elementWidth,
              elementHeight,
            ),
            child: _DPad(
              size: math.min(
                elementWidth,
                elementHeight,
              ),
              onUp: (pressed) {
                _button(
                  'DPadUp',
                  pressed,
                );
              },
              onDown: (pressed) {
                _button(
                  'DPadDown',
                  pressed,
                );
              },
              onLeft: (pressed) {
                _button(
                  'DPadLeft',
                  pressed,
                );
              },
              onRight: (pressed) {
                _button(
                  'DPadRight',
                  pressed,
                );
              },
            ),
          ),
        );

      // ===========================================================
      // A
      // ===========================================================

      case 'a':
        return _FaceButton(
          label: 'A',
          color: const Color(
            0xFF43C95A,
          ),
          size: math.min(
            elementWidth,
            elementHeight,
          ),
          onDown: () {
            _button(
              'A',
              true,
            );
          },
          onUp: () {
            _button(
              'A',
              false,
            );
          },
        );

      // ===========================================================
      // B
      // ===========================================================

      case 'b':
        return _FaceButton(
          label: 'B',
          color: const Color(
            0xFFE72B2B,
          ),
          size: math.min(
            elementWidth,
            elementHeight,
          ),
          onDown: () {
            _button(
              'B',
              true,
            );
          },
          onUp: () {
            _button(
              'B',
              false,
            );
          },
        );

      // ===========================================================
      // X
      // ===========================================================

      case 'x':
        return _FaceButton(
          label: 'X',
          color: const Color(
            0xFF2796E8,
          ),
          size: math.min(
            elementWidth,
            elementHeight,
          ),
          onDown: () {
            _button(
              'X',
              true,
            );
          },
          onUp: () {
            _button(
              'X',
              false,
            );
          },
        );

      // ===========================================================
      // Y
      // ===========================================================

      case 'y':
        return _FaceButton(
          label: 'Y',
          color: const Color(
            0xFFFFD21C,
          ),
          size: math.min(
            elementWidth,
            elementHeight,
          ),
          onDown: () {
            _button(
              'Y',
              true,
            );
          },
          onUp: () {
            _button(
              'Y',
              false,
            );
          },
        );

      // ===========================================================
      // BACK
      // ===========================================================

      case 'back':
        return _ControllerButton(
          label: 'BACK',
          width: elementWidth,
          height: elementHeight,
          fontSize: math.min(
            elementWidth,
            elementHeight,
          ) *
              0.23,
          onDown: () {
            _button(
              'Back',
              true,
            );
          },
          onUp: () {
            _button(
              'Back',
              false,
            );
          },
        );

      // ===========================================================
      // START
      // ===========================================================

      case 'start':
        return _ControllerButton(
          label: 'START',
          width: elementWidth,
          height: elementHeight,
          fontSize: math.min(
            elementWidth,
            elementHeight,
          ) *
              0.23,
          onDown: () {
            _button(
              'Start',
              true,
            );
          },
          onUp: () {
            _button(
              'Start',
              false,
            );
          },
        );

      // ===========================================================
      // SETTINGS
      // ===========================================================

      case 'settings':
        return Center(
          child: _SettingsCenterButton(
            size: math.min(
              elementWidth,
              elementHeight,
            ),
            onPressed: _showSettings,
          ),
        );

      // ===========================================================
      // UNKNOWN ELEMENT
      // ===========================================================

      default:
        return const SizedBox.shrink();
    }
  }

  // =============================================================
  // BUILD
  // =============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_layoutLoading || _layout == null) {
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

        await _closeController();
      },
      child: Scaffold(
        backgroundColor:
            const Color(0xFF050505),
        body: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final double width =
                constraints.maxWidth;

            final double height =
                constraints.maxHeight;

            return Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0xFF050505),
                  ),
                ),

                // ===================================================
                // CONNECTION STATUS
                // ===================================================

                Positioned(
                  top: height * 0.028,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration:
                              BoxDecoration(
                            color: widget
                                    .socket
                                    .isConnected
                                ? const Color(
                                    0xFF35D66F,
                                  )
                                : const Color(
                                    0xFF999999,
                                  ),
                            shape:
                                BoxShape.circle,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Text(
                          widget.socket
                                  .isConnected
                              ? 'Connected'
                              : 'Disconnected',
                          style:
                              const TextStyle(
                            color: Color(
                              0xFFE4E4E4,
                            ),
                            fontSize: 23,
                            fontWeight:
                                FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===================================================
                // CUSTOM LAYOUT
                // ===================================================

                ..._layout!.elements
                    .where(
                      (element) =>
                          element.visible,
                    )
                    .map(
                      (element) {
                        return LayoutElement(
                          element: element,
                          containerWidth: width,
                          containerHeight:
                              height,
                          child: _buildControl(
                            element,
                            width,
                            height,
                          ),
                        );
                      },
                    ),

                // ===================================================
                // SLOT
                // ===================================================

                Positioned(
                  bottom: height * 0.012,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'P${widget.slot}',
                      style: TextStyle(
                        color: Colors.white
                            .withValues(
                          alpha: 0.25,
                        ),
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // =============================================================
  // DISPOSE
  // =============================================================

  @override
  void dispose() {
    _layoutController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    super.dispose();
  }
}

// =============================================================
// CENTER SETTINGS BUTTON
// =============================================================

class _SettingsCenterButton
    extends StatefulWidget {
  final double size;
  final VoidCallback onPressed;

  const _SettingsCenterButton({
    required this.size,
    required this.onPressed,
  });

  @override
  State<_SettingsCenterButton> createState() =>
      _SettingsCenterButtonState();
}

class _SettingsCenterButtonState
    extends State<_SettingsCenterButton> {
  bool _pressed = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });

        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 60),
        width: widget.size,
        height: widget.size,
        decoration:
            BoxDecoration(
          shape: BoxShape.circle,
          color: _pressed
              ? const Color(0xFF292D34)
              : const Color(0xFF151515),
          border: Border.all(
            color: const Color(
              0xFF353535,
            ),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.settings_rounded,
          color: const Color(
            0xFFE8E8E8,
          ),
          size: widget.size * 0.38,
        ),
      ),
    );
  }
}

// =============================================================
// CONTROLLER BUTTON
// =============================================================

class _ControllerButton
    extends StatefulWidget {
  final String label;
  final double width;
  final double height;
  final double fontSize;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const _ControllerButton({
    required this.label,
    required this.width,
    required this.height,
    required this.fontSize,
    required this.onDown,
    required this.onUp,
  });

  @override
  State<_ControllerButton> createState() =>
      _ControllerButtonState();
}

class _ControllerButtonState
    extends State<_ControllerButton> {
  bool _pressed = false;

  void _press() {
    if (_pressed) {
      return;
    }

    setState(() {
      _pressed = true;
    });

    widget.onDown();
  }

  void _release() {
    if (!_pressed) {
      return;
    }

    setState(() {
      _pressed = false;
    });

    widget.onUp();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTapDown: (_) => _press(),
      onTapUp: (_) => _release(),
      onTapCancel: _release,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 60),
        width: widget.width,
        height: widget.height,
        decoration:
            BoxDecoration(
          color: _pressed
              ? const Color(0xFF2A2D33)
              : const Color(0xFF151515),
          borderRadius:
              BorderRadius.circular(25),
          border: Border.all(
            color: const Color(
              0xFF353535,
            ),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: const Color(
                0xFFE8E8E8,
              ),
              fontSize:
                  widget.fontSize,
              fontWeight:
                  FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// ANALOG STICK
// =============================================================

class _AnalogStick
    extends StatefulWidget {
  final double size;
  final String label;

  final void Function(
    double x,
    double y,
  ) onChanged;

  final VoidCallback onDoubleTap;

  const _AnalogStick({
    required this.size,
    required this.label,
    required this.onChanged,
    required this.onDoubleTap,
  });

  @override
  State<_AnalogStick> createState() =>
      _AnalogStickState();
}

class _AnalogStickState
    extends State<_AnalogStick> {
  Offset _position = Offset.zero;

  void _update(
    Offset localPosition,
  ) {
    final Offset center = Offset(
      widget.size / 2,
      widget.size / 2,
    );

    final double maxRadius =
        widget.size * 0.335;

    Offset delta =
        localPosition - center;

    if (delta.distance >
        maxRadius) {
      delta = Offset.fromDirection(
        delta.direction,
        maxRadius,
      );
    }

    final double x =
        (delta.dx / maxRadius)
            .clamp(-1.0, 1.0);

    final double y =
        (delta.dy / maxRadius)
            .clamp(-1.0, 1.0);

    setState(() {
      _position = delta;
    });

    widget.onChanged(
      x,
      y,
    );
  }

  void _release() {
    setState(() {
      _position = Offset.zero;
    });

    widget.onChanged(
      0,
      0,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onDoubleTap:
          widget.onDoubleTap,
      onPanDown: (details) {
        _update(
          details.localPosition,
        );
      },
      onPanUpdate: (details) {
        _update(
          details.localPosition,
        );
      },
      onPanEnd: (_) =>
          _release(),
      onPanCancel: _release,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _StickPainter(
            position: _position,
            label: widget.label,
          ),
        ),
      ),
    );
  }
}

// =============================================================
// STICK PAINTER
// =============================================================

class _StickPainter
    extends CustomPainter {
  final Offset position;
  final String label;

  const _StickPainter({
    required this.position,
    required this.label,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Offset center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final double outerRadius =
        size.width * 0.455;

    final double innerRadius =
        size.width * 0.285;

    final Paint outerPaint = Paint()
      ..color =
          const Color(0xFF151515)
      ..style =
          PaintingStyle.fill;

    final Paint outerBorder = Paint()
      ..color =
          const Color(0xFFE91B23)
      ..style =
          PaintingStyle.stroke
      ..strokeWidth =
          size.width * 0.050;

    final Paint innerBorder = Paint()
      ..color =
          const Color(0xFF383838)
      ..style =
          PaintingStyle.stroke
      ..strokeWidth =
          size.width * 0.018;

    canvas.drawCircle(
      center,
      outerRadius,
      outerPaint,
    );

    canvas.drawCircle(
      center,
      outerRadius,
      outerBorder,
    );

    canvas.drawCircle(
      center,
      innerRadius,
      innerBorder,
    );

    final Offset knobCenter =
        center + position;

    final Paint knobPaint = Paint()
      ..color =
          const Color(0xFF101010)
      ..style =
          PaintingStyle.fill;

    canvas.drawCircle(
      knobCenter,
      innerRadius * 0.78,
      knobPaint,
    );

    final Paint knobBorder = Paint()
      ..color =
          const Color(0xFF3C3C3C)
      ..style =
          PaintingStyle.stroke
      ..strokeWidth =
          size.width * 0.012;

    canvas.drawCircle(
      knobCenter,
      innerRadius * 0.78,
      knobBorder,
    );
  }

  @override
  bool shouldRepaint(
    covariant _StickPainter oldDelegate,
  ) {
    return oldDelegate.position !=
            position ||
        oldDelegate.label != label;
  }
}

// =============================================================
// D-PAD
// =============================================================

class _DPad
    extends StatelessWidget {
  final double size;

  final ValueChanged<bool> onUp;
  final ValueChanged<bool> onDown;
  final ValueChanged<bool> onLeft;
  final ValueChanged<bool> onRight;

  const _DPad({
    required this.size,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final double buttonSize =
        size * 0.35;

    final double center =
        size / 2;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left:
                center - buttonSize / 2,
            top: 0,
            child: _DPadButton(
              size: buttonSize,
              icon: Icons
                  .keyboard_arrow_up_rounded,
              onDown: () =>
                  onUp(true),
              onUp: () =>
                  onUp(false),
            ),
          ),
          Positioned(
            left:
                center - buttonSize / 2,
            bottom: 0,
            child: _DPadButton(
              size: buttonSize,
              icon: Icons
                  .keyboard_arrow_down_rounded,
              onDown: () =>
                  onDown(true),
              onUp: () =>
                  onDown(false),
            ),
          ),
          Positioned(
            left: 0,
            top:
                center - buttonSize / 2,
            child: _DPadButton(
              size: buttonSize,
              icon: Icons
                  .keyboard_arrow_left_rounded,
              onDown: () =>
                  onLeft(true),
              onUp: () =>
                  onLeft(false),
            ),
          ),
          Positioned(
            right: 0,
            top:
                center - buttonSize / 2,
            child: _DPadButton(
              size: buttonSize,
              icon: Icons
                  .keyboard_arrow_right_rounded,
              onDown: () =>
                  onRight(true),
              onUp: () =>
                  onRight(false),
            ),
          ),
          Positioned(
            left:
                center - buttonSize / 2,
            top:
                center - buttonSize / 2,
            child: Container(
              width: buttonSize,
              height: buttonSize,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFF151515,
                ),
                borderRadius:
                    BorderRadius.circular(
                  9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// D-PAD BUTTON
// =============================================================

class _DPadButton
    extends StatefulWidget {
  final double size;
  final IconData icon;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const _DPadButton({
    required this.size,
    required this.icon,
    required this.onDown,
    required this.onUp,
  });

  @override
  State<_DPadButton> createState() =>
      _DPadButtonState();
}

class _DPadButtonState
    extends State<_DPadButton> {
  bool _pressed = false;

  void _press() {
    if (_pressed) {
      return;
    }

    setState(() {
      _pressed = true;
    });

    widget.onDown();
  }

  void _release() {
    if (!_pressed) {
      return;
    }

    setState(() {
      _pressed = false;
    });

    widget.onUp();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTapDown: (_) => _press(),
      onTapUp: (_) => _release(),
      onTapCancel: _release,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 50),
        width: widget.size,
        height: widget.size,
        decoration:
            BoxDecoration(
          color: _pressed
              ? const Color(
                  0xFF292929,
                )
              : const Color(
                  0xFF151515,
                ),
          borderRadius:
              BorderRadius.circular(8),
        ),
        child: Icon(
          widget.icon,
          color: const Color(
            0xFFE7E7E7,
          ),
          size:
              widget.size * 0.56,
        ),
      ),
    );
  }
}

// =============================================================
// FACE BUTTON
// =============================================================

class _FaceButton
    extends StatefulWidget {
  final String label;
  final Color color;
  final double size;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const _FaceButton({
    required this.label,
    required this.color,
    required this.size,
    required this.onDown,
    required this.onUp,
  });

  @override
  State<_FaceButton> createState() =>
      _FaceButtonState();
}

class _FaceButtonState
    extends State<_FaceButton> {
  bool _pressed = false;

  void _press() {
    if (_pressed) {
      return;
    }

    setState(() {
      _pressed = true;
    });

    widget.onDown();
  }

  void _release() {
    if (!_pressed) {
      return;
    }

    setState(() {
      _pressed = false;
    });

    widget.onUp();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTapDown: (_) => _press(),
      onTapUp: (_) => _release(),
      onTapCancel: _release,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 60),
        width: widget.size,
        height: widget.size,
        decoration:
            BoxDecoration(
          shape:
              BoxShape.circle,
          color: _pressed
              ? const Color(
                  0xFF292929,
                )
              : const Color(
                  0xFF101010,
                ),
          border: Border.all(
            color: const Color(
              0xFF373737,
            ),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.color,
              fontSize:
                  widget.size * 0.34,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// SETTINGS SECTION
// =============================================================

class _SettingsSection
    extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: const Color(
          0xFF1B1E24,
        ),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: const Color(
            0xFF2D323B,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              color: Color(
                0xFFE3E5E9,
              ),
              fontSize: 14,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          child,
        ],
      ),
    );
  }
}

// =============================================================
// SETTINGS SWITCH
// =============================================================

class _SettingsSwitch
    extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      contentPadding:
          EdgeInsets.zero,
      title: Text(
        title,
        style:
            const TextStyle(
          color: Color(
            0xFFE8E9EC,
          ),
          fontSize: 16,
          fontWeight:
              FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding:
            const EdgeInsets.only(
          top: 3,
        ),
        child: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white
                .withValues(
              alpha: 0.48,
            ),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// =============================================================
// SETTINGS INFO ROW
// =============================================================

class _SettingInfoRow
    extends StatelessWidget {
  final String label;
  final String value;

  const _SettingInfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white
                    .withValues(
                  alpha: 0.55,
                ),
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style:
                const TextStyle(
              color: Color(
                0xFFE5E7EB,
              ),
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}