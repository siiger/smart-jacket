import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' as fromHooks;
import 'package:flutter_blue/flutter_blue.dart';

import 'package:norbusensor/src/features/devices/blocs/bloc_device/device_bloc.dart';

class ConnectionButtonWidget extends StatelessWidget {
  final connectCubit;
  final BluetoothDevice device;
  ConnectionButtonWidget(this.connectCubit, this.device);
  @override
  Widget build(BuildContext context) {
    return fromHooks.BlocBuilder<DeviceBloc, DeviceState>(
      cubit: connectCubit,
      buildWhen: (previous, current) => previous.isConnected != current.isConnected,
      builder: (context, state) {
        return RaisedButton(
          child: Text(
            state.isConnected ? "DISCONNECT" : "CONNECT",
            style: TextStyle(fontSize: 16),
          ),
          color: state.isConnected ? Colors.grey : Colors.cyan,
          textColor: Colors.white,
          onPressed: () {
            connectCubit.add(ToggleConnectionToDevice(device));
          },
        );
      },
    );
  }
}
