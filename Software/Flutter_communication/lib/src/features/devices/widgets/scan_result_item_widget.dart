import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' as fromHooks;
import 'package:flutter_blue/flutter_blue.dart';

import 'package:norbusensor/src/core/core_providers.dart';
import 'package:norbusensor/src/features/datasensor/data_sensor_screen.dart';

import 'package:norbusensor/src/features/devices/widgets/connection_button_widget.dart';

class ScanResultItemWidget extends StatelessWidget {
  final BluetoothDevice scanResultItem;

  const ScanResultItemWidget({
    this.scanResultItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        BuildContextX(context).read(navigatiorStateProvider).pushNamed(DataSensorScreen.routeName);
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.amber[100],
              ),
              bottom: BorderSide(
                color: Colors.amber[100],
              ),
            ),
            boxShadow: [
              BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            Text(
              scanResultItem.name.toString(),
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            Spacer(),
            ConnectionButtonWidget(BuildContextX(context).read(deviceBlocProvider), scanResultItem),
          ])),
    );
  }
}
