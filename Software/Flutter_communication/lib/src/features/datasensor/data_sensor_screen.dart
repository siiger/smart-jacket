import 'package:flutter/material.dart';
import 'package:norbusensor/src/features/datasensor/widgets/item_activity_widget.dart';
import 'package:norbusensor/src/features/datasensor/widgets/new_item_activity_widget.dart';
import 'package:norbusensor/src/features/devices/blocs/bloc_device/device_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' as fromHooks;

import 'package:norbusensor/src/features/datasensor/blocs/bloc_data_sensor/data_sensor_bloc.dart';
import 'package:norbusensor/src/features/devices/widgets/connection_button_widget.dart';
import 'package:norbusensor/src/config/app_colors.dart';
import 'package:norbusensor/src/common_widgets/border_widget.dart';
import 'package:norbusensor/src/common_widgets/listview_separators.dart';
import 'package:intl/intl.dart';

class DataSensorScreen extends StatelessWidget {
  static const String routeName = '/sensor_page';

  final DeviceBloc deviceBloc;
  final DataSensorBloc sensorCubit;
  DataSensorScreen({this.deviceBloc, this.sensorCubit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.white80),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          'Data Flow Control',
          style: TextStyle(color: AppColors.white80),
        ),
        actions: <Widget>[
          ConnectionButtonWidget(
            connectCubit: deviceBloc,
            device: deviceBloc.state.device,
            activColor: AppColors.white,
            deactivColor: AppColors.white70,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
                _RealTimeButton(sensorCubit),
                _RecToMemoryButton(sensorCubit),
                _ReadFromMemoryButton(sensorCubit),
                _SaveDataToLocalPathButton(sensorCubit),
              ]),
            ),
            Stack(children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: _ViewDataPanel(sensorCubit),
              ),
              _MarkActivityField(sensorCubit),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ViewDataPanel extends StatelessWidget {
  final DataSensorBloc sensorCubit;

  _ViewDataPanel(this.sensorCubit);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: <Widget>[
        Container(
          width: 360,
          height: 400,
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            //plotAreaBorderColor: AppColors.blueSkyI,
            //borderWidth: 2,
            //borderColor: AppColors.blueSkyI,
            // Initialize category axis
            primaryXAxis: DateTimeAxis(
              isVisible: false,
              //rangePadding: ChartRangePadding.round,
              intervalType: DateTimeIntervalType.auto,
              majorGridLines: const MajorGridLines(width: 0),
              interval: 2,
              labelIntersectAction: AxisLabelIntersectAction.rotate45,
              dateFormat: DateFormat.yMd(),
            ),
            primaryYAxis: NumericAxis(
                isVisible: false,
                minimum: 1500,
                maximum: 1900,
                //rangePadding: ChartRangePadding.none,
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0)),
            series: sensorCubit.getAreaSeries(),
          ),
        ),
      ]),
    );
  }
}

class _MarkActivityField extends StatelessWidget {
  _MarkActivityField(this.sensorCubit);
  final sensorCubit;

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
                    fontSize: 18.0,
                    color: state.currentActivity.isNotEmpty ? AppColors.grey2 : AppColors.grey1,
                  )),
              children: List.generate(
                (state.listActivity.length + 2),
                (index) {
                  if (index == 0) {
                    return ListViewSeparatorWidget(padding: EdgeInsets.only(left: 6.0, right: 6.0, bottom: 6.0));
                  } else if (index <= state.listActivity.length) {
                    return ItemActivityWidget(
                      key: ValueKey('Sensor' + index.toString()),
                      text: state.listActivity.elementAt(index - 1).toString(),
                      onTap: () => sensorCubit.add(ChooseActivity(index: index - 1)),
                      onPressedIcon: () => sensorCubit.add(DeleteActivityFromList(index: index - 1)),
                    );
                  } else {
                    return NewItemActivityWidget(
                      key: ValueKey('Sensor' + index.toString()),
                      onSavedValue: (value) => sensorCubit.add(AddActivityToList(mark: value)),
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
  final DataSensorBloc sensorCubit;
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
                  borderColor: AppColors.red,
                  baseColor: AppColors.latoGrey,
                  hasShadow: false,
                  child: Icon(
                    Icons.stop_circle_outlined,
                    color: AppColors.red,
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
                  borderColor: AppColors.red,
                  baseColor: AppColors.latoGrey,
                  hasShadow: false,
                  child: Icon(
                    Icons.stop_circle_outlined,
                    color: AppColors.red,
                    size: 35.0,
                  ),
                )
              : BorderWidget(
                  child: Icon(
                  Icons.radio_button_checked,
                  size: 35.0,
                  color: AppColors.blueSkyI,
                )),
          onPressed: () {
            sensorCubit.add(ToggleRecDataToMemory());
          },
        );
      },
    );
  }
}

class _ReadFromMemoryButton extends StatelessWidget {
  final DataSensorBloc sensorCubit;
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
      },
    );
  }
}

class _SaveDataToLocalPathButton extends StatelessWidget {
  final DataSensorBloc sensorCubit;
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
      },
    );
  }
}
