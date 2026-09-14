import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/controllerhub_socket.dart';

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

    // Controller is always landscape.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
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

    // Return to portrait.
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

                    // Drag handle
                    Container(
                      width: 48,
                      height: 5,
                      decoration:
                          BoxDecoration(
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

                    // Header
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
                              Icons
                                  .settings_rounded,
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

                    // =================================================
                    // SCROLLABLE SETTINGS
                    // =================================================

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

                            // =================================================
                            // RESET
                            // =================================================

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
                                color: Colors.white
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
  // BUILD
  // =============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
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
              // LEFT TRIGGERS
              // ===================================================

              Positioned(
                left: width * 0.022,
                top: height * 0.035,
                child: Row(
                  children: [
                    _ControllerButton(
                      label: 'LT',
                      width:
                          width * 0.110,
                      height:
                          height * 0.105,
                      fontSize: 27,
                      onDown: () =>
                          _trigger(
                        'Left',
                        1,
                      ),
                      onUp: () =>
                          _trigger(
                        'Left',
                        0,
                      ),
                    ),

                    SizedBox(
                      width:
                          width * 0.010,
                    ),

                    _ControllerButton(
                      label: 'LB',
                      width:
                          width * 0.102,
                      height:
                          height * 0.105,
                      fontSize: 27,
                      onDown: () =>
                          _button(
                        'LeftBumper',
                        true,
                      ),
                      onUp: () =>
                          _button(
                        'LeftBumper',
                        false,
                      ),
                    ),
                  ],
                ),
              ),

              // ===================================================
              // RIGHT TRIGGERS
              // ===================================================

              Positioned(
                right: width * 0.022,
                top: height * 0.035,
                child: Row(
                  children: [
                    _ControllerButton(
                      label: 'RB',
                      width:
                          width * 0.102,
                      height:
                          height * 0.105,
                      fontSize: 27,
                      onDown: () =>
                          _button(
                        'RightBumper',
                        true,
                      ),
                      onUp: () =>
                          _button(
                        'RightBumper',
                        false,
                      ),
                    ),

                    SizedBox(
                      width:
                          width * 0.010,
                    ),

                    _ControllerButton(
                      label: 'RT',
                      width:
                          width * 0.110,
                      height:
                          height * 0.105,
                      fontSize: 27,
                      onDown: () =>
                          _trigger(
                        'Right',
                        1,
                      ),
                      onUp: () =>
                          _trigger(
                        'Right',
                        0,
                      ),
                    ),
                  ],
                ),
              ),

              // ===================================================
              // LEFT STICK
              // ===================================================

              Positioned(
                left: width * 0.067,
                top: height * 0.150,
                child: _AnalogStick(
                  size: math.min(
                    width * 0.145,
                    height * 0.315,
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

              // ===================================================
              // D-PAD
              // ===================================================

              Positioned(
                left: width * 0.045,
                bottom: height * 0.075,
                child: _DPad(
                  size: math.min(
                    width * 0.190,
                    height * 0.390,
                  ),
                  onUp: (pressed) =>
                      _button(
                    'DPadUp',
                    pressed,
                  ),
                  onDown: (pressed) =>
                      _button(
                    'DPadDown',
                    pressed,
                  ),
                  onLeft: (pressed) =>
                      _button(
                    'DPadLeft',
                    pressed,
                  ),
                  onRight: (pressed) =>
                      _button(
                    'DPadRight',
                    pressed,
                  ),
                ),
              ),

              // ===================================================
              // CENTER BUTTONS
              //
              // BACK -> SETTINGS -> START
              // ===================================================

              Positioned(
                top: height * 0.270,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    _ControllerButton(
                      label: 'BACK',
                      width:
                          width * 0.090,
                      height:
                          height * 0.105,
                      fontSize: 21,
                      onDown: () =>
                          _button(
                        'Back',
                        true,
                      ),
                      onUp: () =>
                          _button(
                        'Back',
                        false,
                      ),
                    ),

                    SizedBox(
                      width:
                          width * 0.020,
                    ),

                    _SettingsCenterButton(
                      size:
                          height * 0.115,
                      onPressed:
                          _showSettings,
                    ),

                    SizedBox(
                      width:
                          width * 0.020,
                    ),

                    _ControllerButton(
                      label: 'START',
                      width:
                          width * 0.090,
                      height:
                          height * 0.105,
                      fontSize: 21,
                      onDown: () =>
                          _button(
                        'Start',
                        true,
                      ),
                      onUp: () =>
                          _button(
                        'Start',
                        false,
                      ),
                    ),
                  ],
                ),
              ),

              // ===================================================
              // RIGHT STICK
              // ===================================================

              Positioned(
                left: width * 0.497,
                top: height * 0.475,
                child: _AnalogStick(
                  size: math.min(
                    width * 0.145,
                    height * 0.315,
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

              // ===================================================
              // ABXY
              // ===================================================

              Positioned(
                right: width * 0.065,
                bottom: height * 0.060,
                child: _FaceButtons(
                  buttonSize: math.min(
                    width * 0.100,
                    height * 0.190,
                  ),
                  onA: (pressed) =>
                      _button(
                    'A',
                    pressed,
                  ),
                  onB: (pressed) =>
                      _button(
                    'B',
                    pressed,
                  ),
                  onX: (pressed) =>
                      _button(
                    'X',
                    pressed,
                  ),
                  onY: (pressed) =>
                      _button(
                    'Y',
                    pressed,
                  ),
                ),
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
    // Ensure the next screen is portrait.
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
// FACE BUTTONS
// =============================================================

class _FaceButtons
    extends StatelessWidget {
  final double buttonSize;

  final ValueChanged<bool> onA;
  final ValueChanged<bool> onB;
  final ValueChanged<bool> onX;
  final ValueChanged<bool> onY;

  const _FaceButtons({
    required this.buttonSize,
    required this.onA,
    required this.onB,
    required this.onX,
    required this.onY,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final double total =
        buttonSize * 2.45;

    final double center =
        total / 2;

    return SizedBox(
      width: total,
      height: total,
      child: Stack(
        children: [
          // Y
          Positioned(
            left:
                center - buttonSize / 2,
            top: 0,
            child: _FaceButton(
              label: 'Y',
              color: const Color(
                0xFFFFD21C,
              ),
              size: buttonSize,
              onDown: () =>
                  onY(true),
              onUp: () =>
                  onY(false),
            ),
          ),

          // B
          Positioned(
            right: 0,
            top:
                center - buttonSize / 2,
            child: _FaceButton(
              label: 'B',
              color: const Color(
                0xFFE72B2B,
              ),
              size: buttonSize,
              onDown: () =>
                  onB(true),
              onUp: () =>
                  onB(false),
            ),
          ),

          // A
          Positioned(
            left:
                center - buttonSize / 2,
            bottom: 0,
            child: _FaceButton(
              label: 'A',
              color: const Color(
                0xFF43C95A,
              ),
              size: buttonSize,
              onDown: () =>
                  onA(true),
              onUp: () =>
                  onA(false),
            ),
          ),

          // X
          Positioned(
            left: 0,
            top:
                center - buttonSize / 2,
            child: _FaceButton(
              label: 'X',
              color: const Color(
                0xFF2796E8,
              ),
              size: buttonSize,
              onDown: () =>
                  onX(true),
              onUp: () =>
                  onX(false),
            ),
          ),
        ],
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