import 'package:runtime_digital_fingerprint/runtime_digital_fingerprint.dart';

/// This example calls Network methods and prints the results.
void main() async {

  String ipAddress = await Network.iPAddress();
  String macAddress = await Network.macAddress();

  print('The IP address for this machine is: $ipAddress');
  print('The MAC address for this machine is: $macAddress');
}
