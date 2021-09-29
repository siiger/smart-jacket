import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' as fromHooks;
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
        return Stack(alignment: Alignment.center, children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: 35.0,
            height: 35.0,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 3,
                  color: Colors.amber[100],
                )),
          ),
          Align(
            alignment: Alignment.center,
            child: IconButton(
              iconSize: 30.0,
              icon: state.isConnected
                  ? Icon(
                      Icons.link,
                      color: Colors.amber[100],
                    )
                  : Icon(
                      Icons.link_off,
                      color: Colors.amber[100],
                    ),
              onPressed: () {
                connectCubit.add(ToggleConnectionToDevice(device));
                Fluttertoast.showToast(
                  msg: state.isConnected ? "Connected" : "Disconnect",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.amber[100],
                  textColor: Colors.black,
                  fontSize: 16.0,
                );
              },
            ),
          )
        ]);
      },
    );
  }
}
