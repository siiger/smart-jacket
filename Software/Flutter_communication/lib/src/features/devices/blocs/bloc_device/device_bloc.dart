import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:norbusensor/src/core/constants.dart';
import 'package:norbusensor/src/core/utils/show_message.dart';

part 'device_event.dart';
part 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  DeviceBloc({@required FlutterBlue flutterBlue})
      : assert(flutterBlue != null),
        _flutterBlue = flutterBlue,
        super(DeviceState(listScan: [], isConnected: false)) {
    bluetoothInstanceSubscription = _flutterBlue.state.listen((state) => add(BluetoothStateChanged(state)));
  }

  final FlutterBlue _flutterBlue;
  StreamSubscription<BluetoothState> bluetoothInstanceSubscription;
  StreamSubscription<ScanResult> scanSubscription;
  StreamSubscription<List<BluetoothDevice>> connectedDevicesSubscription;
  StreamSubscription<BluetoothDeviceState> sensorDeviceStateSubscription;

  @override
  Stream<DeviceState> mapEventToState(
    DeviceEvent event,
  ) async* {
    if (event is BluetoothStateChanged) {
      yield* _mapBluetoothStateChangedToState(state, event);
    } else if (event is ToggleScanForDevices) {
      yield* _mapToggleScanForDevicesToState(state, event);
    } else if (event is UpdateScanResult) {
      yield* _mapUpdateScanResultToState(state, event);
    } else if (event is ToggleConnectionToDevice) {
      yield* _mapToggleConnectionToDeviceToState(state, event);
    }
  }

  Stream<DeviceState> _mapBluetoothStateChangedToState(DeviceState state, BluetoothStateChanged event) async* {
    yield state.copyWith(stateBle: event.stateBle, isScanning: false);
    if (event.stateBle == BluetoothState.on) {
      connectedDevicesSubscription?.cancel();
      connectedDevicesSubscription = Stream.periodic(Duration(seconds: 2))
          .asyncMap((_) => FlutterBlue.instance.connectedDevices)
          .listen((List<BluetoothDevice> devices) {
        if (devices.length != 0)
          for (BluetoothDevice d in devices) {
            if (d.name == Constants.NAME_DEVICE) {
              sensorDeviceStateSubscription?.cancel();
              sensorDeviceStateSubscription = d.state.listen((event) {
                add(UpdateScanResult(device: d, isConnected: event == BluetoothDeviceState.connected));
              });
            }
          }
      });
    }
  }

  Stream<DeviceState> _mapToggleScanForDevicesToState(DeviceState state, ToggleScanForDevices event) async* {
    if (!state.isScanning) {
      yield state.copyWith(isScanning: true);
      showMessage("Scanning");
      scanSubscription?.cancel();
      scanSubscription = _flutterBlue.scan().listen((ScanResult result) {
        if (result.device.name == Constants.NAME_DEVICE) {
          add(UpdateScanResult(device: result.device, isConnected: false));
        }
      });
    } else {
      await _flutterBlue.stopScan();
      scanSubscription?.cancel();
      yield state.copyWith(isScanning: false);
      showMessage("Stop");
    }
  }

  Stream<DeviceState> _mapUpdateScanResultToState(DeviceState state, UpdateScanResult event) async* {
    if (!state.listScan.contains(event.device)) {
      List<BluetoothDevice> listScanUp = [];
      listScanUp.addAll(state.listScan);
      listScanUp.add(event.device);
      yield state.copyWith(listScan: listScanUp, device: event.device, isConnected: event.isConnected);
    }
  }

  Stream<DeviceState> _mapToggleConnectionToDeviceToState(DeviceState state, ToggleConnectionToDevice event) async* {
    if (!state.isConnected) {
      await event.device.connect();
      yield state.copyWith(isConnected: true);
      showMessage("Connected");
    } else {
      await event.device.disconnect();
      yield state.copyWith(isConnected: false);
      showMessage("Disconnect");
    }
  }

  @override
  Future<void> close() {
    scanSubscription?.cancel();
    bluetoothInstanceSubscription?.cancel();
    connectedDevicesSubscription?.cancel();
    sensorDeviceStateSubscription?.cancel();
    return super.close();
  }
}
