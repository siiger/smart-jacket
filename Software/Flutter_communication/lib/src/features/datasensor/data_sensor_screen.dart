import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' as fromHooks;

import 'package:norbusensor/src/core/core_providers.dart';
import 'package:norbusensor/src/features/datasensor/blocs/bloc_data_sensor/data_sensor_bloc.dart';
import 'package:norbusensor/src/features/devices/widgets/connection_button_widget.dart';

class DataSensorScreen extends StatelessWidget {
  static const String routeName = '/sensor_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor'),
        actions: <Widget>[
          ConnectionButtonWidget(BuildContextX(context).read(deviceBlocProvider),
              BuildContextX(context).read(deviceBlocProvider).state.device),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
              _RealTimeButton(BuildContextX(context).read(sensorBlocProvider)),
              _RecToMemoryButton(BuildContextX(context).read(sensorBlocProvider)),
              _ReadFromMemoryButton(BuildContextX(context).read(sensorBlocProvider)),
              _SaveDataToLocalPathButton(BuildContextX(context).read(sensorBlocProvider)),
            ]),
          ),
          _MarkActivityField(BuildContextX(context).read(sensorBlocProvider)),
          _ViewDataPanel(BuildContextX(context).read(sensorBlocProvider)),
        ]),
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
            backgroundColor: Colors.black,
            traceColor: Colors.green,
            yAxisMax: 1900,
            yAxisMin: 1400,
            dataSet: dataBrCh,
          );

          Oscilloscope scopeStom = Oscilloscope(
            showYAxis: true,
            padding: 10.0,
            backgroundColor: Colors.black,
            traceColor: Colors.blue,
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
        return ExpansionTile(
          key: ValueKey('Sensor'),
          title: new Text(state.currentActivity),
          children: List.generate(
            (state.listActivity.length + 1),
            (index) {
              if (index < state.listActivity.length) {
                return Row(
                    key: ValueKey('Sensor' + index.toString()),
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 270,
                        height: 35,
                        child: ListTile(
                          title: Text(state.listActivity.elementAt(index).toString()),
                          onTap: () {
                            sensorCubit.add(ChooseActivity(index: index));
                          },
                        ),
                      ),
                      RaisedButton(
                        child: Text(
                          'Delete',
                          //state.isRealTimeMode ? "Stop" : "Run",
                          style: TextStyle(fontSize: 16),
                        ),
                        color: Colors.red,
                        textColor: Colors.white,
                        onPressed: () {
                          sensorCubit.add(DeleteActivityFromList(index: index));
                        },
                      )
                    ]);
              } else {
                return Row(
                    key: ValueKey('Sensor' + index.toString()),
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        child: Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Type activity",
                              //icon: Icon(Icons.face),
                            ),
                            //validator: (val) {},
                            controller: TextEditingController()..text = ' ',
                            onSaved: (value) => sensorCubit.add(AddActivityToList(mark: value)),
                            //maxLength: 1,
                          ),
                        ),
                      ),
                      RaisedButton(
                        child: Text(
                          'Add',
                          //state.isRealTimeMode ? "Stop" : "Run",
                          style: TextStyle(fontSize: 16),
                        ),
                        color: Colors.green,
                        textColor: Colors.white,
                        onPressed: () {
                          _formKey.currentState.save();
                        },
                      )
                    ]);
              }
            },
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
        return RaisedButton(
          child: Text(
            state.isRealTimeMode ? "Stop" : "Run",
            style: TextStyle(fontSize: 16),
          ),
          color: state.isRealTimeMode ? Colors.red : Colors.amber,
          textColor: Colors.white,
          onPressed: () {
            sensorCubit.add(ToggleRealTimeDataAccess());
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
        return RaisedButton(
          child: Text(
            state.isRecToMemoryMode ? "Stop" : "Record",
            style: TextStyle(fontSize: 16),
          ),
          color: state.isRecToMemoryMode ? Colors.red : Colors.amber,
          textColor: Colors.white,
          onPressed: () {
            sensorCubit.add(ToggleRecDataToMemory());
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
    return RaisedButton(
      child: Text(
        "Read",
        style: TextStyle(fontSize: 16),
      ),
      color: Colors.green,
      textColor: Colors.white,
      onPressed: () {
        sensorCubit.add(ReadDataFromMemory());
      },
    );
  }
}

class _SaveDataToLocalPathButton extends StatelessWidget {
  final sensorCubit;
  _SaveDataToLocalPathButton(this.sensorCubit);
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text(
        "Save",
        style: TextStyle(fontSize: 16),
      ),
      color: Colors.green,
      textColor: Colors.white,
      onPressed: () {
        sensorCubit.add(SaveDataToLocalPath());
      },
    );
  }
}
