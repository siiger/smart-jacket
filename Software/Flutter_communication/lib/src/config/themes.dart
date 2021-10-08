import 'package:flutter/material.dart';
import 'package:norbusensor/src/config/app_colors.dart';
import 'package:norbusensor/src/common_widgets/fade_page_transition_builder.dart';

final ThemeData kShrineTheme = _buildShrineTheme();

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      color: AppColors.blueSkyI,
      iconTheme: IconThemeData(color: AppColors.blueSkyI),
    ),
    accentColor: AppColors.latoGrey,
    primaryColor: AppColors.blueSkyI,
    buttonColor: AppColors.latoGrey,
    backgroundColor: AppColors.blueSkyI,
    primaryColorLight: AppColors.latoGrey,
    scaffoldBackgroundColor: AppColors.latoGrey,
    cardColor: AppColors.latoGrey,
    errorColor: AppColors.latoGrey,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: FadePageTransitionsBuilder(),
    }),
  );
}

final lightTheme = ThemeData.light().copyWith(
  appBarTheme: const AppBarTheme(
    color: Colors.transparent,
    iconTheme: IconThemeData(color: AppColors.blueSkyI),
  ),
  scaffoldBackgroundColor: AppColors.latoGrey,
  backgroundColor: AppColors.latoGrey,
  primaryColor: AppColors.latoGrey,
  primaryColorLight: AppColors.latoGrey,
  accentColor: Color(0xff7c8cff),
  toggleableActiveColor: Color(0xff7c8cff),
  dialogBackgroundColor: AppColors.latoGrey,
  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.android: FadePageTransitionsBuilder(),
  }),
);
