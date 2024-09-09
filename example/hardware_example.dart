import 'package:runtime_digital_fingerprint/runtime_digital_fingerprint.dart';

/// This example calls Hardware methods and prints the results.
void main() async {

  String cpu = await Hardware.cpu();
  MemoryAmount memory = await Hardware.physicalMemory();
  String? gpu = await Hardware.gpu();

  print('The CPU for this machine is: $cpu');
  print('The physical memory for this machine is: $memory');
  print('The GPU for this machine is: $gpu');
}
