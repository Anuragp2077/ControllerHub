import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pairing_info.dart';
import '../services/client_identity.dart';
import '../services/controllerhub_socket.dart';
import 'controller_screen.dart';
import 'pairing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ControllerHubSocket _socket =
      ControllerHubSocket();

  String _status = 'Not connected';

  String? _serverAddress;

  PairingInfo? _pairing;

  int? _slot;

  bool _controllerScreenOpened = false;

  @override
  void initState() {
    super.initState();

    // Home screen is always portrait.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _socket.messages.listen(
      _handleSocketMessage,
    );
  }

  // =============================================================
  // SOCKET EVENTS
  // =============================================================

  void _handleSocketMessage(
    Map<String, dynamic> message,
  ) {
    if (!mounted) {
      return;
    }

    final String? type =
        message['type']?.toString();

    switch (type) {
      case 'connected':
        setState(() {
          _status = 'Connected';
        });
        break;

      case 'slot':
        final dynamic slotValue =
            message['slot'];

        if (slotValue is int) {
          setState(() {
            _slot = slotValue;
            _status =
                'Controller $slotValue connected';
          });

          _openControllerScreen(
            slotValue,
          );
        }
        break;

      case 'error':
        setState(() {
          _status =
              message['message']?.toString() ??
                  'Server error';
        });
        break;

      case 'disconnected':
        setState(() {
          _status = _pairing != null
              ? 'Paired - disconnected'
              : 'Disconnected';
        });
        break;

      case 'connection_error':
        setState(() {
          _status =
              message['message']?.toString() ??
                  'Connection failed';
        });
        break;
    }
  }

  // =============================================================
  // OPEN CONTROLLER
  // =============================================================

  void _openControllerScreen(
    int slot,
  ) {
    if (_controllerScreenOpened ||
        !mounted) {
      return;
    }

    _controllerScreenOpened = true;

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => ControllerScreen(
          socket: _socket,
          slot: slot,
        ),
      ),
    )
        .then((_) {
      _controllerScreenOpened = false;

      if (!mounted) {
        return;
      }

      // Make sure Home returns to portrait.
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      setState(() {
        _status = _socket.isConnected
            ? 'Connected'
            : _pairing != null
                ? 'Paired - disconnected'
                : 'Disconnected';
      });
    });
  }

  // =============================================================
  // SCAN QR
  // =============================================================

  Future<void> _scanQrCode(
    BuildContext context,
  ) async {
    final String? result =
        await Navigator.of(context)
            .push<String>(
      MaterialPageRoute(
        builder: (_) =>
            const PairingScreen(),
      ),
    );

    if (!context.mounted ||
        result == null) {
      return;
    }

    final PairingInfo? pairing =
        PairingInfo.parse(result);

    if (pairing == null) {
      setState(() {
        _status =
            'Invalid pairing QR code';
      });

      return;
    }

    setState(() {
      _pairing = pairing;

      _serverAddress =
          '${pairing.host}:${pairing.port}';

      _status = 'Connecting...';
    });

    await _connectToPairing(
      pairing,
    );
  }

  // =============================================================
  // RECONNECT
  // =============================================================

  Future<void> _reconnect() async {
    final PairingInfo? pairing =
        _pairing;

    if (pairing == null) {
      return;
    }

    setState(() {
      _status = 'Reconnecting...';
    });

    await _connectToPairing(
      pairing,
    );
  }

  Future<void> _connectToPairing(
    PairingInfo pairing,
  ) async {
    try {
      final String clientId =
          await ClientIdentity
              .getClientId();

      await _socket.connect(
        serverHost: pairing.host,
        serverPort: pairing.port,
        token: pairing.token,
        clientId: clientId,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _status = 'Connection failed';
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Could not connect: $error',
          ),
        ),
      );
    }
  }

  // =============================================================
  // MANUAL CONNECTION
  // =============================================================

  void _enterServerManually(
    BuildContext context,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Manual connection will be added later.',
        ),
      ),
    );
  }

  // =============================================================
  // FORGET PAIRING
  // =============================================================

  Future<void> _forgetPairing() async {
    if (_socket.isConnected) {
      await _socket.disconnect();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _pairing = null;
      _serverAddress = null;
      _slot = null;
      _status = 'Not connected';
    });
  }

  // =============================================================
  // DISPOSE
  // =============================================================

  @override
  void dispose() {
    _socket.dispose();

    super.dispose();
  }

  // =============================================================
  // UI
  // =============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool connected =
        _socket.isConnected;

    final bool paired =
        _pairing != null;

    return Scaffold(
      backgroundColor:
          const Color(0xFF0D0F14),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),

                  // =================================================
                  // APP ICON
                  // =================================================

                  Container(
                    width: 100,
                    height: 100,
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        28,
                      ),
                      color: Colors.white
                          .withValues(
                        alpha: 0.06,
                      ),
                      border:
                          Border.all(
                        color: Colors.white
                            .withValues(
                          alpha: 0.08,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.gamepad_rounded,
                      size: 54,
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // =================================================
                  // TITLE
                  // =================================================

                  const Text(
                    'ControllerHub',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight:
                          FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    'Turn your phone into a game controller',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: Colors.white
                          .withValues(
                        alpha: 0.60,
                      ),
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                    height: 42,
                  ),

                  // =================================================
                  // PAIRED CARD
                  // =================================================

                  if (paired) ...[
                    _PairedCard(
                      connected:
                          connected,
                      slot: _slot,
                      serverAddress:
                          _serverAddress,
                      onOpen:
                          connected &&
                                  _slot != null
                              ? () {
                                  _openControllerScreen(
                                    _slot!,
                                  );
                                }
                              : null,
                      onReconnect:
                          !connected
                              ? _reconnect
                              : null,
                      onForget:
                          _forgetPairing,
                    ),

                    const SizedBox(
                      height: 18,
                    ),
                  ],

                  // =================================================
                  // SCAN
                  // =================================================

                  SizedBox(
                    width:
                        double.infinity,
                    height: 58,
                    child:
                        FilledButton.icon(
                      onPressed:
                          connected
                              ? null
                              : () {
                                  _scanQrCode(
                                    context,
                                  );
                                },
                      icon:
                          const Icon(
                        Icons
                            .qr_code_scanner_rounded,
                      ),
                      label:
                          const Text(
                        'Scan New QR Code',
                        style:
                            TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // =================================================
                  // MANUAL
                  // =================================================

                  SizedBox(
                    width:
                        double.infinity,
                    height: 58,
                    child:
                        OutlinedButton.icon(
                      onPressed:
                          connected
                              ? null
                              : () {
                                  _enterServerManually(
                                    context,
                                  );
                                },
                      icon:
                          const Icon(
                        Icons.link_rounded,
                      ),
                      label:
                          const Text(
                        'Enter Server Manually',
                        style:
                            TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 34,
                  ),

                  // =================================================
                  // STATUS
                  // =================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,
                          color:
                              connected
                                  ? const Color(
                                      0xFF35D66F,
                                    )
                                  : paired
                                      ? const Color(
                                          0xFFFFB020,
                                        )
                                      : const Color(
                                          0xFF777777,
                                        ),
                        ),
                      ),

                      const SizedBox(
                        width: 9,
                      ),

                      Flexible(
                        child: Text(
                          _status,
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            color: Colors
                                .white
                                .withValues(
                              alpha: 0.60,
                            ),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_serverAddress !=
                      null) ...[
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      _serverAddress!,
                      style: TextStyle(
                        color: Colors.white
                            .withValues(
                          alpha: 0.35,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 34,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// PAIRED CARD
// =============================================================

class _PairedCard
    extends StatelessWidget {
  final bool connected;
  final int? slot;
  final String? serverAddress;
  final VoidCallback? onOpen;
  final VoidCallback? onReconnect;
  final VoidCallback onForget;

  const _PairedCard({
    required this.connected,
    required this.slot,
    required this.serverAddress,
    required this.onOpen,
    required this.onReconnect,
    required this.onForget,
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
          0xFF151922,
        ),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(
            0xFF303642,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color: connected
                      ? const Color(
                          0xFF173C28,
                        )
                      : const Color(
                          0xFF3C321A,
                        ),
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  connected
                      ? Icons
                          .sports_esports_rounded
                      : Icons
                          .link_rounded,
                  color: connected
                      ? const Color(
                          0xFF35D66F,
                        )
                      : const Color(
                          0xFFFFB020,
                        ),
                  size: 22,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      slot != null
                          ? 'Controller P$slot'
                          : 'Paired Controller',
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      connected
                          ? 'Currently connected'
                          : 'Paired • ready to reconnect',
                      style: TextStyle(
                        color: Colors
                            .white
                            .withValues(
                          alpha: 0.48,
                        ),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (serverAddress !=
              null) ...[
            const SizedBox(
              height: 14,
            ),
            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                serverAddress!,
                style: TextStyle(
                  color: Colors.white
                      .withValues(
                    alpha: 0.35,
                  ),
                  fontSize: 12,
                ),
              ),
            ),
          ],

          const SizedBox(
            height: 16,
          ),

          if (connected &&
              onOpen != null)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(
                  Icons
                      .sports_esports_rounded,
                ),
                label: const Text(
                  'OPEN CONTROLLER',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ),

          if (!connected &&
              onReconnect != null)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: onReconnect,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'RECONNECT',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ),

          const SizedBox(
            height: 8,
          ),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton.icon(
              onPressed: onForget,
              icon: const Icon(
                Icons.link_off_rounded,
                size: 18,
              ),
              label: const Text(
                'Forget Pairing',
              ),
            ),
          ),
        ],
      ),
    );
  }
}