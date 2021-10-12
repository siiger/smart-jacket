import 'package:flutter/material.dart';
import 'package:norbusensor/src/config/app_colors.dart';

class ListViewBigSeparatorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12.0,
      child: Container(
        decoration: const BoxDecoration(color: Colors.grey),
      ),
    );
  }
}

class ListViewSeparatorWidget extends StatelessWidget {
  const ListViewSeparatorWidget({this.padding = const EdgeInsets.symmetric(horizontal: 6.0), Key key})
      : super(key: key);

  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Divider(
        color: AppColors.blueSkyI,
        height: 2.0,
        thickness: 2.0,
      ),
    );
  }
}
