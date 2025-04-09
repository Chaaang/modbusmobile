// import 'package:modbus_client/modbus_client.dart';

// class ModbusRelayControl {
//   // Use the ModbusClient directly
//   final ModbusClient modbusClient = ModbusClient();

//   final String ipAddress = '192.168.1.100';  // Replace with your relay's IP
//   final int port = 502;  // Default Modbus TCP port

//   // Connect to the relay
//   Future<void> connect() async {
//     try {
//       await modbusClient.connect(ipAddress, port);
//       print('Connected to the relay!');
//     } catch (e) {
//       print('Error connecting to relay: $e');
//     }
//   }

//   // Toggle the relay state (coil addressing may vary)
//   Future<void> toggleRelay(int coilAddress, bool state) async {
//     try {
//       // Example: Write to a single coil (change address and logic as needed)
//       await modbusClient.writeSingleCoil(coilAddress, state);
//       print('Relay state: ${state ? "ON" : "OFF"}');
//     } catch (e) {
//       print('Error toggling relay: $e');
//     }
//   }

//   // Disconnect from the relay
//   Future<void> disconnect() async {
//     try {
//       await modbusClient.close();
//       print('Connection closed');
//     } catch (e) {
//       print('Error closing connection: $e');
//     }
//   }
// }
