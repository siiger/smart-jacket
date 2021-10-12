import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' as fromHooks;
import 'package:flutter_blue/flutter_blue.dart';

import 'package:norbusensor/src/features/devices/blocs/bloc_device/device_bloc.dart';
import 'package:norbusensor/src/config/app_colors.dart';
import 'package:norbusensor/src/common_widgets/border_widget.dart';

class ConnectionButtonWidget extends StatelessWidget {
  final DeviceBloc connectCubit;
  final BluetoothDevice device;
  final Color baseColor;
  final Color activColor;
  final Color deactivColor;
  ConnectionButtonWidget({
    this.connectCubit,
    this.device,
    this.baseColor = AppColors.transparent,
    this.activColor = AppColors.blueSkyI,
    this.deactivColor = AppColors.blueSkyIV,
  });
  @override
  Widget build(BuildContext context) {
    return fromHooks.BlocBuilder<DeviceBloc, DeviceState>(
      cubit: connectCubit,
      buildWhen: (previous, current) => previous.isConnected != current.isConnected,
      builder: (context, state) {
        return IconButton(
          iconSize: 35.0,
          icon: state.isConnected
              ? BorderWidget(
                  shape: BoxShape.circle,
                  widthOut: 35.0,
                  heightOut: 35.0,
                  borderColor: this.activColor,
                  baseColor: this.baseColor,
                  child: Icon(
                    Icons.link,
                    color: this.activColor,
                    size: 30.0,
                  ),
                )
              : BorderWidget(
                  shape: BoxShape.circle,
                  widthOut: 35.0,
                  heightOut: 35.0,
                  borderColor: this.deactivColor,
                  baseColor: this.baseColor,
                  child: Icon(
                    Icons.link_off,
                    color: this.deactivColor,
                    size: 30.0,
                  )),
          onPressed: () {
            connectCubit.add(ToggleConnectionToDevice(device));
          },
        );
      },
    );
  }
}
