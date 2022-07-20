// Copyright 2020-2022 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:anytime/bloc/podcast/audio_bloc.dart';
import 'package:anytime/l10n/L.dart';
import 'package:anytime/services/audio/audio_player_service.dart';
import 'package:anytime/ui/widgets/sleep_selector.dart';
import 'package:anytime/ui/widgets/speed_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

/// Builds a transport control bar for rewind, play and fast-forward.
/// See [NowPlaying].
class PlayerTransportControls extends StatefulWidget {
  @override
  State<PlayerTransportControls> createState() => _PlayerTransportControlsState();
}

class _PlayerTransportControlsState extends State<PlayerTransportControls> {
  @override
  Widget build(BuildContext context) {
    final audioBloc = Provider.of<AudioBloc>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: StreamBuilder<AudioState>(
          stream: audioBloc.playingState,
          builder: (context, snapshot) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SleepSelector(),
                IconButton(
                  onPressed: () {
                    return snapshot.data == AudioState.buffering ? null : _rewind(audioBloc);
                  },
                  tooltip: L.of(context).rewind_button_label,
                  padding: const EdgeInsets.all(0.0),
                  icon: Icon(
                    Icons.replay_30,
                    size: 48.0,
                  ),
                ),
                AnimatedPlayButton(audioState: snapshot.data),
                IconButton(
                  onPressed: () {
                    return snapshot.data == AudioState.buffering ? null : _fastforward(audioBloc);
                  },
                  padding: const EdgeInsets.all(0.0),
                  icon: Icon(
                    Icons.forward_30,
                    size: 48.0,
                  ),
                ),
                SpeedSelectorWidget(),
              ],
            );
          }),
    );
  }

  void _rewind(AudioBloc audioBloc) {
    audioBloc.transitionState(TransitionState.rewind);
  }

  void _fastforward(AudioBloc audioBloc) {
    audioBloc.transitionState(TransitionState.fastforward);
  }
}

typedef PlayHandler = Function(AudioBloc audioBloc);

class AnimatedPlayButton extends StatefulWidget {
  final AudioState audioState;
  final PlayHandler onPlay;
  final PlayHandler onPause;

  AnimatedPlayButton({
    Key key,
    @required this.audioState,
    this.onPlay = _onPlay,
    this.onPause = _onPause,
  }) : super(key: key);

  @override
  State<AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

void _onPlay(AudioBloc audioBloc) {
  audioBloc.transitionState(TransitionState.play);
}

void _onPause(AudioBloc audioBloc) {
  audioBloc.transitionState(TransitionState.pause);
}

class _AnimatedPlayButtonState extends State<AnimatedPlayButton> with SingleTickerProviderStateMixin {
  AnimationController _playPauseController;
  StreamSubscription<AudioState> _audioStateSubscription;
  bool init = true;

  @override
  void initState() {
    super.initState();

    final audioBloc = Provider.of<AudioBloc>(context, listen: false);

    _playPauseController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    /// Seems a little hacky, but when we load the form we want the play/pause
    /// button to be in the correct state. If we are building the first frame,
    /// just set the animation controller to the correct state; for all other
    /// frames we want to animate. Doing it this way prevents the play/pause
    /// button from animating when the form is first loaded.
    _audioStateSubscription = audioBloc.playingState.listen((event) {
      if (event == AudioState.playing || event == AudioState.buffering) {
        if (init) {
          _playPauseController.value = 1;
          init = false;
        } else {
          _playPauseController.forward();
        }
      } else {
        if (init) {
          _playPauseController.value = 0;
          init = false;
        } else {
          _playPauseController.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    _playPauseController.dispose();
    _audioStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioBloc = Provider.of<AudioBloc>(context, listen: false);

    final playing = widget.audioState == AudioState.playing;
    final buffering = widget.audioState == null || widget.audioState == AudioState.buffering;

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        if (buffering)
          SpinKitRing(
            lineWidth: 4.0,
            color: Theme.of(context).primaryColor,
            size: 84,
          ),
        if (!buffering)
          SizedBox(
            height: 84,
            width: 84,
          ),
        Tooltip(
          message: playing ? L.of(context).pause_button_label : L.of(context).play_button_label,
          child: TextButton(
            style: TextButton.styleFrom(
              shape: CircleBorder(side: BorderSide(color: Theme.of(context).highlightColor, width: 0.0)),
              backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.orange : Colors.grey[800],
              primary: Theme.of(context).brightness == Brightness.light ? Colors.orange : Colors.grey[800],
              padding: const EdgeInsets.all(6.0),
            ),
            onPressed: () {
              if (playing) {
                widget.onPause(audioBloc);
                // audioBloc.transitionState(TransitionState.pause);
              } else {
                widget.onPlay(audioBloc);
                // audioBloc.transitionState(TransitionState.play);
              }
            },
            child: AnimatedIcon(
              size: 60.0,
              icon: AnimatedIcons.play_pause,
              color: Theme.of(context).primaryColor == Colors.white ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
              progress: _playPauseController,
            ),
          ),
        ),
      ],
    );
  }
}