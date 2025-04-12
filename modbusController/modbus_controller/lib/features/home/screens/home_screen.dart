import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:modbus_controller/features/home/components/my_button.dart';
import '../../helper/relay_controller.dart';
import 'package:modbus_client/modbus_client.dart';
import 'package:modbus_client_tcp/modbus_client_tcp.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final controller = RelayController(ip: '192.168.1.200');
  bool _isAdmin = false; // Track admin mode
  bool relayStatus = false; // Track the relay status
  final List<bool> _relayStates = [
    true, // Relay 0
    true, // Relay 1
    true, // Relay 2
    true, // Relay 3
    true, // Relay 4
    true, // Relay 5
    true, // Relay 6
    true, // Relay 7
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_initializeRelayStates(); // Initialize the relay states
  }

  // Future<void> _initializeRelayStates() async {
  //     for (int i = 0; i < _relayStates.length; i++) {
  //       bool? status = await controller.checkRelayStatus(i);
  //       setState(() {
  //         _relayStates[i] = status ?? false; // Set relay state, defaulting to false if the status is null
  //       });
  //     }
  //   }
  void _onButtonPressed(int index) {
    setState(() {
      _relayStates[index] = !_relayStates[index]; // Toggle relay state
    });
  }

  void _checkPassword() {
    if (_passwordController.text.isEmpty) {
      // Show an error message if the password field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent, // Highlight error with red
          behavior: SnackBarBehavior.floating, // Floating style
          margin: EdgeInsets.all(16), // Adds spacing from screen edges
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
        ),
      );
      return;
    }
    if (_passwordController.text == 'admin') {
      // If the password is correct, toggle admin mode
      setState(() {
        _isAdmin = true;
      });
    } else {
      // Show an error message if the password is incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Incorrect password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent, // Highlight error with red
          behavior: SnackBarBehavior.floating, // Floating style
          margin: EdgeInsets.all(16), // Adds spacing from screen edges
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
        ),
      );
    }
  }

  void _logout() {
    // Logic to log out the user
    setState(() {
      _isAdmin = false; // Reset admin mode
      _passwordController.clear(); // Clear the password field
    });
  }

  Future controlRelay() async {
    //bool turnOn = true;
    ModbusAppLogger(Level.ALL);
    var serverIp = '192.168.1.200'; // Replace with your Modbus server IP
    final modbusClient = ModbusClientTcp(serverIp, serverPort: 502, unitId: 1);
    // Connect to the server
    bool isConnected = await modbusClient.connect();
    if (!isConnected) {
      print('Failed to connect to Modbus server');
      return;
    }
    print('Connected to Modbus server');

    // Raw RTU frame to turn on relay 0
    final frame = Uint8List.fromList([
      0x01,
      0x05,
      0x00,
      0x00,
      0x00,
      0x00,
      0xCD,
      0xCA,
    ]);

    final ip = '192.168.1.200'; // your device IP
    final port = 502; // Modbus TCP port
    try {
      final socket = await Socket.connect(ip, port);
      print('Connected to $ip:$port');

      socket.add(frame);
      print(
        'Sent: ${frame.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );

      socket.listen((data) {
        print(
          'Response: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
        );
      });

      await Future.delayed(Duration(seconds: 1)); // wait for response
      await socket.close();
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.greenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.greenAccent,
            ], // Two colors for the gradient
            begin: Alignment.topLeft, // Starting point of the gradient
            end: Alignment.bottomRight, // Ending point of the gradient
          ),
        ),
        child: Row(
          children: [
            // Left Side: Relay Buttons
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 200),
                      MyButton(
                        text: 'Relay 1',
                        onTap: () async {
                          await controller.toggleRelay(0, _relayStates[0]);
                          setState(() {
                            _relayStates[0] = !_relayStates[0];
                          });
                        },
                        color:
                            _relayStates[0] == false
                                ? Colors.redAccent
                                : Colors.green,
                      ),
                    ],
                  ),
                  // MyButton(
                  //   text: 'Relay 2',
                  //   onTap: () => _onButtonPressed(1),
                  //   color:
                  //       _relayStates[1] == false
                  //           ? Colors.redAccent
                  //           : Colors.green,
                  // ),
                  // MyButton(
                  //   text: 'Relay 3',
                  //   onTap: () => _onButtonPressed(2),
                  //   color:
                  //       _relayStates[2] == false
                  //           ? Colors.redAccent
                  //           : Colors.green,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     SizedBox(width: 200),
                  //     MyButton(
                  //       text: 'Relay 4',
                  //       onTap: () => _onButtonPressed(3),
                  //       color:
                  //           _relayStates[3] == false
                  //               ? Colors.redAccent
                  //               : Colors.green,
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),

            // // Right Side: Admin Mode
            // Expanded(
            //   child:
            //       _isAdmin
            //           ? Column(
            //             children: [
            //               SizedBox(height: 100),
            //               Text(
            //                 'Admin Mode',
            //                 style: TextStyle(
            //                   fontSize: 36,
            //                   fontStyle: FontStyle.italic,
            //                 ),
            //               ),
            //               SizedBox(height: 100),
            //               AdminButton(
            //                 text: 'Relay 5',
            //                 onTap: () => _onButtonPressed(4),
            //                 color:
            //                     _relayStates[4] == false
            //                         ? Colors.redAccent
            //                         : Colors.green,
            //               ),
            //               SizedBox(
            //                 height: 100,
            //               ), // Add spacing between containers
            //               AdminButton(
            //                 text: 'Relay 6',
            //                 onTap: () => _onButtonPressed(5),
            //                 color:
            //                     _relayStates[5] == false
            //                         ? Colors.redAccent
            //                         : Colors.green,
            //               ),
            //               SizedBox(
            //                 height: 100,
            //               ), // Add spacing between containers
            //               AdminButton(
            //                 text: 'Relay 7',
            //                 onTap: () => _onButtonPressed(6),
            //                 color:
            //                     _relayStates[6] == false
            //                         ? Colors.redAccent
            //                         : Colors.green,
            //               ),
            //               SizedBox(
            //                 height: 100,
            //               ), // Add spacing between containers
            //               IconButton(
            //                 onPressed: _logout,
            //                 icon: Icon(Icons.arrow_forward, size: 50),
            //               ),
            //             ],
            //           )
            //           : Column(
            //             children: [
            //               SizedBox(height: 100),
            //               Text(
            //                 'Admin Mode',
            //                 style: TextStyle(
            //                   fontSize: 36,
            //                   fontStyle: FontStyle.italic,
            //                 ),
            //               ),
            //               SizedBox(height: 100),
            //               Padding(
            //                 padding: const EdgeInsets.symmetric(
            //                   horizontal: 50.0,
            //                 ),
            //                 child: Row(
            //                   children: [
            //                     Expanded(
            //                       child: MyTextfield(
            //                         passwordController: _passwordController,
            //                       ),
            //                     ),
            //                     SizedBox(width: 10),
            //                     IconButton(
            //                       onPressed: _checkPassword,
            //                       icon: Icon(Icons.arrow_forward, size: 50),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ],
            //           ),
            // ),
          ],
        ),
      ),
    );
  }
}
