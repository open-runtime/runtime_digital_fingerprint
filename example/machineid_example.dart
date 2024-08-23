import 'package:runtime_digital_fingerprint/runtime_digital_fingerprint.dart';

/// This example calls MachineId.machineId() and prints the result.
void main() async {
  
  String machineId = await MachineId.machineId();

  print('The machineId for this machine is: $machineId');
}
