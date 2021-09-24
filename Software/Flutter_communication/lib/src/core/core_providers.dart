import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverbloc/riverbloc.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';

import 'package:norbusensor/src/features/devices/blocs/bloc_device/device_bloc.dart';
import 'package:norbusensor/src/features/datasensor/blocs/bloc_data_sensor/data_sensor_bloc.dart';

final flutterBlueInstanceProvider = Provider((ref) => FlutterBlue.instance);

final deviceBlocProvider = BlocProvider((ref) => DeviceBloc(flutterBlue: ref.read(flutterBlueInstanceProvider)));

final sensorBlocProvider = BlocProvider((ref) => DataSensorBloc(deviceBloc: ref.read(deviceBlocProvider)));

final navigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());
final navigatiorStateProvider = Provider((ref) => ref.read(navigatorKeyProvider).currentState);
