import 'package:flutter/material.dart';
import 'package:modbus_controller/features/home/screens/landscape_view.dart';
import '../components/my_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool get isSmallDevice {
    final size = MediaQuery.of(context).size;
    return size.shortestSide <
        600; // Rough check: devices <600dp are usually phones
  }

  @override
  Widget build(BuildContext context) {
    return isSmallDevice
        ? Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'This app is designed for iPad.\nPlease use an iPad for the best experience.',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black, // Ensure text is visible
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        )
        : Scaffold(
          resizeToAvoidBottomInset: false, // Prevent UI shift on keyboard open
          body: Stack(children: [BackgroundImage(), LandscapeView()]),
        );
  }
}
