// Copyright 2020-2022 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final ThemeData _lightTheme = _buildLightTheme();
final ThemeData _darkTheme = _buildDarktheme();

ThemeData _buildLightTheme() {
  final base = ThemeData.light();

  return base.copyWith(
    buttonTheme: base.buttonTheme.copyWith(
        colorScheme: base.buttonTheme.colorScheme!.copyWith(
            onPrimary: Colors.orange,
            onSecondary: Color(0xffffe0b2),
            onSurface: Colors.grey[800]!.withOpacity(0.5))),
    textButtonTheme: base.textButtonTheme,
    elevatedButtonTheme: base.elevatedButtonTheme,
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(foregroundColor: Colors.grey[800]),
    ),
    brightness: Brightness.light,
    primaryColor: Color(0xffff9800),
    primaryColorLight: Color(0xffffe0b2),
    primaryColorDark: Color(0xfff57c00),
    canvasColor: Color(0xffffffff),
    scaffoldBackgroundColor: Color(0xffffffff),
    cardColor: Color(0xffffffff),
    dividerColor: Color(0x1f000000),
    highlightColor: Color(0x66bcbcbc),
    splashColor: Color(0x66c8c8c8),
    unselectedWidgetColor: Color(0x8a000000),
    disabledColor: Color(0x61000000),
    secondaryHeaderColor: Color(0xfffff3e0),
    textSelectionTheme: TextSelectionThemeData(
        selectionColor: Color(0xffffcc80),
        cursorColor: Colors.blue,
        selectionHandleColor: Color(0xffffb74d)),
    dialogBackgroundColor: Color(0xffffffff),
    indicatorColor: Colors.orange,
    hintColor: Color(0x8a000000),
    primaryTextTheme:
        Typography.material2018(platform: TargetPlatform.android).black,
    textTheme: Typography.material2018(platform: TargetPlatform.android).black,
    primaryIconTheme: IconThemeData(color: Colors.grey[800]),
    iconTheme: base.iconTheme.copyWith(
      color: Colors.orange,
    ),
    sliderTheme: SliderThemeData().copyWith(
      valueIndicatorColor: Colors.orange,
      trackHeight: 2.0,
      thumbShape: RoundSliderThumbShape(
        enabledThumbRadius: 6.0,
        disabledThumbRadius: 6.0,
      ),
    ),
    appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        )),
    snackBarTheme: base.snackBarTheme.copyWith(
      actionTextColor: Colors.orange,
    ),
    bottomAppBarTheme: BottomAppBarTheme(color: Color(0xffffffff)),
    checkboxTheme: CheckboxThemeData(
      fillColor:
          MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xfffb8c00);
        }
        return null;
      }),
    ),
    radioTheme: base.radioTheme.copyWith(
      fillColor: MaterialStateProperty.resolveWith(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.orange;
          } else {
            return Color(0x8a000000);
          }
        },
      ),
    ).copyWith(
      fillColor:
          MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xfffb8c00);
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor:
          MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xfffb8c00);
        }
        return null;
      }),
      trackColor:
          MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xfffb8c00);
        }
        return null;
      }),
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xffff9800),
      background: Color(0xfffafafa),
      onSecondary: Colors.black,
      error: Color(0xffd32f2f),
    ),
  );
}

ThemeData _buildDarktheme() {
  final base = ThemeData.dark();

  return base.copyWith(
    brightness: Brightness.dark,
    primaryColor: Color(0xffffffff),
    primaryColorLight: Color(0xffffe0b2),
    primaryColorDark: Color(0xfff57c00),
    canvasColor: Color(0xff000000),
    scaffoldBackgroundColor: Color(0xff000000),
    cardColor: Colors.black,
    dividerColor: Color(0xff444444),
    highlightColor: Color(0xff222222),
    splashColor: Color(0x66c8c8c8),
    unselectedWidgetColor: Colors.white,
    disabledColor: Color(0x77ffffff),
    secondaryHeaderColor: Color(0xfffff3e0),
    textSelectionTheme: TextSelectionThemeData(
        selectionColor: Color(0xffffcc80),
        cursorColor: Colors.orange,
        selectionHandleColor: Color(0xffffb74d)),
    dialogBackgroundColor: Color(0xff222222),
    indicatorColor: Colors.orange,
    hintColor: Color(0x80ffffff),
    primaryTextTheme:
        Typography.material2018(platform: TargetPlatform.android).white,
    textTheme: Typography.material2018(platform: TargetPlatform.android).white,
    primaryIconTheme: IconThemeData(color: Colors.white),
    iconTheme: base.iconTheme.copyWith(
      color: Colors.white,
    ),
    dividerTheme: base.dividerTheme.copyWith(
      color: Color(0xff444444),
    ),
    sliderTheme: SliderThemeData().copyWith(
      valueIndicatorColor: Colors.white,
      trackHeight: 2.0,
      thumbShape: RoundSliderThumbShape(
        enabledThumbRadius: 6.0,
        disabledThumbRadius: 6.0,
      ),
    ),
    appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Color(0xff222222),
        foregroundColor: Colors.white,
        shadowColor: Color(0xff222222),
        elevation: 1.0,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xff222222),
          statusBarIconBrightness: Brightness.light,
        )),
    snackBarTheme: base.snackBarTheme.copyWith(
      actionTextColor: Colors.orange,
    ),
    buttonTheme: base.buttonTheme.copyWith(
        colorScheme: base.buttonTheme.colorScheme!
            .copyWith(onSecondary: Colors.orange, onSurface: Colors.grey[800])),
    textButtonTheme: base.textButtonTheme,
    elevatedButtonTheme: base.elevatedButtonTheme,
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Color(0xffffffff),
        side: BorderSide(
          color: Color(0xffffffff),
          style: BorderStyle.solid,
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor:
          MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xfffb8c00);
        }
        return null;
      }),
    ),
    radioTheme: base.radioTheme.copyWith(
      fillColor: MaterialStateProperty.resolveWith(
        (states) {
          return Colors.white;
        },
      ),
    ).copyWith(
      fillColor:
          MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xfffb8c00);
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor:
          MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xfffb8c00);
        }
        return null;
      }),
      trackColor:
          MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Color(0xfffb8c00);
        }
        return null;
      }),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xffffffff),
      background: Color(0xff333333),
      onSecondary: Colors.white,
      error: Color(0xffd32f2f),
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Color(0xff222222),
    ),
  );
}

class Themes {
  final ThemeData themeData;

  Themes({required this.themeData});

  factory Themes.lightTheme() {
    return Themes(themeData: _lightTheme);
  }

  factory Themes.darkTheme() {
    return Themes(themeData: _darkTheme);
  }
}
