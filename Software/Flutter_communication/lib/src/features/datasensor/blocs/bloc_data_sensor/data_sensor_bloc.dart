import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:norbusensor/src/features/devices/blocs/bloc_device/device_bloc.dart';
import 'package:norbusensor/src/features/datasensor/models/data_sensor_model.dart';
import 'package:norbusensor/src/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:norbusensor/src/config/app_colors.dart';
import 'package:norbusensor/src/core/utils/show_message.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

part 'data_sensor_event.dart';
part 'data_sensor_state.dart';

class DataSensorBloc extends Bloc<SensorEvent, DataSensorState> {
  DataSensorBloc({@required DeviceBloc deviceBloc})
      : assert(deviceBloc != null),
        _deviceBloc = deviceBloc,
        super(DataSensorState(listSensorData: [])) {
    _deviceSubscription = _deviceBloc.listen(
        (DeviceState states) => add(UpdateDeviceDataSource(device: states.device, isAvailable: states.isConnected)));
  }

  final DeviceBloc _deviceBloc;
  StreamSubscription<DeviceState> _deviceSubscription;
  StreamSubscription _receiveDataSubscription;
  SharedPreferences preferences;
  int saveDataStartIndex;

  //redraw the series controllers
  ChartSeriesController _chartSeriesControllerCh;
  ChartSeriesController _chartSeriesControllerSt;
  final int _deltaChartData = 100;
  List<DataSensorModel> _dataBr = [];

  //Post data to server
  http.StreamedResponse response;
  http.Response responsePost;
  var url = Uri.parse('http://192.168.0.100:5500/products/add/');
  var urlP = Uri.parse('http://192.168.0.100:5500/products/');

  @override
  Stream<DataSensorState> mapEventToState(
    SensorEvent event,
  ) async* {
    if (event is InitSensor) {
      yield* _mapInitSensorToState(state);
    } else if (event is UpdateDeviceDataSource) {
      yield* _mapUpdateDeviceDataSourceToState(state, event);
    } else if (event is ToggleRecDataToMemory) {
      yield* _mapToggleRecDataToMemoryToState(state, event);
    } else if (event is ReadDataFromMemory) {
      yield* _mapReadDataFromMemoryToState(state);
    } else if (event is SaveDataToLocalPath) {
      yield* _mapSaveDataToLocalPathToState(state);
    } else if (event is ToggleRealTimeDataAccess) {
      yield* _mapToggleRealTimeDataAccessToState(state, event);
    } else if (event is UpdateDataSensor) {
      yield* _mapUpdateDataSensorToState(state, event);
    } else if (event is AddActivityToList) {
      yield* _mapAddActivityToListToState(state, event);
    } else if (event is DeleteActivityFromList) {
      yield* _mapDeleteActivityFromListToState(state, event);
    } else if (event is ChooseActivity) {
      yield* _mapChooseActivityToState(state, event);
    }
  }

  Stream<DataSensorState> _mapInitSensorToState(DataSensorState state) async* {
    preferences = await SharedPreferences.getInstance();
    saveDataStartIndex = 0;
    List<String> listActivityUp = await preferences.getStringList(Constants.ACTIVITY);
    if (listActivityUp == null) listActivityUp = [];
    yield state.copyWith(currentActivity: '', listActivity: listActivityUp);
  }

  Stream<DataSensorState> _mapUpdateDeviceDataSourceToState(
      DataSensorState state, UpdateDeviceDataSource event) async* {
    BluetoothCharacteristic ccRX, ccTX;
    if (event.isAvailable) {
      try {
        final List<BluetoothService> services = await event.device.discoverServices();
        if (services != null)
          services.forEach((service) {
            if (service.uuid.toString() == Constants.ISSC_PROPRIETARY_SERVICE_UUID) {
              service.characteristics.forEach((c) {
                if (c.uuid.toString() == Constants.UUIDSTR_ISSC_TRANS_RX) {
                  //Updating characteristic to perform write operation.
                  ccRX = c;
                } else if (c.uuid.toString() == Constants.UUIDSTR_ISSC_TRANS_TX) {
                  //Updating stream to perform read operation.
                  c.setNotifyValue(!c.isNotifying);
                  ccTX = c;
                }
              });
            }
          });
      } catch (e) {
        print(e.toString());
      }
    } else {}
    yield state.copyWith(cRX: ccRX, cTX: ccTX, isAvailable: event.isAvailable);
  }

  Stream<DataSensorState> _mapToggleRecDataToMemoryToState(DataSensorState state, ToggleRecDataToMemory event) async* {
    if (state.isAvailable) {
      DateTime time = DateTime.now();
      List<int> data = [
        time.year - 2000,
        time.month,
        time.day,
        time.hour,
        time.minute,
        time.second,
        ((time.millisecond - time.millisecond % 100) ~/ 100),
        time.millisecond % 100,
      ];
      data.insertAll(8, Constants.DATA_TIME_END);
      data.insertAll(0, Constants.DATA_TIME_BEGIN);
      if (!state.isRecToMemoryMode) {
        data.insert(0, Constants.CMD_RECORD);
        Uint8List bytes = Uint8List.fromList(data);
        await state.cRX.write(bytes, withoutResponse: true);
        yield state.copyWith(isRecToMemoryMode: true);
        showMessage("Record");
      } else {
        await state.cRX.write([Constants.CMD_STOP], withoutResponse: true);
        yield state.copyWith(isRecToMemoryMode: false);
        showMessage("Stop");
      }
    }
  }

  Stream<DataSensorState> _mapReadDataFromMemoryToState(DataSensorState state) async* {
    if (state.isAvailable) {
      bool isDataTime = false;
      int partDataTime = 1;
      List<int> listDataTime = [];
      await state.cRX.write([Constants.CMD_READ], withoutResponse: true);
      DateTime time;
      _receiveDataSubscription?.cancel();
      _receiveDataSubscription = state.cTX.value.listen((List<int> data) {
        if (data[0] == Constants.DATA_TIME_BEGIN[0] &&
            data[1] == Constants.DATA_TIME_BEGIN[1] &&
            data[2] == Constants.DATA_TIME_BEGIN[2] &&
            data[3] == Constants.DATA_TIME_BEGIN[3]) {
          isDataTime = true;
          partDataTime = 1;
          return;
        } else if (data[0] == Constants.DATA_TIME_END[0] &&
            data[1] == Constants.DATA_TIME_END[1] &&
            data[2] == Constants.DATA_TIME_END[2] &&
            data[3] == Constants.DATA_TIME_END[3]) {
          isDataTime = false;
          partDataTime = 1;
          return;
        }
        if (isDataTime) {
          if (partDataTime == 1) {
            List<int> firstPart = [data[0] + 2000, data[1], data[2], data[3]];
            listDataTime.addAll(firstPart);
            partDataTime = 2;
          } else if (partDataTime == 2) {
            List<int> secondPart = [data[0], data[1], data[2] * 100 + data[3]];
            listDataTime.addAll(secondPart);
            time = DateTime(
                listDataTime[0], listDataTime[1], listDataTime[2], listDataTime[3], listDataTime[4], listDataTime[5]);
          }
        } else if (!isDataTime) {
          List<int> listData = [0, 0];
          if (data.length != 0) {
            for (int i = 0; i < data.length / 2; i++) {
              Uint8List bytes = Uint8List.fromList([data[i * 2], data[(i + 1) * 2 - 1]]);
              ByteBuffer byteBuffer = bytes.buffer;
              Uint16List thirtytwoBitList = byteBuffer.asUint16List();
              listData[i] = int.parse(thirtytwoBitList[0].toRadixString(2), radix: 2);
            }
            time = time.add(new Duration(milliseconds: 300));
            final DataSensorModel sensorData =
                new DataSensorModel(stbreath: listData[0].toDouble(), chbreath: listData[1].toDouble(), lastTime: time);
            add(UpdateDataSensor(sensorData: sensorData));
          }
        }
      });
      showMessage("Reading data");
    }
  }

  Stream<DataSensorState> _mapToggleRealTimeDataAccessToState(
      DataSensorState state, ToggleRealTimeDataAccess event) async* {
    if (state.isAvailable) {
      if (!state.isRealTimeMode) {
        //state.cTX.setNotifyValue(!state.cTX.isNotifying);
        try {
          await state.cRX.write([Constants.CMD_RUN], withoutResponse: true);
          try {
            final res = await state.cRX.read();
            if (res.length != null) print("OK");
            yield state.copyWith(isRealTimeMode: true);
            showMessage("Run");
          } catch (e) {
            print(e);
          }
        } catch (e) {
          print(e);
        }
        _receiveDataSubscription?.cancel();
        _receiveDataSubscription = state.cTX.value.listen((data) {
          List<int> listData = [0, 0, 0];
          if (data.length != 0) {
            for (int i = 0; i < data.length / 2; i++) {
              Uint8List bytes = Uint8List.fromList([data[i * 2], data[(i + 1) * 2 - 1]]);
              ByteBuffer byteBuffer = bytes.buffer;
              Uint16List thirtytwoBitList = byteBuffer.asUint16List();
              listData[i] = int.parse(thirtytwoBitList[0].toRadixString(2), radix: 2);
            }
            final DataSensorModel sensorData =
                new DataSensorModel(stbreath: listData[0].toDouble(), chbreath: listData[1].toDouble());
            add(UpdateDataSensor(sensorData: sensorData));
          }
        });
      } else {
        _receiveDataSubscription?.cancel();
        await state.cRX.write([Constants.CMD_STOP], withoutResponse: true);
        yield state.copyWith(isRealTimeMode: false);
        showMessage("Stop");
      }
    }
  }

  Stream<DataSensorState> _mapUpdateDataSensorToState(DataSensorState state, UpdateDataSensor event) async* {
    List<DataSensorModel> listScanUp = [];
    listScanUp.addAll(state.listSensorData);
    listScanUp.add(event.sensorData);

    _dataBr.add(event.sensorData);
    if (_dataBr.length == _deltaChartData) {
      _dataBr.removeAt(0);

      _chartSeriesControllerCh
          ?.updateDataSource(addedDataIndexes: <int>[_dataBr.length - 1], removedDataIndexes: <int>[0]);
      _chartSeriesControllerSt
          ?.updateDataSource(addedDataIndexes: <int>[_dataBr.length - 1], removedDataIndexes: <int>[0]);
    } else {
      _chartSeriesControllerCh?.updateDataSource(addedDataIndexes: <int>[_dataBr.length - 1]);
      _chartSeriesControllerSt?.updateDataSource(addedDataIndexes: <int>[_dataBr.length - 1]);
    }
    yield state.copyWith(listSensorData: listScanUp);
  }

  Stream<DataSensorState> _mapAddActivityToListToState(DataSensorState state, AddActivityToList event) async* {
    List<String> listActivityUp = [];
    listActivityUp.addAll(state.listActivity);
    listActivityUp.add(event.mark);
    yield state.copyWith(listActivity: listActivityUp);
    await preferences.setStringList(Constants.ACTIVITY, listActivityUp);
    //yield state.copyWith(listSensorData: state.listSensorData..addAll([event.sensorData]));
  }

  Stream<DataSensorState> _mapDeleteActivityFromListToState(
      DataSensorState state, DeleteActivityFromList event) async* {
    List<String> listActivityUp = [];
    listActivityUp.addAll(state.listActivity);
    listActivityUp.removeAt(event.index);
    yield state.copyWith(listActivity: listActivityUp);
    await preferences.setStringList(Constants.ACTIVITY, listActivityUp);
    //yield state.copyWith(listSensorData: state.listSensorData..addAll([event.sensorData]));
  }

  Stream<DataSensorState> _mapChooseActivityToState(DataSensorState state, ChooseActivity event) async* {
    String currentActivityUp = state.listActivity[event.index];

    final file = await _localFileActivity;
    DateTime time = DateTime.now();
    await file.writeAsString(time.toString() + ',' + currentActivityUp + '\r\n', mode: FileMode.append);
    yield state.copyWith(currentActivity: currentActivityUp);
    //yield state.copyWith(listSensorData: state.listSensorData..addAll([event.sensorData]));
  }

  Stream<DataSensorState> _mapSaveDataToLocalPathToState(DataSensorState state) async* {
    if (!state.isRealTimeMode || !state.isRecToMemoryMode) {
      final path = await _localPath;
      final nameData = fileName("sensor");
      final f = await _localFileData(nameData);

      int saveDataEndIndex = state.listSensorData.length;
      List<List<dynamic>> rows = [];
      for (int i = saveDataStartIndex; i < saveDataEndIndex; i++) {
        rows.add([
          state.listSensorData[i].lastTime.toString(),
          state.listSensorData[i].stbreath,
          state.listSensorData[i].chbreath
        ]);
      }
      String csv = const ListToCsvConverter().convert(rows);
      await f.writeAsString(csv, mode: FileMode.append);

      var stream = f.readAsBytes().asStream();
      var length = f.lengthSync();
      var name = f.path.split("/").last;
      var request = http.MultipartRequest('POST', url);
      request.files.add(http.MultipartFile('file', stream, length, filename: name));
      response = await request.send();

      saveDataStartIndex = saveDataEndIndex;
      showMessage("Saving data to: ${path}", toastLen: Toast.LENGTH_LONG);
    }
  }

  List<AreaSeries<DataSensorModel, DateTime>> getAreaSeries() {
    return <AreaSeries<DataSensorModel, DateTime>>[
      AreaSeries<DataSensorModel, DateTime>(
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesControllerSt = controller;
        },
        dataSource: _dataBr,
        xValueMapper: (DataSensorModel dataBr, _) => dataBr.lastTime,
        yValueMapper: (DataSensorModel dataBr, _) => dataBr.stbreath,
        animationDuration: 0,
        color: AppColors.latoGrey2,
        borderColor: AppColors.blueSkyI,
        borderWidth: 4,
        //gradient: AppColors.gradientColorsBlue,
      ),
      AreaSeries<DataSensorModel, DateTime>(
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesControllerCh = controller;
        },
        dataSource: _dataBr,
        xValueMapper: (DataSensorModel dataBr, _) => dataBr.lastTime,
        yValueMapper: (DataSensorModel dataBr, _) => dataBr.chbreath + 50,
        //gradient: AppColors.gradientColorsGreen,
        animationDuration: 0,
        color: AppColors.latoGrey2,
        borderColor: AppColors.green,
        borderWidth: 4,
      ),
    ];
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    print(directory.path);
    return directory.path;
  }

  Future<File> _localFileData(String name) async {
    final path = await _localPath;
    return File('$path/$name.csv');
  }

  String fileName(String postname) {
    DateTime t = DateTime.now();
    return '${t.year}${t.month}${t.day}${t.hour}${t.minute}${t.second}${t.millisecond}.' + postname;
  }

  Future<File> get _localFileActivity async {
    final path = await _localPath;
    return File('$path/sensordataactivity.txt');
  }

  @override
  Future<void> close() {
    _deviceSubscription?.cancel();
    _receiveDataSubscription?.cancel();
    return super.close();
  }
}
