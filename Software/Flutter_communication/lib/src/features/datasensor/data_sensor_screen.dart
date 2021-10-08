import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' as fromHooks;
import 'package:norbusensor/src/features/datasensor/models/data_sensor_model.dart';

import 'package:norbusensor/src/core/core_providers.dart';
import 'package:norbusensor/src/features/datasensor/blocs/bloc_data_sensor/data_sensor_bloc.dart';
import 'package:norbusensor/src/features/devices/widgets/connection_button_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:norbusensor/src/config/app_colors.dart';
import 'package:norbusensor/src/common_widgets/border_widget.dart';

class DataSensorScreen extends StatelessWidget {
  static const String routeName = '/sensor_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.white70),
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

List<DataSensorModel> dataBr = [];

class _ViewDataPanel extends StatelessWidget {
  final sensorCubit;
  ChartSeriesController _chartSeriesControllerCh;
  ChartSeriesController _chartSeriesControllerSt;

  _ViewDataPanel(this.sensorCubit);
  @override
  Widget build(BuildContext context) {
    return fromHooks.BlocBuilder<DataSensorBloc, DataSensorState>(
        cubit: BuildContextX(context).read(sensorBlocProvider),
        buildWhen: (previous, current) => (previous.listSensorData != current.listSensorData),
        builder: (context, state) {
          final _dataSeries = _getChartData(state.listSensorData);
          /*
          Oscilloscope scopeChest = Oscilloscope(
            showYAxis: true,
            yAxisColor: Colors.orange,
            padding: 10.0,
            backgroundColor: Colors.transparent,
            traceColor: Colors.green[200],
            yAxisMax: 1900,
            yAxisMin: 1400,
            dataSet: dataBrCh,
          );

          Oscilloscope scopeStom = Oscilloscope(
            showYAxis: true,
            padding: 10.0,
            backgroundColor: Colors.transparent,
            traceColor: Colors.blue[200],
            yAxisMax: 2100,
            yAxisMin: 1600,
            dataSet: dataBrSt,
          );
           */
          return Center(
            child: Column(children: <Widget>[
              Container(
                width: 360,
                height: 400,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  // Initialize category axis
                  primaryXAxis: CategoryAxis(isVisible: false),
                  primaryYAxis: CategoryAxis(isVisible: false),
                  series: _dataSeries,
                ),
              ),
            ]),
          );
        });
  }

  List<AreaSeries<DataSensorModel, DateTime>> _getChartData(List<DataSensorModel> listSensorData) {
    final int deltaData = 100;
    int dataLength = listSensorData.length;
    if (dataLength != 0) {
      dataBr.add(listSensorData[dataLength - 1]);
      if (dataLength <= deltaData) {
        //_chartSeriesControllerCh?.updateDataSource(addedDataIndexes: <int>[dataBr.length - 1]);
        //_chartSeriesControllerSt?.updateDataSource(addedDataIndexes: <int>[dataBr.length - 1]);
      } else if (dataLength > deltaData) {
        dataBr.removeAt(0);

        _chartSeriesControllerCh
            ?.updateDataSource(addedDataIndexes: <int>[dataBr.length - 1], removedDataIndexes: <int>[0]);
        _chartSeriesControllerSt
            ?.updateDataSource(addedDataIndexes: <int>[dataBr.length - 1], removedDataIndexes: <int>[0]);
      }
    }
    return <AreaSeries<DataSensorModel, DateTime>>[
      AreaSeries<DataSensorModel, DateTime>(
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesControllerSt = controller;
        },
        dataSource: dataBr,
        xValueMapper: (DataSensorModel dataBr, _) => dataBr.lastTime,
        yValueMapper: (DataSensorModel dataBr, _) => dataBr.stbreath,
      ),
      AreaSeries<DataSensorModel, DateTime>(
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesControllerCh = controller;
        },
        dataSource: dataBr,
        xValueMapper: (DataSensorModel dataBr, _) => dataBr.lastTime,
        yValueMapper: (DataSensorModel dataBr, _) => dataBr.chbreath - 300,
      ),
    ];
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
                color: AppColors.blueSkyI,
                width: 2.5,
              ),
              bottom: BorderSide(
                color: AppColors.blueSkyI,
                width: 3.0,
              ),
            ),
          ),
          child: ListTileTheme(
            textColor: AppColors.blueGrey,
            tileColor: AppColors.latoGrey,
            iconColor: AppColors.blueSkyI,
            child: ExpansionTile(
              collapsedIconColor: AppColors.blueSkyI,
              iconColor: AppColors.blueSkyI,
              backgroundColor: AppColors.latoGrey,
              childrenPadding: const EdgeInsets.only(
                left: 5.0,
                right: 5.0,
              ),
              key: ValueKey('Sensor'),
              title: Text(state.currentActivity.isNotEmpty ? state.currentActivity : 'Mark current activity',
                  style: TextStyle(
                    color: state.currentActivity.isNotEmpty ? AppColors.blueGrey : AppColors.grey,
                  )),
              children: List.generate(
                (state.listActivity.length + 1),
                (index) {
                  if (index < state.listActivity.length) {
                    return Card(
                        color: AppColors.white80,
                        shadowColor: AppColors.blueSkyI,
                        elevation: 3.0,
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
                                        style: TextStyle(color: AppColors.blueGrey), overflow: TextOverflow.ellipsis),
                                  ),
                                  onTap: () {
                                    sensorCubit.add(ChooseActivity(index: index));
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: AppColors.blueSkyI),
                                onPressed: () {
                                  sensorCubit.add(DeleteActivityFromList(index: index));
                                },
                              ),
                            ]));
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(
                        right: 5.0,
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
                                  labelText: "Add new activity",
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
                            icon: Icon(Icons.add, color: AppColors.blueSkyI),
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
          iconSize: 55.0,
          icon: state.isRealTimeMode
              ? BorderWidget(
                  child: Icon(
                  Icons.stop_circle_outlined,
                  color: Colors.red[200],
                  size: 35.0,
                ))
              : BorderWidget(
                  child: Icon(
                    Icons.play_circle,
                    size: 35.0,
                    color: AppColors.blueSkyI,
                  ),
                ),
          onPressed: () {
            sensorCubit.add(ToggleRealTimeDataAccess());
            Fluttertoast.showToast(
              msg: state.isRealTimeMode ? "Stop" : "Run",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: AppColors.blueSkyI,
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
          iconSize: 55.0,
          icon: state.isRecToMemoryMode
              ? BorderWidget(
                  child: Icon(
                    Icons.stop_circle_outlined,
                    color: Colors.red[200],
                    size: 35.0,
                  ),
                  borderColor: Colors.red[200],
                )
              : BorderWidget(
                  child: Icon(
                  Icons.radio_button_checked,
                  size: 35.0,
                  color: AppColors.blueSkyI,
                )),
          onPressed: () {
            sensorCubit.add(ToggleRecDataToMemory());
            Fluttertoast.showToast(
              msg: state.isRecToMemoryMode ? "Stop" : "Record",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: AppColors.blueSkyI,
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
      iconSize: 55.0,
      icon: BorderWidget(
        child: Icon(
          Icons.download_for_offline,
          size: 35.0,
          color: AppColors.blueSkyI,
        ),
      ),
      onPressed: () {
        sensorCubit.add(ReadDataFromMemory());
        Fluttertoast.showToast(
          msg: "Reading data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: AppColors.blueSkyI,
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
      iconSize: 55.0,
      icon: BorderWidget(
        child: Icon(
          Icons.save,
          size: 35.0,
          color: AppColors.blueSkyI,
        ),
      ),
      onPressed: () {
        sensorCubit.add(SaveDataToLocalPath());
        Fluttertoast.showToast(
            msg: "Saving data",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: AppColors.blueSkyI,
            textColor: Colors.black,
            fontSize: 16.0);
      },
    );
  }
}
