import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color transparent = Color(0x00000000);

  static const Color black = Color(0xff000000);

  static const Color latoGrey = Color(0xffdfe1e1);
  static const Color latoGrey1 = Color(0xffc3c5c5);
  static const Color latoGrey2 = Color(0xffecefef);
  static const Color blueSkyI = Color(0xff1d77b4);
  static const Color blueSkyII = Color(0xff96bad2);
  static const Color blueSkyIII = Color(0xff0b476f);
  static const Color blueSkyIV = Color(0xff186295);
  static const Color blueSkyV = Color(0xff3c99ea);
  static const Color blueSkyVI = Color(0xffaee0fd);
  static const Color green = Color(0xff45b583);
  static const Color greenDark = Color(0xff066612);
  static const Color red = Color(0xffe77271);
  static const Color greenLight = Color(0xffc7e7c8);

  static const Color white = Color(0xffffffff);
  static const Color white90 = Color(0xe6ffffff);
  static const Color white85 = Color(0xd9ffffff);
  static const Color white80 = Color(0xccffffff);
  static const Color white75 = Color(0xbfffffff);
  static const Color white70 = Color(0xb3ffffff);
  static const Color white65 = Color(0xa6ffffff);
  static const Color white60 = Color(0x99ffffff);
  static const Color white55 = Color(0x8cffffff);
  static const Color white50 = Color(0x80ffffff);
  static const Color white45 = Color(0x73ffffff);
  static const Color white40 = Color(0x66ffffff);
  static const Color white35 = Color(0x59ffffff);
  static const Color white30 = Color(0x4dffffff);
  static const Color white20 = Color(0x33ffffff);
  static const Color white15 = Color(0x24ffffff);

  static const Color grey = Color(0xffaaaaaa);
  static const Color grey1 = Color(0xff848585);
  static const Color grey2 = Color(0xff4e4e4e);
  static const Color darkGrey = Color(0xff1a1c24);
  static const Color darkGrey1 = Color(0xff0d0e13);
  static const Color darkGrey2 = Color(0xff20212a);
  static const Color darkGrey3 = Color(0xff121212);

  static const Color blueGrey = Color(0xff282a33);
  static const Color blueGreyLight = Color(0xff363741);

  static LinearGradient get gradientColorsGreen {
    final List<Color> listColorGreen = <Color>[];
    listColorGreen.add(latoGrey);
    listColorGreen.add(Colors.green[200]);
    listColorGreen.add(Colors.green[400]);
    final List<double> stops = <double>[];
    stops.add(0.0);
    stops.add(0.8);
    stops.add(1.0);
    return LinearGradient(
        begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: listColorGreen, stops: stops);
  }

  static LinearGradient get gradientColorsBlue {
    final List<Color> listColorBlue = <Color>[];
    listColorBlue.add(latoGrey);
    listColorBlue.add(latoGrey);
    listColorBlue.add(Colors.blue[100]);
    listColorBlue.add(Colors.blue[400]);
    final List<double> stops = <double>[];
    stops.add(0.0);
    stops.add(0.7);
    stops.add(0.9);
    stops.add(1.0);
    return LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: listColorBlue, stops: stops);
  }
}
