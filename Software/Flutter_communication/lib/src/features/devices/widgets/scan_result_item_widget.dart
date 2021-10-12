import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:norbusensor/src/core/core_providers.dart';
import 'package:norbusensor/src/features/datasensor/data_sensor_screen.dart';

import 'package:norbusensor/src/features/devices/widgets/connection_button_widget.dart';
import 'package:norbusensor/src/config/app_colors.dart';

class ScanResultItemWidget extends StatelessWidget {
  final BluetoothDevice scanResultItem;

  const ScanResultItemWidget({
    this.scanResultItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.latoGrey2,
      child: InkWell(
        splashColor: Theme.of(context).accentColor,
        focusColor: Theme.of(context).accentColor,
        onTap: () {
          BuildContextX(context).read(navigatiorStateProvider).pushNamed(DataSensorScreen.routeName);
        },
        child: Container(
          alignment: Alignment.center,
          height: 60,
          decoration: new BoxDecoration(
            color: AppColors.transparent,
            border: Border(
              top: BorderSide(width: 2.0, color: AppColors.blueSkyI),
              bottom: BorderSide(width: 2.0, color: AppColors.blueSkyI),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  left: 14.0,
                ),
                child: Text(
                  scanResultItem.name.toString(),
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.grey2),
                ),
              ),
              Spacer(),
              ConnectionButtonWidget(
                  connectCubit: BuildContextX(context).read(deviceBlocProvider), device: scanResultItem),
            ],
          ),
        ),
      ),
    );
  }
}
