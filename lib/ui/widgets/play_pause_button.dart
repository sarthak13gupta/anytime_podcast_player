// Copyright 2020-2022 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:percent_indicator/percent_indicator.dart';

class PlayPauseButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? title;

  const PlayPauseButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $title',
      child: CircularPercentIndicator(
        radius: 19.0,
        lineWidth: 1.5,
        backgroundColor: Theme.of(context).buttonTheme.colorScheme!.onPrimary,
        percent: 0.0,
        center: Icon(
          icon,
          size: 22.0,
          color: Theme.of(context).buttonTheme.colorScheme!.onPrimary,
        ),
      ),
    );
  }
}

class PlayPauseBusyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? title;

  const PlayPauseBusyButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
        label: '$label $title',
        child: Container(
          padding: EdgeInsets.all(0.0),
          height: 40.0,
          width: 38.0,
          child: Stack(
            children: <Widget>[
              CircularPercentIndicator(
                radius: 19.0,
                lineWidth: 1.5,
                backgroundColor: Theme.of(context).buttonTheme.colorScheme!.onSurface,
                percent: 0.0,
                center: Icon(
                  icon,
                  size: 22.0,
                  color: Theme.of(context).buttonTheme.colorScheme!.onSurface,
                ),
              ),
              SpinKitRing(
                lineWidth: 1.5,
                size: 38.0,
                color: Theme.of(context).buttonTheme.colorScheme!.onPrimary
              ),
            ],
          ),
        ));
  }
}
