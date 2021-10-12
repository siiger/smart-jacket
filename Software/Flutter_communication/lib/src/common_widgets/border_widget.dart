import 'package:flutter/material.dart';
import 'package:norbusensor/src/config/app_colors.dart';

class BorderWidget extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color baseColor;
  final double widthOut;
  final double heightOut;
  final double widthLine;
  final double borderRadius;
  final BoxShape shape;
  final bool hasShadow;

  BorderWidget({
    Key key,
    Widget this.child,
    BoxShape this.shape = BoxShape.rectangle,
    Color this.borderColor = AppColors.blueSkyI,
    Color this.baseColor = AppColors.latoGrey2,
    double this.heightOut = 55.0,
    double this.widthOut = 55.0,
    double this.widthLine = 3,
    double this.borderRadius = 10,
    bool this.hasShadow = true,
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
          shape: this.shape,
          borderRadius: this.shape == BoxShape.rectangle ? BorderRadius.circular(this.borderRadius) : null,
          border: Border.all(width: this.widthLine, color: borderColor),
          boxShadow: this.shape == BoxShape.rectangle && hasShadow
              ? [
                  BoxShadow(
                    color: AppColors.blueSkyIII,
                    blurRadius: 1.0,
                    spreadRadius: 0.0,
                    offset: Offset(1.0, 1.0), // shadow direction: bottom right
                  )
                ]
              : null,
        ),
      ),
      Align(
        alignment: Alignment.center,
        child: this.child,
      )
    ]);
  }
}
