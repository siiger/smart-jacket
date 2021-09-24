part of 'data_sensor_bloc.dart';

class DataSensorState extends Equatable {
  const DataSensorState({
    this.listSensorData,
    this.listActivity,
    this.currentActivity,
    this.cTX,
    this.cRX,
    this.isRealTimeMode = false,
    this.isRecToMemoryMode = false,
    this.isReadFromMemoryMode = false,
    this.isAvailable,
  });

  final List<DataSensorModel> listSensorData;
  final List<String> listActivity;
  final String currentActivity;
  final BluetoothCharacteristic cTX;
  final BluetoothCharacteristic cRX;
  final bool isRealTimeMode;
  final bool isRecToMemoryMode;
  final bool isReadFromMemoryMode;
  final bool isAvailable;

  DataSensorState copyWith({
    List<DataSensorModel> listSensorData,
    List<String> listActivity,
    String currentActivity,
    BluetoothCharacteristic cTX,
    BluetoothCharacteristic cRX,
    bool isRealTimeMode,
    bool isRecToMemoryMode,
    bool isReadFromMemoryMode,
    bool isAvailable,
  }) {
    return DataSensorState(
      listSensorData: listSensorData ?? this.listSensorData,
      listActivity: listActivity ?? this.listActivity,
      currentActivity: currentActivity ?? this.currentActivity,
      cTX: cTX ?? this.cTX,
      cRX: cRX ?? this.cRX,
      isRealTimeMode: isRealTimeMode ?? this.isRealTimeMode,
      isRecToMemoryMode: isRecToMemoryMode ?? this.isRecToMemoryMode,
      isReadFromMemoryMode: isReadFromMemoryMode ?? this.isReadFromMemoryMode,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      listSensorData,
      listActivity,
      currentActivity,
      cTX,
      cRX,
      isRealTimeMode,
      isRecToMemoryMode,
      isReadFromMemoryMode,
      isAvailable,
    ];
  }
}
