part of 'data_sensor_bloc.dart';

abstract class SensorEvent extends Equatable {
  const SensorEvent();

  @override
  List<Object> get props => [];
}

class UpdateDeviceDataSource extends SensorEvent {
  final BluetoothDevice device;
  final bool isAvailable;

  UpdateDeviceDataSource({
    this.device,
    this.isAvailable,
  });

  @override
  List<Object> get props => [device, isAvailable];
}

class ToggleRecDataToMemory extends SensorEvent {}

class AddActivityToList extends SensorEvent {
  final String mark;

  AddActivityToList({
    this.mark,
  });
  @override
  List<Object> get props => [mark];
}

class DeleteActivityFromList extends SensorEvent {
  final int index;

  DeleteActivityFromList({
    this.index,
  });
  @override
  List<Object> get props => [index];
}

class ChooseActivity extends SensorEvent {
  final int index;

  ChooseActivity({
    this.index,
  });
  @override
  List<Object> get props => [index];
}

class ReadDataFromMemory extends SensorEvent {}

class SaveDataToLocalPath extends SensorEvent {}

class ToggleRealTimeDataAccess extends SensorEvent {}

class InitSensor extends SensorEvent {}

class UpdateDataSensor extends SensorEvent {
  final DataSensorModel sensorData;

  UpdateDataSensor({
    this.sensorData,
  });
  @override
  List<Object> get props => [sensorData];
}
