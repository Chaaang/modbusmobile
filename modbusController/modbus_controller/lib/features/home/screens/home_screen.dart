import 'package:flutter/material.dart';
import 'package:modbus_controller/features/home/components/my_button.dart';
import '../../helper/relay_controller.dart';

import '../components/admin_button.dart';
import '../components/my_textfield.dart';

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

  // Future<void> _onButtonPressed(int index) async {
  //   await controller.toggleRelay(index, _relayStates[index]);
  //   setState(() {
  //     _relayStates[index] = !_relayStates[index]; // Toggle relay state
  //   });
  // }

  Future<void> _onButtonPressed(int index) async {
    final success = await controller.toggleRelay(index, _relayStates[index]);

    if (success) {
      setState(() {
        _relayStates[index] = !_relayStates[index]; // Toggle relay state
      });
    } else {
      // Show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to toggle relay ${index + 1}',
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
    setState(() {
      _isAdmin = false; // Reset admin mode
      _passwordController.clear(); // Clear the password field
    });
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
        actions: [
          _isAdmin
              ? IconButton(icon: Icon(Icons.logout), onPressed: _logout)
              : SizedBox(),
        ],
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
                        onTap: () async => await _onButtonPressed(0),
                        color:
                            _relayStates[0] == true
                                ? Colors.redAccent
                                : Colors.green,
                      ),
                    ],
                  ),
                  MyButton(
                    text: 'Relay 2',
                    onTap: () async => await _onButtonPressed(1),
                    color:
                        _relayStates[1] == true
                            ? Colors.redAccent
                            : Colors.green,
                  ),
                  MyButton(
                    text: 'Relay 3',
                    onTap: () async => await _onButtonPressed(2),
                    color:
                        _relayStates[2] == true
                            ? Colors.redAccent
                            : Colors.green,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 200),
                      MyButton(
                        text: 'Relay 4',
                        onTap: () async => await _onButtonPressed(3),
                        color:
                            _relayStates[3] == true
                                ? Colors.redAccent
                                : Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right Side: Admin Mode
            Expanded(
              child:
                  _isAdmin
                      ? Column(
                        children: [
                          SizedBox(height: 100),
                          Text(
                            'Admin Mode',
                            style: TextStyle(
                              fontSize: 36,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 100),
                          AdminButton(
                            text: 'Relay 5',
                            onTap: () async => await _onButtonPressed(4),
                            color:
                                _relayStates[4] == true
                                    ? Colors.redAccent
                                    : Colors.green,
                          ),
                          SizedBox(
                            height: 100,
                          ), // Add spacing between containers
                          AdminButton(
                            text: 'Relay 6',
                            onTap: () async => await _onButtonPressed(5),
                            color:
                                _relayStates[5] == true
                                    ? Colors.redAccent
                                    : Colors.green,
                          ),
                          SizedBox(
                            height: 100,
                          ), // Add spacing between containers
                          AdminButton(
                            text: 'Relay 7',
                            onTap: () async => await _onButtonPressed(6),
                            color:
                                _relayStates[6] == true
                                    ? Colors.redAccent
                                    : Colors.green,
                          ),
                          SizedBox(height: 100),
                        ],
                      )
                      : Column(
                        children: [
                          SizedBox(height: 100),
                          Text(
                            'Admin Mode',
                            style: TextStyle(
                              fontSize: 36,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 100),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: MyTextfield(
                                    passwordController: _passwordController,
                                  ),
                                ),
                                SizedBox(width: 10),
                                IconButton(
                                  onPressed: _checkPassword,
                                  icon: Icon(Icons.arrow_forward, size: 50),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
