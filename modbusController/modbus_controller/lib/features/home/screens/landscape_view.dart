import 'package:flutter/material.dart';
import 'package:modbus_controller/features/helper/relay_controller.dart';
import 'package:modbus_controller/features/home/components/my_button2.dart';
import 'package:modbus_controller/features/home/screens/admin_view.dart';
import 'package:modbus_controller/features/settings/presentation/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/admin_button.dart';
import '../components/my_button.dart';

class LandscapeView extends StatefulWidget {
  const LandscapeView({super.key});

  @override
  State<LandscapeView> createState() => _LandscapeViewState();
}

class _LandscapeViewState extends State<LandscapeView> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  //final controller = RelayController(ip: '192.168.1.200');
  late RelayController controller;

  bool _isAdmin = false; // Track admin mode
  bool onTapAdminMode = false; // Track admin mode tap
  bool relayStatus = false; // Track the relay status

  String text1 = 'Legislative Council\nComplex';
  String text2 = 'Original\nBuilding';
  String text3 = 'Expanded Section';
  String text4 = 'Chamber';

  @override
  void initState() {
    super.initState();
    _loadSavedIPAndPort(); // Call the async function here
  }

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
                    builder: (context) => AdminView(),
                  ), // <-- Replace with your admin page
                );
              },
              child: const Text('ADMIN MODE'),
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
              child: const Text('VISITOR MODE'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onButtonPressed(List<int> indices) async {
    await controller.toggleRelays(indices); // 🚀
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
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            // vertical: 20.0,
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
                                Icon(Icons.logout, color: Colors.blue[900]),
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
                  //SizedBox(width: 20),
                  Column(
                    children: [
                      //SizedBox(height: 10),
                      // MyButton(
                      //   text: text1,
                      //   onTap: () async => await _onButtonPressed([0, 1, 2]),
                      //   color: Colors.blue[900]!,
                      // ),
                      MyButton2(
                        imageAssetPath: 'lib/assets/bluebutton.png',
                        text: text1,
                        onTap: () async => await _onButtonPressed([0, 1, 2]),
                      ),
                      SizedBox(height: 25),

                      // MyButton(
                      //   text: text3,
                      //   onTap: () async => await _onButtonPressed([2]),
                      //   color: Colors.purple[900]!,
                      // ),
                      MyButton2(
                        imageAssetPath: 'lib/assets/purplebutton.png',
                        text: text3,
                        onTap: () async => await _onButtonPressed([2]),
                      ),
                    ],
                  ),
                  //SizedBox(width: 10),
                  Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(height: 170),
                      // MyButton(
                      //   text: text2,
                      //   onTap: () async => await _onButtonPressed([0, 1]),
                      //   color: Colors.orange[900]!,
                      // ),
                      MyButton2(
                        imageAssetPath: 'lib/assets/orangebutton.png',
                        text: text2,
                        onTap: () async => await _onButtonPressed([0, 1]),
                      ),

                      SizedBox(height: 25),

                      // MyButton(
                      //   text: text4,
                      //   onTap: () async => await _onButtonPressed([1]),
                      //   color: Colors.green[900]!,
                      //   imageAssetPath: 'lib/assets/greenbutton.png',
                      // ),
                      MyButton2(
                        imageAssetPath: 'lib/assets/greenbutton.png',
                        text: text4,
                        onTap: () async => await _onButtonPressed([1]),
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
                                  onTap:
                                      () async =>
                                          await _onButtonPressed([1, 3, 4]),
                                  color: Colors.blue,
                                ),
                                SizedBox(height: 100),
                                AdminButton(
                                  text: '開1213',
                                  onTap:
                                      () async => await _onButtonPressed([5]),
                                  color: Colors.white,
                                ),
                                SizedBox(height: 100),
                                AdminButton(
                                  text: '開 1318-19',
                                  onTap:
                                      () async => await _onButtonPressed([6]),
                                  color: Colors.blue,
                                ),
                                SizedBox(height: 100),
                              ],
                            )
                            : Container(),

                    // Column(
                    //   children: [
                    //     GestureDetector(
                    //       onTap: () {
                    //         widget.onToggleBackground();
                    //         setState(() {
                    //           onTapAdminMode = !onTapAdminMode;
                    //         });
                    //       },
                    //       child: Text(
                    //         'Admin Mode',
                    //         style: TextStyle(
                    //           fontSize: 36,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //     ),
                    //     SizedBox(height: 50),

                    //     onTapAdminMode
                    //         ? Padding(
                    //           padding: const EdgeInsets.symmetric(
                    //             horizontal: 50.0,
                    //           ),
                    //           child: Row(
                    //             children: [
                    //               Expanded(
                    //                 child: MyTextfield(
                    //                   passwordController:
                    //                       _passwordController,
                    //                 ),
                    //               ),
                    //               SizedBox(width: 10),
                    //               Container(
                    //                 decoration: BoxDecoration(
                    //                   shape: BoxShape.circle,
                    //                   color: Colors.green[900],
                    //                 ),
                    //                 child: IconButton(
                    //                   onPressed: _checkPassword,
                    //                   icon: Icon(
                    //                     Icons.arrow_forward,
                    //                     size: 40,
                    //                     color: Colors.white,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         )
                    //         : SizedBox(),
                    //   ],
                    // ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
