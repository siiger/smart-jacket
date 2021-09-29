import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' as fromHooks;

import 'package:norbusensor/src/core/core_providers.dart';
import 'package:norbusensor/src/features/datasensor/blocs/bloc_data_sensor/data_sensor_bloc.dart';
import 'package:norbusensor/src/features/devices/widgets/connection_button_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DataSensorScreen extends StatelessWidget {
  static const String routeName = '/sensor_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.amber[100]),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          'Data Flow',
          style: TextStyle(color: Colors.white70),
        ),
        actions: <Widget>[
          ConnectionButtonWidget(BuildContextX(context).read(deviceBlocProvider),
              BuildContextX(context).read(deviceBlocProvider).state.device),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                _RealTimeButton(BuildContextX(context).read(sensorBlocProvider)),
                _RecToMemoryButton(BuildContextX(context).read(sensorBlocProvider)),
                _ReadFromMemoryButton(BuildContextX(context).read(sensorBlocProvider)),
                _SaveDataToLocalPathButton(BuildContextX(context).read(sensorBlocProvider)),
              ]),
            ),
            _MarkActivityField(BuildContextX(context).read(sensorBlocProvider)),
            _ViewDataPanel(BuildContextX(context).read(sensorBlocProvider)),
          ],
        ),
      ),
    );
  }
}

class _ViewDataPanel extends StatelessWidget {
  final sensorCubit;

  final int deltaData = 360;

  _ViewDataPanel(this.sensorCubit);
  @override
  Widget build(BuildContext context) {
    return fromHooks.BlocBuilder<DataSensorBloc, DataSensorState>(
        cubit: BuildContextX(context).read(sensorBlocProvider),
        buildWhen: (previous, current) => (previous.listSensorData != current.listSensorData),
        builder: (context, state) {
          List<double> dataBrSt = [1000.0];
          List<double> dataBrCh = [1000.0];
          int dataLength = state.listSensorData.length;
          if (dataLength != 0) {
            if (dataLength <= deltaData) {
              dataBrSt = state.listSensorData.map((e) => e.stbreath).toList();
              dataBrCh = state.listSensorData.map((e) => e.chbreath).toList();
            } else if (dataLength > deltaData) {
              dataBrSt =
                  state.listSensorData.getRange(dataLength - deltaData, dataLength).map((e) => e.stbreath).toList();
              dataBrCh =
                  state.listSensorData.getRange(dataLength - deltaData, dataLength).map((e) => e.chbreath).toList();
            }
          }
          Oscilloscope scopeChest = Oscilloscope(
            showYAxis: true,
            yAxisColor: Colors.orange,
            padding: 10.0,
            backgroundColor: Color(0xff20212a),
            traceColor: Colors.green[200],
            yAxisMax: 1900,
            yAxisMin: 1400,
            dataSet: dataBrCh,
          );

          Oscilloscope scopeStom = Oscilloscope(
            showYAxis: true,
            padding: 10.0,
            backgroundColor: Color(0xff20212a),
            traceColor: Colors.blue[200],
            yAxisMax: 2100,
            yAxisMin: 1600,
            dataSet: dataBrSt,
          );

          return Center(
            child: Column(children: <Widget>[
              Container(
                width: 360,
                height: 200,
                child: scopeChest,
              ),
              Container(
                width: 360,
                height: 200,
                child: scopeStom,
              ),
            ]),
          );
        });
  }
}

class _MarkActivityField extends StatelessWidget {
  final sensorCubit;
  _MarkActivityField(this.sensorCubit);
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return fromHooks.BlocBuilder<DataSensorBloc, DataSensorState>(
      cubit: sensorCubit,
      buildWhen: (previous, current) =>
          previous.listActivity != current.listActivity || previous.currentActivity != current.currentActivity,
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.amber[100],
              ),
              bottom: BorderSide(
                color: Colors.amber[100],
              ),
            ),
          ),
          child: ListTileTheme(
            textColor: Colors.white,
            tileColor: Color(0xff363741),
            iconColor: Colors.amber[100],
            child: ExpansionTile(
              backgroundColor: Color(0xff363741),
              childrenPadding: const EdgeInsets.only(
                left: 5.0,
                right: 5.0,
              ),
              key: ValueKey('Sensor'),
              title: Text(state.currentActivity,
                  style: TextStyle(
                    color: Colors.white,
                  )),
              children: List.generate(
                (state.listActivity.length + 1),
                (index) {
                  if (index < state.listActivity.length) {
                    return Card(
                        color: Color(0x24ffffff),
                        child: Row(
                            key: ValueKey('Sensor' + index.toString()),
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 270,
                                height: 35,
                                child: ListTile(
                                  tileColor: Colors.transparent,
                                  title: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 15.0,
                                    ),
                                    child: Text(state.listActivity.elementAt(index).toString(),
                                        style: TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
                                  ),
                                  onTap: () {
                                    sensorCubit.add(ChooseActivity(index: index));
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.amber[100]),
                                onPressed: () {
                                  sensorCubit.add(DeleteActivityFromList(index: index));
                                },
                              ),
                            ]));
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(
                        right: 8.0,
                      ),
                      child: Row(
                        key: ValueKey('Sensor' + index.toString()),
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Form(
                            key: _formKey,
                            child: Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Type new activity",
                                  //icon: Icon(Icons.face),
                                ),
                                //validator: (val) {},
                                controller: TextEditingController()..text = ' ',
                                onSaved: (value) => sensorCubit.add(AddActivityToList(mark: value)),
                                //maxLength: 1,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.amber[100]),
                            onPressed: () {
                              _formKey.currentState.save();
                            },
                          )
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RealTimeButton extends StatelessWidget {
  final sensorCubit;
  _RealTimeButton(this.sensorCubit);
  @override
  Widget build(BuildContext context) {
    return fromHooks.BlocBuilder<DataSensorBloc, DataSensorState>(
      cubit: sensorCubit,
      buildWhen: (previous, current) => previous.isRealTimeMode != current.isRealTimeMode,
      builder: (context, state) {
        return IconButton(
          iconSize: 35.0,
          icon: state.isRealTimeMode
              ? Icon(Icons.stop_circle_outlined, color: Colors.red[500])
              : Icon(Icons.play_circle, color: Colors.amber[100]),
          onPressed: () {
            sensorCubit.add(ToggleRealTimeDataAccess());
            Fluttertoast.showToast(
              msg: state.isRealTimeMode ? "Stop" : "Run",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.amber[100],
              textColor: Colors.black,
              fontSize: 16.0,
            );
          },
        );
      },
    );
  }
}

class _RecToMemoryButton extends StatelessWidget {
  final sensorCubit;
  _RecToMemoryButton(this.sensorCubit);
  @override
  Widget build(BuildContext context) {
    return fromHooks.BlocBuilder<DataSensorBloc, DataSensorState>(
      cubit: sensorCubit,
      buildWhen: (previous, current) => previous.isRecToMemoryMode != current.isRecToMemoryMode,
      builder: (context, state) {
        return IconButton(
          iconSize: 35.0,
          icon: state.isRecToMemoryMode
              ? Icon(Icons.stop_circle_outlined, color: Colors.red[500])
              : Icon(Icons.radio_button_checked, color: Colors.amber[100]),
          onPressed: () {
            sensorCubit.add(ToggleRecDataToMemory());
            Fluttertoast.showToast(
              msg: state.isRecToMemoryMode ? "Stop" : "Record",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.amber[100],
              textColor: Colors.black,
              fontSize: 16.0,
            );
          },
        );
      },
    );
  }
}

class _ReadFromMemoryButton extends StatelessWidget {
  final sensorCubit;
  _ReadFromMemoryButton(this.sensorCubit);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 35.0,
      icon: Icon(Icons.download_for_offline, color: Colors.amber[100]),
      onPressed: () {
        sensorCubit.add(ReadDataFromMemory());
        Fluttertoast.showToast(
          msg: "Reading data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.amber[100],
          textColor: Colors.black,
          fontSize: 16.0,
        );
      },
    );
  }
}

class _SaveDataToLocalPathButton extends StatelessWidget {
  final sensorCubit;
  _SaveDataToLocalPathButton(this.sensorCubit);
  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 35.0,
      icon: Icon(Icons.save, color: Colors.amber[100]),
      onPressed: () {
        sensorCubit.add(SaveDataToLocalPath());
        Fluttertoast.showToast(
            msg: "Saving data",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.amber[100],
            textColor: Colors.black,
            fontSize: 16.0);
      },
    );
  }
}
