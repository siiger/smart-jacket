import 'package:flutter/material.dart';
import 'package:norbusensor/src/config/app_colors.dart';

class BorderWidget extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color baseColor;
  final double widthOut;
  final double heightOut;

  BorderWidget({
    Key key,
    Widget this.child,
    Color this.borderColor = AppColors.blueSkyI,
    Color this.baseColor = AppColors.white80,
    double this.heightOut = 55.0,
    double this.widthOut = 55.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: <Widget>[
      Container(
        alignment: Alignment.center,
        width: this.widthOut,
        height: this.heightOut,
        decoration: new BoxDecoration(
            color: baseColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 3, color: borderColor)),
      ),
      Align(
        alignment: Alignment.center,
        child: this.child,
      )
    ]);
  }
}
