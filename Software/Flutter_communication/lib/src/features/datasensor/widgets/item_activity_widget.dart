import 'package:flutter/material.dart';
import 'package:norbusensor/src/common_widgets/border_widget.dart';
import 'package:norbusensor/src/config/app_colors.dart';

class ItemActivityWidget extends StatelessWidget {
  const ItemActivityWidget({Key key, this.onTap, this.onPressedIcon, this.text}) : super(key: key);

  final VoidCallback onTap;
  final VoidCallback onPressedIcon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return BorderWidget(
        heightOut: 46,
        widthLine: 1.9,
        widthOut: null,
        hasShadow: false,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
          Container(
            width: 270,
            height: 35,
            child: ListTile(
              tileColor: Colors.transparent,
              title: Padding(
                padding: const EdgeInsets.only(
                  bottom: 15.0,
                ),
                child: Text(text,
                    style: TextStyle(fontSize: 18.0, color: AppColors.grey2), overflow: TextOverflow.ellipsis),
              ),
              onTap: () => onTap(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                width: 1,
                height: 26,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppColors.blueSkyI,
                      width: 1.9,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.clear_outlined, color: AppColors.blueSkyI),
                onPressed: () => onPressedIcon(),
              ),
            ],
          ),
        ]));
  }
}
