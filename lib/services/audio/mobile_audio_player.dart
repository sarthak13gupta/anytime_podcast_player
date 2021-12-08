// Copyright 2020-2021 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:anytime/core/environment.dart';
import 'package:anytime/entities/persistable.dart';
import 'package:anytime/state/persistent_state.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';
import 'package:pedantic/pedantic.dart';

/// This class acts as a go-between between [AudioService] and the chosen
/// audio player implementation.
///
/// For each transition, such as play, pause etc, this class will call the
/// equivalent function on the audio player and update the [AudioService]
/// state.
///
/// This version is backed by just_audio
class MobileAudioPlayer {
  static const rewindMillis = 10001;
  static const fastForwardMillis = 30000;
  static const AUDIO_GAIN = 0.8;

  final log = Logger('MobileAudioPlayer');
  final Completer _completer = Completer<dynamic>();

  AndroidLoudnessEnhancer _androidLoudnessEnhancer;
  AudioPipeline _audioPipeline;
  AudioPlayer _audioPlayer;
  VoidCallback completionHandler;
  PlaybackEvent lastState;

  StreamSubscription<PlaybackEvent> _eventSubscription;

  String _uri;
  int _startPosition = 0;
  bool _loadTrack = false;
  bool _local;
  int _episodeId = 0;
  double _playbackSpeed = 1.0;
  bool _trimSilence = false;
  bool _volumeBoost = false;
  MediaItem _mediaItem;
  Timer _durationTimer;

  MediaControl playControl = MediaControl(
    androidIcon: 'drawable/ic_action_play_circle_outline',
    label: 'Play',
    action: MediaAction.play,
  );

  MediaControl pauseControl = MediaControl(
    androidIcon: 'drawable/ic_action_pause_circle_outline',
    label: 'Pause',
    action: MediaAction.pause,
  );

  MediaControl stopControl = MediaControl(
    androidIcon: 'drawable/ic_action_stop',
    label: 'Stop',
    action: MediaAction.stop,
  );

  MediaControl rewindControl = MediaControl(
    androidIcon: 'drawable/ic_action_rewind_10',
    label: 'Rewind',
    action: MediaAction.rewind,
  );

  MediaControl fastforwardControl = MediaControl(
    androidIcon: 'drawable/ic_action_fastforward_30',
    label: 'Fastforward',
    action: MediaAction.fastForward,
  );

  MobileAudioPlayer({this.completionHandler}) {
    if (Platform.isAndroid) {
      _androidLoudnessEnhancer = AndroidLoudnessEnhancer();
      _androidLoudnessEnhancer.setEnabled(true);
      _audioPipeline = AudioPipeline(androidAudioEffects: [_androidLoudnessEnhancer]);
      _audioPlayer = AudioPlayer(audioPipeline: _audioPipeline);
    } else {
      _audioPlayer = AudioPlayer();
    }
  }

  Future<void> updatePosition() async {
    await AudioServiceBackground.setState(
      controls: [
        rewindControl,
        if (_audioPlayer.playing) pauseControl else playControl,
        fastforwardControl,
      ],
      processingState: AudioProcessingState.none,
      playing: _audioPlayer.playing,
      position: _audioPlayer.position,
    );
  }

  Future<void> setMediaItem(dynamic args) async {
    var sp = args[5] as String;
    var episodeIdStr = args[6] as String;
    var playbackSpeedStr = args[7] as String;
    var durationStr = args[8] as String;
    var trimSilenceStr = args[9] as String;
    var volumeBoostStr = args[10] as String;

    _episodeId = int.parse(episodeIdStr);
    _playbackSpeed = double.parse(playbackSpeedStr);
    _uri = args[3] as String;
    _local = (args[4] as String) == '1';
    _startPosition = 0;
    _trimSilence = trimSilenceStr == '1';
    _volumeBoost = volumeBoostStr == '1';
    Duration duration;

    if (int.tryParse(sp) != null) {
      _startPosition = int.parse(sp);
    } else {
      log.info('Failed to parse starting position of $sp');
    }

    if (int.tryParse(durationStr) != null) {
      duration = Duration(seconds: int.parse(durationStr));
    }

    log.fine(
        'Setting play URI to $_uri, isLocal $_local and position $_startPosition id $_episodeId speed $_playbackSpeed}');

    _loadTrack = true;

    _mediaItem = MediaItem(
      id: episodeIdStr,
      title: args[1] as String,
      album: args[0] as String,
      artUri: Uri.parse(args[2] as String),
      duration: duration,
    );

    await AudioServiceBackground.setMediaItem(_mediaItem);
  }

  Future<void> start() async {
    log.fine('start()');

    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      _setState(position: _audioPlayer.position);
    }, onError: (Object error, StackTrace t) async {
      _reportError(error);

      log.fine('Playback stream error');
      log.fine(error.toString());

      await _audioPlayer.stop();
      await complete();
    });
  }

  void _reportError(Object e) async {
    log.fine('Playback event stream - playback error', e);
    log.fine('Object is of type ${e.runtimeType}');

    if (e is PlatformException) {
      log.fine(e.code);
      log.fine(e.message);
      log.fine(e.stacktrace);
    }

    await _setErrorState();
  }

  Future<void> play() async {
    log.fine('play() - loadTrack is $_loadTrack');

    if (_loadTrack) {
      if (!_local) {
        await _setBufferingState();
      }

      var userAgent = Environment.userAgent();

      var headers = <String, String>{
        'User-Agent': userAgent,
      };

      var start = _startPosition > 0 ? Duration(milliseconds: _startPosition) : Duration.zero;

      log.fine('loading new track $_uri - from position ${start.inSeconds} (${start.inMilliseconds})');

      if (_local) {
        await _audioPlayer.setFilePath(
          _uri,
          initialPosition: start,
        );
      } else {
        var d = await _audioPlayer.setUrl(
          _uri,
          headers: headers,
          initialPosition: start,
        );

        /// If we don't already have a duration and we have been able to calculate it from
        /// beginning to fetch the media, update the current media item with the duration.
        if (d != null && _mediaItem != null && (_mediaItem.duration == null || _mediaItem.duration.inSeconds == 0)) {
          _mediaItem = _mediaItem.copyWith(duration: d);
          await AudioServiceBackground.setMediaItem(_mediaItem);
        }
      }

      _loadTrack = false;
    }

    if (_audioPlayer.processingState != ProcessingState.idle) {
      try {
        if (_audioPlayer.speed != _playbackSpeed) {
          await _audioPlayer.setSpeed(_playbackSpeed);
        }

        if (Platform.isAndroid) {
          if (_audioPlayer.skipSilenceEnabled != _trimSilence) {
            await _audioPlayer.setSkipSilenceEnabled(_trimSilence);
          }

          print('SETTING VOLUME BOOST TO $_volumeBoost');
          volumeBoost(_volumeBoost);
        }

        unawaited(_audioPlayer.play());
      } catch (e) {
        log.fine('State error ${e.toString()}');
      }
    }
    await _persistState(LastState.playing, _audioPlayer.position).whenComplete(
      () => _durationTimer = Timer.periodic(
        Duration(seconds: 10),
        (timer) async {
          await _persistState(LastState.playing, _audioPlayer.position);
        },
      ),
    );
    await _setState(position: _audioPlayer.position);
  }

  Future<void> pause() async {
    _durationTimer?.cancel();
    await _audioPlayer.pause();
    await _persistState(LastState.paused, _audioPlayer.position);
  }

  Future<void> stop() async {
    log.fine('stop()');

    await _setStoppedState();
  }

  Future<void> complete() async {
    log.fine('complete()');

    _durationTimer?.cancel();
    await _persistState(LastState.completed, _audioPlayer.position);

    if (completionHandler != null) {
      completionHandler();
    }
  }

  Future<void> fastforward() async {
    log.fine('fastforward()');

    var forwardPosition = _latestPosition();

    await seekTo(Duration(milliseconds: forwardPosition + fastForwardMillis));
  }

  Future<void> rewind() async {
    log.fine('rewind()');

    var rewindPosition = _latestPosition();

    log.fine('Positions:');
    log.fine(' - Player position is ${_audioPlayer.position.inMilliseconds}');

    if (rewindPosition > 0) {
      rewindPosition -= rewindMillis;

      if (rewindPosition < 0) {
        rewindPosition = 0;
      }

      await seekTo(Duration(milliseconds: rewindPosition));
    }
  }

  Future<void> setSpeed(double speed) async {
    _playbackSpeed = speed;

    await _audioPlayer.setSpeed(speed);
  }

  Future<void> trimSilence(bool trim) async {
    log.fine('Setting trim silence to $trim');
    _trimSilence = trim;

    await _audioPlayer.setSkipSilenceEnabled(trim);
  }

  void volumeBoost(bool boost) {
    log.fine('Setting volume boost to $boost');

    /// For now, we know we only have one effect so we can cheat
    var e = _audioPipeline.androidAudioEffects[0];

    if (e is AndroidLoudnessEnhancer) {
      e.setTargetGain(boost ? AUDIO_GAIN : 0.0);
    }
  }

  Future<void> onNoise() async {
    if (_audioPlayer.playing) {
      await pause();
    }
  }

  Future<void> onClick() async {
    if (_uri.isNotEmpty) {
      if (_audioPlayer.playing) {
        await pause();
      } else {
        await play();
      }
    }
  }

  Future<void> _setErrorState() async {
    await _setState(fixedState: AudioProcessingState.error, position: Duration(milliseconds: 0));
  }

  Future<void> _setBufferingState() async {
    if (!_local) {
      await _setState(fixedState: AudioProcessingState.buffering, position: _audioPlayer.position);
    }
  }

  Future<void> _setStoppedState({bool completed = false}) async {
    _durationTimer?.cancel();
    var p = _audioPlayer.position;

    log.fine('setStoppedState() - position is ${p.inMilliseconds} - completed is $completed');

    await _persistState(LastState.stopped, p);

    await _eventSubscription.cancel();
    await _audioPlayer.stop();

    await _setState(
      fixedState: completed ? AudioProcessingState.completed : AudioProcessingState.stopped,
      position: p,
    );

    await _audioPlayer.dispose();

    _completer.complete();
  }

  Future<void> seekTo(Duration position) async {
    await _setBufferingState();
    await _audioPlayer.seek(position);
    await _persistState(LastState.playing, position);
  }

  Future<void> _setState({
    AudioProcessingState fixedState,
    @required Duration position,
  }) async {
    var mapped = fixedState ?? _mapPlayerStateToServiceState();

    await AudioServiceBackground.setState(
      controls: [
        rewindControl,
        if (_audioPlayer.playing) pauseControl else playControl,
        fastforwardControl,
      ],
      processingState: mapped,
      position: position,
      playing: _audioPlayer.playing,
      speed: _audioPlayer.speed,
    );

    if (mapped == AudioProcessingState.completed) {
      await complete();
    }
  }

  AudioProcessingState _mapPlayerStateToServiceState() {
    switch (_audioPlayer.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.none;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        return AudioProcessingState.none;
    }
  }

  Future<void> _persistState(LastState state, Duration position) async {
    // Save our completion state to disk so we can query this later
    log.fine('Saving ${state.toString()} state - episode id $_episodeId - position ${position?.inMilliseconds}');

    await PersistentState.persistState(Persistable(
      episodeId: _episodeId,
      position: position.inMilliseconds,
      state: state,
    ));
  }

  int _latestPosition() {
    log.fine('Fetching latest position:');
    log.fine(' - Player position is ${_audioPlayer.position?.inMilliseconds}');

    return _audioPlayer.position == null ? 0 : _audioPlayer.position.inMilliseconds;
  }

  bool get playing => _audioPlayer.playing;
}
