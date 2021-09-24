part of 'device_bloc.dart';

class DeviceState extends Equatable {
  final BluetoothState stateBle;
  final List<BluetoothDevice> listScan;
  final BluetoothDevice device;
  final bool isScanning;
  final bool isConnected;
  DeviceState({
    this.stateBle = BluetoothState.off,
    this.listScan,
    this.device,
    this.isScanning,
    this.isConnected,
  });

  DeviceState copyWith({
    BluetoothState stateBle,
    List<BluetoothDevice> listScan,
    BluetoothDevice device,
    bool isScanning,
    bool isConnected,
  }) {
    return DeviceState(
      stateBle: stateBle ?? this.stateBle,
      listScan: listScan ?? this.listScan,
      device: device ?? this.device,
      isScanning: isScanning ?? this.isScanning,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      stateBle,
      listScan,
      device,
      isScanning,
      isConnected,
    ];
  }
}
