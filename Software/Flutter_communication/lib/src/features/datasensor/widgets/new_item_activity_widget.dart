import 'package:flutter/material.dart';
import 'package:norbusensor/src/common_widgets/border_widget.dart';
import 'package:norbusensor/src/config/app_colors.dart';

class NewItemActivityWidget extends StatelessWidget {
  NewItemActivityWidget({Key key, this.onSavedValue, this.text}) : super(key: key);

  final Function(String) onSavedValue;
  final String text;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 0.0,
      ),
      child: BorderWidget(
        heightOut: 46,
        widthLine: 1.9,
        widthOut: null,
        hasShadow: false,
        baseColor: AppColors.latoGrey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Expanded(
                child: TextFormField(
                  style: TextStyle(fontSize: 18.0, color: AppColors.grey2),
                  decoration: InputDecoration(
                    hintText: "Add new activity",
                    hintStyle: TextStyle(
                      fontSize: 18.0,
                      color: AppColors.grey1,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    //icon: Icon(Icons.face),
                  ),
                  //validator: (val) {},
                  controller: TextEditingController()..text = '',
                  onSaved: (value) => onSavedValue(value),
                  //maxLength: 1,
                ),
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
                  icon: Icon(Icons.add, color: AppColors.blueSkyI),
                  onPressed: () {
                    _formKey.currentState.save();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
