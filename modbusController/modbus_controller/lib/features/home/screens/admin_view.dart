import 'package:flutter/material.dart';
import 'package:modbus_controller/features/helper/relay_controller.dart';
import 'package:modbus_controller/features/home/screens/home_screen.dart';
import 'package:modbus_controller/features/settings/presentation/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/admin_button.dart';
import '../components/my_button.dart';
import '../components/my_button2.dart';
import '../components/my_textfield.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  //final controller = RelayController(ip: '192.168.1.200');
  late RelayController controller;

  bool _isAdmin = false; // Track admin mode
  bool onTapAdminMode = false; // Track admin mode tap
  bool relayStatus = false; // Track the relay status

  String text1 = 'Legislative Council\nComplex';
  String text2 = 'Original Building';
  String text3 = 'Expanded Section';
  String text4 = 'Chamber';

  @override
  void initState() {
    super.initState();
    _loadSavedIPAndPort(); // Call the async function here
  }

  final List<Future<void> Function()> _commandQueue = [];
  bool _isProcessing = false;

  void _enqueueRelayCommand(Future<void> Function() command) {
    _commandQueue.add(command);
    if (!_isProcessing) _runQueue();
  }

  Future<void> _runQueue() async {
    _isProcessing = true;
    while (_commandQueue.isNotEmpty) {
      final command = _commandQueue.removeAt(0);
      try {
        await command();
      } catch (e) {
        print('Error executing relay command: $e');
      }
    }
    _isProcessing = false;
  }

  //testt

  Future<void> _loadSavedIPAndPort() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedIP = prefs.getString('ip_address');
    String? savedPort = prefs.getString('port');

    final ip =
        (savedIP != null && savedIP.isNotEmpty) ? savedIP : '192.168.1.200';
    final port = int.tryParse(savedPort ?? '') ?? 502;

    setState(() {
      controller = RelayController(ip: ip, port: port);
      ipController.text = savedIP ?? '192.168.1.200';
      portController.text = savedPort ?? '502';
    });
  }

  void _updateRelayController() {
    print('TRIGGER CALL BACK');
    setState(() {
      controller = RelayController(
        ip: ipController.text.isNotEmpty ? ipController.text : '192.168.1.200',
        port: int.tryParse(portController.text) ?? 502,
      );
    });
  }

  void _showPasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    const correctPassword = '1234';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Admin Access',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline),
              hintText: 'Enter Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 6,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.blueAccent.withOpacity(0.4),
              ),
              onPressed: () {
                if (passwordController.text == correctPassword) {
                  Navigator.of(context).pop();
                  _showIPPortDialog(context, controller.ip, controller.port);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect password')),
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.lock_open_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Unlock',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showIPPortDialog(BuildContext context, String ip, int port) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Network Configuration',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ipController,
                decoration: InputDecoration(
                  labelText: 'IP Address',
                  prefixIcon: const Icon(Icons.language),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: portController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Port',
                  prefixIcon: const Icon(Icons.dns),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 6,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.greenAccent.withOpacity(0.4),
              ),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('ip_address', ipController.text);
                prefs.setString('port', portController.text);

                // Update the RelayController with new IP and port
                _updateRelayController(); // Update RelayController here

                // print(
                //   "Saved IP: ${ipController.text}, Port: ${portController.text}",
                // );
                Navigator.pop(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.save_as, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onButtonPressed(List<int> indices, int? buttonNumber) async {
    if (buttonNumber != null) {
      if (buttonNumber == 1) {
        //HERE
        await controller.toggleAdmin(indices, 1);
        //await controller.toggleRelays(indices); // 🚀
      } else if (buttonNumber == 2) {
        await controller.toggleAdmin(indices, 2); // 🚀

        await Future.delayed(Duration(seconds: 1));
        await controller.toggleAdmin(indices, 2); // 🚀
      } else if (buttonNumber == 3) {
        await controller.toggleAdmin(indices, 3); // 🚀
        await Future.delayed(Duration(seconds: 1));
        await controller.toggleAdmin(indices, 3); // 🚀
      }
    } else {
      await controller.toggleRelays(indices); // 🚀
    }
  }

  void onTapButton(List<int> relays, int? buttonNumber) {
    _enqueueRelayCommand(() => _onButtonPressed(relays, buttonNumber));
  }

  // void _checkPassword() {
  //   if (_passwordController.text.isEmpty) {
  //     // Show an error message if the password field is empty
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Please enter a password',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         duration: Duration(seconds: 2),
  //         backgroundColor: Colors.redAccent, // Highlight error with red
  //         behavior: SnackBarBehavior.floating, // Floating style
  //         margin: EdgeInsets.all(16), // Adds spacing from screen edges
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12), // Rounded corners
  //         ),
  //       ),
  //     );
  //     return;
  //   }
  //   if (_passwordController.text == 'admin') {
  //     // If the password is correct, toggle admin mode
  //     setState(() {
  //       _isAdmin = true;
  //     });
  //   } else if (_passwordController.text == 'super') {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => SettingsScreen()),
  //     );
  //   } else {
  //     // Show an error message if the password is incorrect
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Incorrect password',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 16,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         duration: Duration(seconds: 2),
  //         backgroundColor: Colors.redAccent, // Highlight error with red
  //         behavior: SnackBarBehavior.floating, // Floating style
  //         margin: EdgeInsets.all(16), // Adds spacing from screen edges
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12), // Rounded corners
  //         ),
  //       ),
  //     );
  //   }
  // }

  void _checkPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAdmin = prefs.getString('admin') ?? 'admin'; // Default: "admin"
    final savedSuperAdmin =
        prefs.getString('superAdmin') ?? 'qbase88'; // Default: "super"

    final enteredPassword = _passwordController.text;

    if (enteredPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please enter a password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (enteredPassword == savedAdmin) {
      setState(() {
        _isAdmin = true;
      });
    } else if (enteredPassword == savedSuperAdmin) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      ).then((_) {
        _loadSavedIPAndPort();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Incorrect password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showInitialChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Select Mode',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          //content: const Text('Please choose an option:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ), // <-- Replace with your admin page
                );
              },
              child: const Text('VISITOR MODE'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the first dialog
                // _showPasswordDialog(context); // Show the password dialog
              },
              child: const Text('ADMIN MODE'),
            ),
          ],
        );
      },
    );
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
      resizeToAvoidBottomInset: false, // Prevent UI shift on keyboard open
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/admin_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  //vertical: 5.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue[900],
                            ),
                            child: Icon(
                              Icons.language,
                              size: 40, // Slightly smaller for balance
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                text1 = 'Legislative Council\nComplex';
                                text2 = 'Original Building';
                                text3 = 'Expanded Section';
                                text4 = 'Chamber';
                              });
                            },
                            child: Text(
                              '  ENG  ',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                text1 = '立法會\n綜合大樓';
                                text2 = '原有建築';
                                text3 = '擴建部分';
                                text4 = '會議廳';
                              });
                            },
                            child: Text(
                              '繁  ',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                text1 = '立法会\n综合大楼';
                                text2 = '原有建筑';
                                text3 = '扩建部分 ';
                                text4 = '会议厅';
                              });
                            },
                            child: Text(
                              '简',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                          SizedBox(width: 65),
                          GestureDetector(
                            onTap: () => _showInitialChoiceDialog(context),
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.settings,
                                size: 40, // Slightly smaller for balance
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                          Spacer(),

                          _isAdmin
                              ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(
                                    50,
                                  ), // Oblong shape
                                ),
                                child: GestureDetector(
                                  onTap: _logout,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        color: Colors.blue[900],
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.blue[900],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.blue[900],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              : SizedBox(),
                        ],
                      ),
                    ),

                    Row(
                      children: [
                        // Left Side: Relay Buttons
                        //SizedBox(width: 40),
                        Column(
                          children: [
                            //SizedBox(height: 10),
                            // MyButton(
                            //   text: text1,
                            //   onTap:
                            //       () async =>
                            //           await _onButtonPressed([0, 1, 2], null),
                            //   color: Colors.blue[900]!,
                            // ),
                            MyButton2(
                              imageAssetPath: 'lib/assets/bluebutton.png',
                              text: text1,
                              onTap:
                                  () async =>
                                      await _onButtonPressed([0, 1, 2], null),
                            ),
                            SizedBox(height: 25),
                            // MyButton(
                            //   text: text3,
                            //   onTap:
                            //       () async => await _onButtonPressed([2], null),
                            //   color: Colors.purple[900]!,
                            // ),
                            MyButton2(
                              imageAssetPath: 'lib/assets/purplebutton.png',
                              text: text3,
                              onTap:
                                  () async => await _onButtonPressed([2], null),
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            SizedBox(height: 170),

                            MyButton2(
                              imageAssetPath: 'lib/assets/orangebutton.png',
                              text: text2,
                              onTap:
                                  () async =>
                                      await _onButtonPressed([0, 1], null),
                            ),

                            SizedBox(height: 25),

                            MyButton2(
                              imageAssetPath: 'lib/assets/greenbutton.png',
                              text: text4,
                              onTap:
                                  () async => await _onButtonPressed([1], null),
                            ),
                          ],
                        ),

                        //Right Side: Admin Mode
                        Expanded(
                          child:
                              _isAdmin
                                  ? Column(
                                    children: [
                                      //SizedBox(height: 50),
                                      Text(
                                        'Admin Mode',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 100),
                                      AdminButton(
                                        text: '升會議廳',
                                        onTap: () => onTapButton([1, 3, 4], 1),
                                        // await _onButtonPressed([
                                        //   1,
                                        //   3,
                                        //   4,
                                        // ], 1),
                                        color: Colors.blue,
                                      ),
                                      SizedBox(height: 100),
                                      AdminButton(
                                        text: '開1213',
                                        onTap: () => onTapButton([5], 2),
                                        // _onButtonPressed([5], 2),
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 100),
                                      AdminButton(
                                        text: '開 1318-19',
                                        onTap: () => onTapButton([6], 3),
                                        // await _onButtonPressed([6], 3),
                                        color: Colors.blue,
                                      ),
                                      SizedBox(height: 100),
                                    ],
                                  )
                                  : Column(
                                    children: [
                                      Text(
                                        'Admin Mode',
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 50),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 50.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: MyTextfield(
                                                passwordController:
                                                    _passwordController,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.green[900],
                                              ),
                                              child: IconButton(
                                                onPressed: _checkPassword,
                                                icon: Icon(
                                                  Icons.arrow_forward,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
