// Copyright 2020-2021 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:anytime/bloc/bloc.dart';
import 'package:anytime/entities/episode.dart';
import 'package:anytime/services/audio/audio_player_service.dart';
import 'package:anytime/state/sleep_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

enum TransitionState {
  play,
  pause,
  stop,
  fastforward,
  rewind,
}

enum LifecyleState {
  pause,
  resume,
  detach,
}

/// A BLoC to handle interactions between the audio service and the client.
/// A lot of the code in here could do with moving to the audio player service.
class AudioBloc extends Bloc {
  final log = Logger('AudioBloc');

  /// Listen for new episode play requests.
  final BehaviorSubject<Episode> _play = BehaviorSubject<Episode>();

  /// Move from one playing state to another such as from paused to play
  final PublishSubject<TransitionState> _transitionPlayingState = PublishSubject<TransitionState>();

  /// Sink to update our position
  final PublishSubject<double> _transitionPosition = PublishSubject<double>();

  /// Handles persisting data to storage.
  final AudioPlayerService audioPlayerService;

  /// Listens for playback speed change requests.
  final PublishSubject<double> _playbackSpeedSubject = PublishSubject<double>();

  /// Listen for toggling of trim silence requests.
  final PublishSubject<bool> _trimSilence = PublishSubject<bool>();

  /// Listen for toggling of volume boost silence requests.
  final PublishSubject<bool> _volumeBoost = PublishSubject<bool>();

  /// Move from one sleep policy to another.
  final Subject<SleepPolicy> _sleepPolicy = BehaviorSubject<SleepPolicy>();

  AudioBloc({
    @required this.audioPlayerService,
  }) {
    /// Listen for transition events from the client.
    _handlePlayingStateTransitions();

    /// Listen for events requesting the start of a new episode.
    _handleEpisodeRequests();

    /// Listen for requests to move the play position within the episode.
    _handlePositionTransitions();

    /// Listen for playback speed changes
    _handlePlaybackSpeedTransitions();

    /// Listen to trim silence requests
    _handleTrimSilenceTransitions();

    /// Listen to volume boost silence requests
    _handleVolumeBoostTransitions();

    /// Listen for sleep policy changes
    _handleSleepPolicyChanges();
  }

  /// Listens to events from the UI (or any client) to transition from one
  /// audio state to another. For example, to pause the current playback
  /// a [TransitionState.pause] event should be sent. To ensure the underlying
  /// audio service processes one state request at a time we push events
  /// on to a queue and execute them sequentially. Each state maps to a call
  /// to the Audio Service plugin.
  void _handlePlayingStateTransitions() {
    _transitionPlayingState.asyncMap((event) => Future.value(event)).listen((state) async {
      switch (state) {
        case TransitionState.play:
          await audioPlayerService.play();
          break;
        case TransitionState.pause:
          _turnSleepPolicyOff();
          await audioPlayerService.pause();
          break;
        case TransitionState.fastforward:
          await audioPlayerService.fastForward();
          break;
        case TransitionState.rewind:
          await audioPlayerService.rewind();
          break;
        case TransitionState.stop:
          _turnSleepPolicyOff();
          await audioPlayerService.stop();
          break;
      }
    });
  }

  /// Setup a listener for episode requests and then connect to the
  /// underlying audio service.
  void _handleEpisodeRequests() async {
    _play.listen((episode) {
      changeSleepPolicy(sleepPolicyNotSet());
      audioPlayerService.playEpisode(episode: episode, resume: true);
    });
  }

  /// Listen for requests to change the position of the current episode.
  void _handlePositionTransitions() async {
    _transitionPosition.listen((pos) async {
      await audioPlayerService.seek(position: pos.ceil());
    });
  }

  void _handlePlaybackSpeedTransitions() {
    _playbackSpeedSubject.listen((double speed) async {
      await audioPlayerService.setPlaybackSpeed(speed);
    });
  }

  void _handleTrimSilenceTransitions() {
    _trimSilence.listen((bool trim) async {
      await audioPlayerService.trimSilence(trim);
    });
  }

  void _handleVolumeBoostTransitions() {
    _volumeBoost.listen((bool boost) async {
      await audioPlayerService.volumeBoost(boost);
    });
  }

  void _handleSleepPolicyChanges() {
    _sleepPolicy.listen((SleepPolicy policy) async {
      log.fine('Policy changed o $policy');
      if (policy is SleepPolicyTimer) {
        await Future<void>.delayed(policy.duration).then((_) async {
          final current = await _sleepPolicy.first;
          if (policy == current) {
            transitionState(TransitionState.pause);
          }
        });
      }
    });
  }

  void _turnSleepPolicyOff() async {
    final current = await _sleepPolicy.first;
    if (current is SleepPolicyNotSet) return;
    if (current is SleepPolicyOff) return;
    changeSleepPolicy(sleepPolicyOff());
  }

  @override
  void pause() async {
    log.fine('Audio lifecycle pause');
    await audioPlayerService.suspend();
  }

  @override
  void resume() async {
    log.fine('Audio lifecycle resume');
    var ep = await audioPlayerService.resume();

    if (ep != null) {
      log.fine('Resuming with episode ${ep?.title} - ${ep?.position} - ${ep?.played}');
    } else {
      log.fine('Resuming without an episode');
    }
  }

  /// Play the specified track now
  void Function(Episode) get play => _play.add;

  /// Transition the state from connecting, to play, pause, stop etc.
  void Function(TransitionState) get transitionState => _transitionPlayingState.add;

  /// Move the play position.
  void Function(double) get transitionPosition => _transitionPosition.sink.add;

  /// Get the current playing state
  Stream<AudioState> get playingState => audioPlayerService.playingState;

  /// Listen for any playback errors
  Stream<int> get playbackError => audioPlayerService.playbackError;

  /// Get the current playing episode
  Stream<Episode> get nowPlaying => audioPlayerService.episodeEvent;

  /// Get position and percentage played of playing episode
  Stream<PositionState> get playPosition => audioPlayerService.playPosition;

  /// Change playback speed
  void Function(double) get playbackSpeed => _playbackSpeedSubject.sink.add;

  /// Toggle trim silence
  void Function(bool) get trimSilence => _trimSilence.sink.add;

  /// Toggle volume boost silence
  void Function(bool) get volumeBoost => _volumeBoost.sink.add;

  /// Get the sleep policy stream
  Stream<SleepPolicy> get sleepPolicy => _sleepPolicy.stream;

  /// Change the sleep policy
  void Function(SleepPolicy) get changeSleepPolicy => _sleepPolicy.sink.add;

  @override
  void dispose() {
    _play.close();
    _transitionPlayingState.close();
    _transitionPosition.close();
    _playbackSpeedSubject.close();
    _trimSilence.close();
    _volumeBoost.close();
    _sleepPolicy.close();
    super.dispose();
  }
}
