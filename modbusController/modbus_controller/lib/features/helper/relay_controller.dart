import 'dart:io';
import 'dart:typed_data';

class RelayController {
  final String ip;
  final int port;

  RelayController({required this.ip, this.port = 502});

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

  // Future<void> toggleRelay(int relayNumber, bool turnOn) async {
  //   final command = _relayCommands[relayNumber]?[turnOn ? 'on' : 'off'];
  //   if (command == null) {
  //     return;
  //   }

  //   try {
  //     final socket = await Socket.connect(ip, port);
  //     print('Connected to $ip:$port');

  //     socket.add(Uint8List.fromList(command));
  //     print(
  //       'Sent: ${command.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
  //     );

  //     socket.listen((data) {
  //       print(
  //         'hey Response: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
  //       );
  //     });

  //     await Future.delayed(Duration(seconds: 1));
  //     await socket.close();
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  Future<bool> toggleRelay(int relayNumber, bool turnOn) async {
    final command = _relayCommands[relayNumber]?[turnOn ? 'on' : 'off'];

    if (command == null) {
      print('Invalid relay number or command not found for relay $relayNumber');
      return false;
    }

    try {
      final socket = await Socket.connect(
        ip,
        port,
      ).timeout(Duration(seconds: 3));
      print('Connected to $ip:$port');

      socket.add(Uint8List.fromList(command));
      print(
        'Sent: ${command.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );

      socket.listen(
        (data) {
          print(
            'Response: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
          );
        },
        onError: (error) {
          print('Socket error: $error');
        },
        onDone: () {
          print('Connection closed by server');
        },
        cancelOnError: true,
      );

      //await Future.delayed(Duration(seconds: 1));
      await socket.close();
      return true;
    } catch (e) {
      print('Error toggling relay: $e');
      return false;
    }
  }
}
