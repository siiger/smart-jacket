class Constants {
  static const ACTIVITY = 'listActivity';
  // device Proprietary characteristics of the ISSC service
  static const ISSC_PROPRIETARY_SERVICE_UUID = "0000fe40-cc7a-482a-984a-7f2ed5b3e58f";
  // device char for ISSC characteristics
  static const UUIDSTR_ISSC_TRANS_TX = "0000fe42-8e22-4541-9d4c-21edae82ed19";
  static const UUIDSTR_ISSC_TRANS_RX = "0000fe41-8e22-4541-9d4c-21edae82ed19";
  static const NAME_DEVICE = "P2PSRV1";
  // commands
  static const CMD_RUN = 0;
  static const CMD_RECORD = 1;
  static const CMD_READ = 2;
  static const CMD_STOP = 4;
  // marcks for date data into data flow
  static const List<int> DATA_TIME_BEGIN = [255, 0, 0, 255];
  static const List<int> DATA_TIME_END = [255, 1, 1, 255];
}
