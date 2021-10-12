import 'package:fluttertoast/fluttertoast.dart';
import 'package:norbusensor/src/config/app_colors.dart';

Future<bool> showMessage(String msg, {Toast toastLen = Toast.LENGTH_SHORT}) {
  return Fluttertoast.showToast(
    msg: msg,
    toastLength: toastLen,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: AppColors.blueSkyVI,
    textColor: AppColors.blueGreyLight,
    fontSize: 16.0,
  );
}
