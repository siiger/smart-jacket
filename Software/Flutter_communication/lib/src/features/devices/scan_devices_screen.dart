import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' as fromHooks;

import 'package:norbusensor/src/core/core_providers.dart';
import 'package:norbusensor/src/features/devices/widgets/scan_result_item_widget.dart';
import 'package:norbusensor/src/features/devices/blocs/bloc_device/device_bloc.dart';

class ScanDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
        actions: <Widget>[
          _ScanButton(BuildContextX(context).read(deviceBlocProvider)),
        ],
      ),
      body: fromHooks.BlocBuilder<DeviceBloc, DeviceState>(
          cubit: BuildContextX(context).read(deviceBlocProvider),
          buildWhen: (previous, current) => (previous.listScan != current.listScan),
          builder: (context, state) {
            return state.listScan == null
                ? Container()
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
        return RaisedButton(
          child: Text(
            state.isScanning ? "STOP" : "SCAN",
            style: TextStyle(fontSize: 16),
          ),
          color: state.isScanning ? Colors.red : Colors.indigo,
          textColor: Colors.white,
          onPressed: () {
            scanCubit.add(ToggleScanForDevices());
          },
        );
      },
    );
  }
}
