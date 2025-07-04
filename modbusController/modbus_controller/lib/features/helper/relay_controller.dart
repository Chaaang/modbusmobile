import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class RelayController {
  final String ip;
  final int port;

  RelayController({required this.ip, required this.port});

  static final Map<int, Map<String, List<int>>> _relayCommands = {
    0: {
      'on': [0x01, 0x05, 0x00, 0x00, 0xFF, 0x00, 0x8C, 0x3A],
      'off': [0x01, 0x05, 0x00, 0x00, 0x00, 0x00, 0xCD, 0xCA],
    },
    1: {
      'on': [0x01, 0x05, 0x00, 0x01, 0xFF, 0x00, 0xDD, 0xFA],
      'off': [0x01, 0x05, 0x00, 0x01, 0x00, 0x00, 0x9C, 0x0A],
    },
    2: {
      'on': [0x01, 0x05, 0x00, 0x02, 0xFF, 0x00, 0x2D, 0xFA],
      'off': [0x01, 0x05, 0x00, 0x02, 0x00, 0x00, 0x6C, 0x0A],
    },
    3: {
      'on': [0x01, 0x05, 0x00, 0x03, 0xFF, 0x00, 0x7C, 0x3A],
      'off': [0x01, 0x05, 0x00, 0x03, 0x00, 0x00, 0x3D, 0xCA],
    },
    4: {
      'on': [0x01, 0x05, 0x00, 0x04, 0xFF, 0x00, 0xCD, 0xFB],
      'off': [0x01, 0x05, 0x00, 0x04, 0x00, 0x00, 0x8C, 0x0B],
    },
    5: {
      'on': [0x01, 0x05, 0x00, 0x05, 0xFF, 0x00, 0x9C, 0x3B],
      'off': [0x01, 0x05, 0x00, 0x05, 0x00, 0x00, 0xDD, 0xCB],
    },
    6: {
      'on': [0x01, 0x05, 0x00, 0x06, 0xFF, 0x00, 0x6C, 0x3B],
      'off': [0x01, 0x05, 0x00, 0x06, 0x00, 0x00, 0x2D, 0xCB],
    },
    7: {
      'on': [0x01, 0x05, 0x00, 0x07, 0xFF, 0x00, 0x3D, 0xFB],
      'off': [0x01, 0x05, 0x00, 0x07, 0x00, 0x00, 0x7C, 0x0B],
    },
  };

  Future<void> toggleRelays(List<int> targetRelays) async {
    Socket? socket;

    try {
      socket = await Socket.connect(ip, port).timeout(Duration(seconds: 3));
      print('Connected to $ip:$port');

      List<int> allRelays = [0, 1, 2, 3, 4];

      // Step 1: Get current status of all relays
      Map<int, bool> currentStatuses = {};
      for (int relay in allRelays) {
        try {
          bool? status = await getRelayStatus(relay);
          currentStatuses[relay] = status ?? false;
        } catch (e) {
          print('Failed to get status for relay $relay: $e');
          currentStatuses[relay] = false;
        }
      }

      // Step 2: Check if only targetRelays are ON
      bool onlyTargetRelaysAreOn = true;
      for (var relay in allRelays) {
        bool isTarget = targetRelays.contains(relay);
        bool isOn = currentStatuses[relay] ?? false;

        if ((isTarget && !isOn) || (!isTarget && isOn)) {
          onlyTargetRelaysAreOn = false;
          break;
        }
      }

      // Step 3: Act accordingly
      if (onlyTargetRelaysAreOn) {
        print('All target relays are already ON. Turning them OFF.');
        for (var relay in targetRelays) {
          final command = _relayCommands[relay]?['off'];
          if (command != null) {
            socket.add(Uint8List.fromList(command));
            print('Turning OFF relay $relay');
            await Future.delayed(Duration(milliseconds: 300));
          }
        }
      } else {
        print('Turning ON target relays and OFF others.');
        for (var relay in allRelays) {
          bool isTarget = targetRelays.contains(relay);
          bool isOn = currentStatuses[relay] ?? false;

          if (isTarget && !isOn) {
            final command = _relayCommands[relay]?['on'];
            if (command != null) {
              socket.add(Uint8List.fromList(command));
              print('Turning ON relay $relay');
              await Future.delayed(Duration(milliseconds: 300));
            }
          } else if (!isTarget && isOn) {
            final command = _relayCommands[relay]?['off'];
            if (command != null) {
              socket.add(Uint8List.fromList(command));
              print('Turning OFF relay $relay');
              await Future.delayed(Duration(milliseconds: 300));
            }
          }
        }
      }
    } catch (e, stackTrace) {
      print('Exception in toggleRelays: $e');
      print(stackTrace);
    } finally {
      await socket?.close();
      print('Socket closed.');
    }
  }

  Future<void> toggleAdmin(List<int> targetRelays, int buttonNumber) async {
    Socket? socket;

    try {
      socket = await Socket.connect(ip, port).timeout(Duration(seconds: 3));
      print('Connected to $ip:$port');

      List<int> allRelays = [0, 1, 2, 3, 4, 5, 6, 7];

      // Get current status of all relays
      Map<int, bool> currentStatuses = {};
      for (int relay in allRelays) {
        try {
          bool? status = await getRelayStatus(relay);
          currentStatuses[relay] = status ?? false;
        } catch (e) {
          print('Failed to get status for relay $relay: $e');
          currentStatuses[relay] = false;
        }
      }

      // ==== BUTTON 1 special logic ====
      if (buttonNumber == 1) {
        bool isRelay1On = currentStatuses[1] ?? false;
        bool isRelay3On = currentStatuses[3] ?? false;
        bool isRelay4On = currentStatuses[4] ?? false;

        if (!isRelay1On || !isRelay3On) {
          print('Button 1 first press: ON 1, 3, 4 → then OFF 4');
          for (var relay in [1, 3, 4]) {
            final command = _relayCommands[relay]?['on'];
            if (command != null) {
              socket.add(Uint8List.fromList(command));
              print('Turning ON relay $relay');
              await Future.delayed(Duration(milliseconds: 300));
            }
          }
          await Future.delayed(Duration(seconds: 1));
          final commandOff4 = _relayCommands[4]?['off'];
          if (commandOff4 != null) {
            socket.add(Uint8List.fromList(commandOff4));
            print('Turning OFF relay 4');
          }
        } else if (isRelay1On && isRelay3On && !isRelay4On) {
          print('Button 1 second press: OFF 1, 3 → blink 7');
          for (var relay in [1, 3]) {
            final command = _relayCommands[relay]?['off'];
            if (command != null) {
              socket.add(Uint8List.fromList(command));
              print('Turning OFF relay $relay');
              await Future.delayed(Duration(milliseconds: 300));
            }
          }

          final commandOn7 = _relayCommands[7]?['on'];
          final commandOff7 = _relayCommands[7]?['off'];
          if (commandOn7 != null && commandOff7 != null) {
            socket.add(Uint8List.fromList(commandOn7));
            print('Turning ON relay 7');
            await Future.delayed(Duration(seconds: 1));
            socket.add(Uint8List.fromList(commandOff7));
            print('Turning OFF relay 7');
          }
        } else {
          print('Button 1 in unknown state — no action taken.');
        }

        await socket.close();
        print('Socket closed.');
        return;
      }

      // ==== BUTTON 2 (relay 5) simple toggle ====
      if (buttonNumber == 2) {
        bool isRelay5On = currentStatuses[5] ?? false;
        final command = _relayCommands[5]?[isRelay5On ? 'off' : 'on'];
        if (command != null) {
          socket.add(Uint8List.fromList(command));
          print('Button 2 toggling relay 5 to ${isRelay5On ? 'OFF' : 'ON'}');
        }
        await socket.close();
        print('Socket closed.');
        return;
      }

      // ==== BUTTON 3 (relay 6) simple toggle ====
      if (buttonNumber == 3) {
        bool isRelay6On = currentStatuses[6] ?? false;
        final command = _relayCommands[6]?[isRelay6On ? 'off' : 'on'];
        if (command != null) {
          socket.add(Uint8List.fromList(command));
          print('Button 3 toggling relay 6 to ${isRelay6On ? 'OFF' : 'ON'}');
        }
        await socket.close();
        print('Socket closed.');
        return;
      }

      // ==== GENERAL TOGGLE FOR OTHER BUTTONS ====
      bool onlyTargetRelaysAreOn = true;
      for (var relay in allRelays) {
        bool isTarget = targetRelays.contains(relay);
        bool isOn = currentStatuses[relay] ?? false;

        if ((isTarget && !isOn) || (!isTarget && isOn)) {
          onlyTargetRelaysAreOn = false;
          break;
        }
      }

      if (onlyTargetRelaysAreOn) {
        print('All target relays are already ON. Turning them OFF.');
        for (var relay in targetRelays) {
          final command = _relayCommands[relay]?['off'];
          if (command != null) {
            socket.add(Uint8List.fromList(command));
            print('Turning OFF relay $relay');
            await Future.delayed(Duration(milliseconds: 300));
          }
        }
      } else {
        print('Turning ON target relays and OFF others.');
        for (var relay in allRelays) {
          bool isTarget = targetRelays.contains(relay);
          bool isOn = currentStatuses[relay] ?? false;

          if (isTarget && !isOn) {
            final command = _relayCommands[relay]?['on'];
            if (command != null) {
              socket.add(Uint8List.fromList(command));
              print('Turning ON relay $relay');
              await Future.delayed(Duration(milliseconds: 300));
            }
          } else if (!isTarget && isOn) {
            final command = _relayCommands[relay]?['off'];
            if (command != null) {
              socket.add(Uint8List.fromList(command));
              print('Turning OFF relay $relay');
              await Future.delayed(Duration(milliseconds: 300));
            }
          }
        }
      }
    } catch (e, stackTrace) {
      print('Exception in toggleRelays: $e');
      print(stackTrace);
    } finally {
      await socket?.close();
      print('Socket closed.');
    }
  }

  // Future<void> toggleAdmin(List<int> targetRelays, int buttonNumber) async {
  //   Socket? socket;

  //   try {
  //     socket = await Socket.connect(ip, port).timeout(Duration(seconds: 3));
  //     print('Connected to $ip:$port');

  //     List<int> allRelays = [0, 1, 2, 3, 4, 5, 6, 7];

  //     // Step 1: Get current status of all relays
  //     Map<int, bool> currentStatuses = {};
  //     for (int relay in allRelays) {
  //       try {
  //         bool? status = await getRelayStatus(relay);
  //         currentStatuses[relay] = status ?? false;
  //       } catch (e) {
  //         print('Failed to get status for relay $relay: $e');
  //         currentStatuses[relay] = false;
  //       }
  //     }

  //     // ===== SPECIAL HANDLING FOR BUTTON 1 =====
  //     if (buttonNumber == 1) {
  //       bool isRelay1On = currentStatuses[1] ?? false;
  //       bool isRelay3On = currentStatuses[3] ?? false;
  //       bool isRelay4On = currentStatuses[4] ?? false;

  //       if (!isRelay1On || !isRelay3On) {
  //         // First press: turn on 1, 3, 4 → after 1s turn off 4
  //         print('Button 1 first press: ON 1, 3, 4 → then OFF 4');
  //         for (var relay in [1, 3, 4]) {
  //           final command = _relayCommands[relay]?['on'];
  //           if (command != null) {
  //             socket.add(Uint8List.fromList(command));
  //             print('Turning ON relay $relay');
  //             await Future.delayed(Duration(milliseconds: 300));
  //           }
  //         }
  //         await Future.delayed(Duration(seconds: 1));
  //         final commandOff4 = _relayCommands[4]?['off'];
  //         if (commandOff4 != null) {
  //           socket.add(Uint8List.fromList(commandOff4));
  //           print('Turning OFF relay 4');
  //         }
  //       } else if (isRelay1On && isRelay3On && !isRelay4On) {
  //         // Second press: turn off 1, 3 → blink 7
  //         print('Button 1 second press: OFF 1, 3 → blink 7');
  //         for (var relay in [1, 3]) {
  //           final command = _relayCommands[relay]?['off'];
  //           if (command != null) {
  //             socket.add(Uint8List.fromList(command));
  //             print('Turning OFF relay $relay');
  //             await Future.delayed(Duration(milliseconds: 300));
  //           }
  //         }

  //         final commandOn7 = _relayCommands[7]?['on'];
  //         final commandOff7 = _relayCommands[7]?['off'];
  //         if (commandOn7 != null && commandOff7 != null) {
  //           socket.add(Uint8List.fromList(commandOn7));
  //           print('Turning ON relay 7');
  //           await Future.delayed(Duration(seconds: 1));
  //           socket.add(Uint8List.fromList(commandOff7));
  //           print('Turning OFF relay 7');
  //         }
  //       } else {
  //         print('Button 1 in unknown state — no action taken.');
  //       }

  //       await socket.close();
  //       print('Socket closed.');
  //       return; // Exit early
  //     }

  //     // ===== GENERAL TOGGLE LOGIC FOR OTHER BUTTONS =====

  //     // Step 2: Check if only targetRelays are ON
  //     bool onlyTargetRelaysAreOn = true;
  //     for (var relay in allRelays) {
  //       bool isTarget = targetRelays.contains(relay);
  //       bool isOn = currentStatuses[relay] ?? false;

  //       if ((isTarget && !isOn) || (!isTarget && isOn)) {
  //         onlyTargetRelaysAreOn = false;
  //         break;
  //       }
  //     }

  //     // Step 3: Act accordingly
  //     if (onlyTargetRelaysAreOn) {
  //       print('All target relays are already ON. Turning them OFF.');
  //       for (var relay in targetRelays) {
  //         final command = _relayCommands[relay]?['off'];
  //         if (command != null) {
  //           socket.add(Uint8List.fromList(command));
  //           print('Turning OFF relay $relay');
  //           await Future.delayed(Duration(milliseconds: 300));
  //         }
  //       }
  //     } else {
  //       print('Turning ON target relays and OFF others.');
  //       for (var relay in allRelays) {
  //         bool isTarget = targetRelays.contains(relay);
  //         bool isOn = currentStatuses[relay] ?? false;

  //         if (isTarget && !isOn) {
  //           final command = _relayCommands[relay]?['on'];
  //           if (command != null) {
  //             socket.add(Uint8List.fromList(command));
  //             print('Turning ON relay $relay');
  //             await Future.delayed(Duration(milliseconds: 300));
  //           }
  //         } else if (!isTarget && isOn) {
  //           final command = _relayCommands[relay]?['off'];
  //           if (command != null) {
  //             socket.add(Uint8List.fromList(command));
  //             print('Turning OFF relay $relay');
  //             await Future.delayed(Duration(milliseconds: 300));
  //           }
  //         }
  //       }
  //     }
  //   } catch (e, stackTrace) {
  //     print('Exception in toggleRelays: $e');
  //     print(stackTrace);
  //   } finally {
  //     await socket?.close();
  //     print('Socket closed.');
  //   }
  // }

  List<int> _calculateCRC(List<int> data) {
    int crc = 0xFFFF;
    for (var b in data) {
      crc ^= b;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x0001) != 0) {
          crc >>= 1;
          crc ^= 0xA001;
        } else {
          crc >>= 1;
        }
      }
    }
    return [crc & 0xFF, (crc >> 8) & 0xFF]; // [CRC_L, CRC_H]
  }

  Future<bool?> getRelayStatus(int relayNumber) async {
    if (relayNumber < 0 || relayNumber > 7) {
      throw ArgumentError('Relay number must be between 0 and 7.');
    }

    final request = [0x01, 0x01, 0x00, 0x00, 0x00, 0x08];
    final crc = _calculateCRC(request);
    request.addAll(crc);

    try {
      final socket = await Socket.connect(
        ip,
        port,
      ).timeout(Duration(seconds: 3));
      socket.add(Uint8List.fromList(request));

      final completer = Completer<bool?>();
      socket.listen(
        (data) {
          if (data.length >= 5 && data[1] == 0x01) {
            final statusByte = data[3];
            final status = (statusByte >> relayNumber) & 0x01;
            completer.complete(status == 1);
          } else {
            completer.complete(null); // Unexpected response
          }
          socket.destroy();
        },
        onError: (e) {
          completer.complete(null);
          socket.destroy();
        },
        cancelOnError: true,
      );

      return await completer.future;
    } catch (e) {
      return null;
    }
  }
}
