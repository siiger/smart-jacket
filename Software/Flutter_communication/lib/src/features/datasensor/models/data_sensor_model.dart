class DataSensorModel {
  final double stbreath;
  final double chbreath;
  final DateTime lastTime;

  DataSensorModel({this.stbreath, this.chbreath, DateTime lastTime}) : this.lastTime = lastTime ?? DateTime.now();
}
