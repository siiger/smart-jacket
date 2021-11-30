import 'dart:io';

import 'package:norbusensor/src/core/core_providers.dart';
import 'package:norbusensor/src/features/datasensor/data_sensor_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Routes {
  final BuildContext context;
  Routes(this.context);
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case DataSensorScreen.routeName:
        return _getPageRoute(
            routeName: settings.name,
            viewToShow: DataSensorScreen(
                deviceBloc: BuildContextX(context).read(deviceBlocProvider),
                sensorCubit: BuildContextX(context).read(sensorBlocProvider)));
        break;
      default:
        return MaterialPageRoute(builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.96),
            appBar: AppBar(
              title: Text('Error'),
            ),
            body: Center(
              child: Text(settings.name),
            ),
          );
        });
    }
  }

  static PageRoute _getPageRoute({String routeName, Widget viewToShow, Object arguments}) {
    return Platform.isIOS
        ? CupertinoPageRoute(settings: RouteSettings(name: routeName, arguments: arguments), builder: (_) => viewToShow)
        : MaterialPageRoute(settings: RouteSettings(name: routeName, arguments: arguments), builder: (_) => viewToShow);
  }
}
