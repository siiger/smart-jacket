import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' as fromHooks;

import 'package:norbusensor/src/core/core_providers.dart';
import 'package:norbusensor/src/features/devices/widgets/scan_result_item_widget.dart';
import 'package:norbusensor/src/features/devices/blocs/bloc_device/device_bloc.dart';
import 'package:norbusensor/src/config/app_colors.dart';
import 'package:norbusensor/src/common_widgets/border_widget.dart';

class ScanDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DeviceBloc deviceBloc = BuildContextX(context).read(deviceBlocProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Searching Devices',
          style: TextStyle(color: AppColors.white80),
        ),
        actions: <Widget>[
          _ScanButton(deviceBloc),
        ],
      ),
      body: fromHooks.BlocBuilder<DeviceBloc, DeviceState>(
          cubit: deviceBloc,
          buildWhen: (previous, current) => (previous.listScan != current.listScan),
          builder: (context, state) {
            return state.listScan == null
                ? SizedBox.shrink()
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    primary: false,
                    itemCount: state.listScan.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 15);
                    },
                    itemBuilder: (context, index) {
                      return ScanResultItemWidget(scanResultItem: state.listScan.elementAt(index));
                    },
                  );
          }),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final scanCubit;
  _ScanButton(this.scanCubit);
  @override
  Widget build(BuildContext context) {
    return fromHooks.BlocBuilder<DeviceBloc, DeviceState>(
      cubit: scanCubit,
      buildWhen: (previous, current) => previous.isScanning != current.isScanning,
      builder: (context, state) {
        return IconButton(
          iconSize: 35.0,
          icon: state.isScanning
              ? BorderWidget(
                  shape: BoxShape.circle,
                  widthOut: 35.0,
                  heightOut: 35.0,
                  borderColor: AppColors.white,
                  baseColor: AppColors.blueSkyI,
                  child: Icon(
                    Icons.wifi_tethering,
                    color: AppColors.white,
                    size: 30.0,
                  ))
              : BorderWidget(
                  shape: BoxShape.circle,
                  widthOut: 35.0,
                  heightOut: 35.0,
                  borderColor: AppColors.white80,
                  baseColor: AppColors.blueSkyI,
                  child: Icon(
                    Icons.wifi_tethering_off,
                    color: AppColors.white80,
                    size: 30.0,
                  )),
          onPressed: () {
            scanCubit.add(ToggleScanForDevices());
          },
        );
      },
    );
  }
}
