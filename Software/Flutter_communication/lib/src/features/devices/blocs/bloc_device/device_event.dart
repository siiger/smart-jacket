part of 'device_bloc.dart';

abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object> get props => [];
}

class BluetoothStateChanged extends DeviceEvent {
  const BluetoothStateChanged(this.stateBle);

  final BluetoothState stateBle;

  @override
  List<Object> get props => [stateBle];
}

class ToggleScanForDevices extends DeviceEvent {}

class UpdateScanResult extends DeviceEvent {
  final BluetoothDevice device;
  final bool isConnected;

  UpdateScanResult({this.device, this.isConnected});

  @override
  List<Object> get props => [device, isConnected];
}

class ToggleConnectionToDevice extends DeviceEvent {
  ToggleConnectionToDevice(this.device);
  final BluetoothDevice device;

  @override
  List<Object> get props => [device];
}

class UpdateScanningState extends DeviceEvent {
  final bool state;

  const UpdateScanningState({
    this.state,
  });

  @override
  List<Object> get props => [state];
}
