import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' as fromHooks;

import 'package:norbusensor/src/core/core_providers.dart';
import 'package:norbusensor/src/features/devices/widgets/scan_result_item_widget.dart';
import 'package:norbusensor/src/features/devices/blocs/bloc_device/device_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ScanDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Searching Devices',
          style: TextStyle(color: Colors.white70),
        ),
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
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              width: 35.0,
              height: 35.0,
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 3, color: state.isScanning ? Colors.amber[100] : Colors.amber[100])),
            ),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                iconSize: 30.0,
                icon: state.isScanning
                    ? Icon(Icons.wifi_tethering, color: Colors.amber[100])
                    : Icon(Icons.wifi_tethering_off, color: Colors.amber[100]),
                onPressed: () {
                  scanCubit.add(ToggleScanForDevices());
                  Fluttertoast.showToast(
                    msg: state.isScanning ? "Stop" : "Scanning",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.amber[100],
                    textColor: Colors.black,
                    fontSize: 16.0,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
