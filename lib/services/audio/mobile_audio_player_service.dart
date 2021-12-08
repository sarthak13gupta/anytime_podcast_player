// Copyright 2020-2021 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:anytime/core/utils.dart';
import 'package:anytime/entities/chapter.dart';
import 'package:anytime/entities/downloadable.dart';
import 'package:anytime/entities/episode.dart';
import 'package:anytime/entities/persistable.dart';
import 'package:anytime/repository/repository.dart';
import 'package:anytime/services/audio/audio_background_player.dart';
import 'package:anytime/services/audio/audio_player_service.dart';
import 'package:anytime/services/podcast/podcast_service.dart';
import 'package:anytime/services/settings/settings_service.dart';
import 'package:anytime/state/episode_state.dart';
import 'package:anytime/state/persistent_state.dart';
import 'package:audio_service/audio_service.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

/// An implementation of the [AudioPlayerService] for mobile devices.
/// The [audio_service](https://pub.dev/packages/audio_service) package
/// is used to handle audio tasks in a separate Isolate thus allowing
/// audio to play in the background or when the screen is off. An
/// instance of [BackgroundPlayerTask] is used to handle events from
/// the background Isolate and pass them on to the audio player.
class MobileAudioPlayerService extends AudioPlayerService {
  final zeroDuration = const Duration(seconds: 0);
  final log = Logger('MobileAudioPlayerService');
  final Repository repository;
  final SettingsService settingsService;
  final PodcastService podcastService;
  final Color androidNotificationColor;
  double _playbackSpeed;
  bool _trimSilence = false;
  bool _volumeBoost = false;
  Episode _episode;

  /// Subscription to the position ticker.
  StreamSubscription<int> _positionSubscription;

  /// Stream showing our current playing state.
  final BehaviorSubject<AudioState> _playingState = BehaviorSubject<AudioState>.seeded(AudioState.none);

  /// Ticks whilst playing. Updates our current position within an episode.
  final _durationTicker = Stream<int>.periodic(Duration(milliseconds: 500)).asBroadcastStream();

  /// Stream for the current position of the playing track.
  final BehaviorSubject<PositionState> _playPosition = BehaviorSubject<PositionState>();

  final BehaviorSubject<Episode> _episodeEvent = BehaviorSubject<Episode>(sync: true);

  /// Stream for the last audio error as an integer code.
  final PublishSubject<int> _playbackError = PublishSubject<int>();

  MobileAudioPlayerService({
    @required this.repository,
    @required this.settingsService,
    @required this.podcastService,
    this.androidNotificationColor,
  }) {
    _handleAudioServiceTransitions();
  }

  /// Called by the client (UI) when a new episode should be played. If we have
  /// a downloaded copy of the requested episode we will use that; otherwise
  /// we will stream the episode directly.
  @override
  Future<void> playEpisode({@required Episode episode, bool resume = true}) async {
    if (episode.guid != '') {
      var streaming = true;
      var startPosition = 0;
      var uri = episode.contentUrl;

      _episodeEvent.sink.add(episode);
      _playingState.add(AudioState.buffering);

      if (resume) {
        startPosition = episode?.position ?? 0;
      }

      if (episode.downloadState == DownloadState.downloaded) {
        if (await hasStoragePermission()) {
          final downloadFile = await resolvePath(episode);

          uri = downloadFile;

          streaming = false;
        } else {
          throw Exception('Insufficient storage permissions');
        }
      }

      log.info('Playing episode ${episode?.id} - ${episode?.title} from position $startPosition');
      log.fine(' - $uri');

      // If we are streaming try and let the user know as soon as possible and
      // clear any chapters as we'll fetch them again.
      if (streaming) {
        // We are streaming. Clear any chapters as we'll (re)fetch them
        episode.chapters = <Chapter>[];
        episode.currentChapter = null;

        _playingState.add(AudioState.buffering);

        // Check we have connectivity
        var connectivityResult = await Connectivity().checkConnectivity();

        if (connectivityResult == ConnectivityResult.none) {
          _playbackError.add(401);
          _playingState.add(AudioState.none);

          await AudioService.stop();
          return;
        }
      }

      _episodeEvent.sink.add(episode);
      updateCurrentPosition(episode);
      _playbackSpeed = settingsService.playbackSpeed;
      _trimSilence = settingsService.trimSilence;
      _volumeBoost = settingsService.volumeBoost;

      // If we are currently playing a track - save the position of the current
      // track before switching to the next.
      var currentState = AudioService.playbackState?.processingState ?? AudioProcessingState.none;

      log.fine(
          'Current playback state is $currentState. Speed = $_playbackSpeed. Trim = $_trimSilence. Volume Boost = $_volumeBoost}');

      if (currentState == AudioProcessingState.ready) {
        await _savePosition();
      }

      // Store reference
      _episode = episode;
      _episode.played = false;

      await repository.saveEpisode(_episode);

      if (!AudioService.running) {
        await _start();
      }

      await AudioService.customAction('track', _loadTrackDetails(uri, startPosition));

      try {
        await AudioService.play();

        // If we are streaming and this episode has chapters we should (re)fetch them now.
        if (streaming && _episode.hasChapters) {
          _episode.chaptersLoading = true;
          _episode.chapters = <Chapter>[];
          _episodeEvent.sink.add(_episode);

          await _onUpdatePosition();

          _episode.chapters = await podcastService.loadChaptersByUrl(url: _episode.chaptersUrl);
          _episode.chaptersLoading = false;

          _episode = await repository.saveEpisode(_episode);
          _episodeEvent.sink.add(_episode);
          await _onUpdatePosition();
        }
      } catch (e) {
        log.fine('Error during playback');
        log.fine(e.toString());

        _playingState.add(AudioState.error);
        _playingState.add(AudioState.stopped);
        await AudioService.stop();
      }
    }
  }

  @override
  Future<void> fastForward() => AudioService.fastForward();

  @override
  Future<void> rewind() => AudioService.rewind();

  @override
  Future<void> pause() => AudioService.pause();

  @override
  Future<void> play() {
    if (AudioService.running) {
      return AudioService.play();
    } else {
      return playEpisode(episode: _episode, resume: true);
    }
  }

  @override
  Future<void> seek({int position}) async {
    var currentMediaItem = AudioService.currentMediaItem;
    var duration = currentMediaItem?.duration ?? Duration(seconds: 1);
    var p = Duration(seconds: position);
    var complete = p.inSeconds > 0 ? (duration.inSeconds / p.inSeconds) * 100 : 0;

    _updateChapter(p.inSeconds, duration.inSeconds);

    _playPosition.add(PositionState(p, duration, complete.toInt(), _episode, true));

    // Pause the ticker whilst we seek to prevent jumpy UI.
    _positionSubscription?.pause();

    await AudioService.seekTo(Duration(seconds: position));

    _positionSubscription?.resume();
  }

  @override
  Future<void> stop() async {
    await AudioService.stop();
  }

  /// When resuming from a paused state we first need to reconnect to the [AudioService].
  /// Next we need to restore the state of either the current playing episode or the last
  /// played episode. We do this in one of three ways. If Anytime has only been placed in
  /// the background when we resume [_episode] may still be valid and we can continue as
  /// normal. If not, we check to see if the [AudioService] has a current media item and,
  /// if so, we restore [_episode] that way. Failing that, we look to see if we have a
  /// persisted state file and use that to re-fetch the episode.
  @override
  Future<Episode> resume() async {
    await AudioService.connect();

    if (_episode == null) {
      if (AudioService.currentMediaItem == null) {
        await _updateEpisodeFromSavedState();
      } else {
        _episode = await repository.findEpisodeById(int.parse(AudioService.currentMediaItem.id));
      }
    } else {
      var playbackState = AudioService.playbackState;

      final basicState = playbackState?.processingState ?? AudioProcessingState.none;

      // If we have no state we'll have to assume we stopped whilst suspended.
      if (basicState == AudioProcessingState.none) {
        await _updateEpisodeFromSavedState();
        _playingState.add(AudioState.stopped);
      } else {
        _startTicker();
      }
    }

    _episodeEvent.sink.add(_episode);

    return Future.value(_episode);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) => AudioService.setSpeed(speed);

  @override
  Future<void> trimSilence(bool trim) => AudioService.customAction('trim', trim);

  @override
  Future<void> volumeBoost(bool boost) => AudioService.customAction('boost', boost);

  /// This method opens a saved state file. If it exists we fetch the episode ID from
  /// the saved state and fetch it from the database. If the last updated value of the
  /// saved state is later than the episode last updated date, we update the episode
  /// properties from the saved state.
  Future<void> _updateEpisodeFromSavedState() async {
    log.fine('_updateEpisodeFromSavedState()');
    var persistedState = await PersistentState.fetchState();

    if (persistedState != null) {
      log.fine(
          ' - Loaded state ${persistedState.state} - for episode ${persistedState.episodeId} - ${persistedState.position}');
      log.fine(' - Loaded state ${persistedState.state} - for episode ${persistedState.episodeId} - ${persistedState.position}');
      _episode = await repository.findEpisodeById(persistedState.episodeId);

      if (_episode != null) {
        if (persistedState.state == LastState.completed) {
          _episode.position = 0;
          _episode.played = true;
        } else {
          _episode.position = persistedState.position;

          if (persistedState.state == LastState.paused || persistedState.state == LastState.playing) {
            _playingState.add(AudioState.pausing);
            updateCurrentPosition(_episode);
          }
        }

        await repository.saveEpisode(_episode);
      }
    }
  }

  @override
  Future<void> suspend() async {
    _stopTicker();

    await AudioService.disconnect();
  }

  Future<void> _onStop() async {
    _stopTicker();
    await _savePosition();

    _episode = null;

    _playingState.add(AudioState.stopped);
  }

  Future<void> _onComplete() async {
    _stopTicker();

    _episode.position = 0;
    _episode.played = true;

    await repository.saveEpisode(_episode);

    _episode = null;

    _playingState.add(AudioState.stopped);
  }

  Future<void> _onPause() async {
    _playingState.add(AudioState.pausing);

    _stopTicker();
    await _savePosition();
  }

  Future<void> _onPlay() async {
    _playingState.add(AudioState.playing);

    _startTicker();
  }

  Future<void> _onBuffering() async {
    _playingState.add(AudioState.buffering);
  }

  Future<void> _onError() async {
    _playbackError.add(501);
  }

  Future<void> _onUpdatePosition() async {
    var playbackState = AudioService.playbackState;

    if (playbackState != null) {
      var currentMediaItem = AudioService.currentMediaItem;
      var duration = currentMediaItem?.duration ?? Duration(seconds: 1);
      var position = playbackState?.currentPosition;
      var complete = position.inSeconds > 0 ? (duration.inSeconds / position.inSeconds) * 100 : 0;
      var buffering = AudioService.playbackState.processingState == AudioProcessingState.buffering;

      _updateChapter(position.inSeconds, duration.inSeconds);

      _playPosition.add(PositionState(position, duration, complete.toInt(), _episode, buffering));
    }
  }

  void updateCurrentPosition(Episode e) {
    if (e != null) {
      var duration = Duration(seconds: e.duration);
      var complete = e.position > 0 ? (duration.inSeconds / e.position) * 100 : 0;

      _playPosition.add(PositionState(Duration(milliseconds: e.position), duration, complete.toInt(), e, false));
    }
  }

  /// Called before any playing of podcasts can take place. Only needs to be
  /// called again if a [AudioService.stop()] is called. This is quite an
  /// expensive operation so calling this method should be minimised.
  Future<void> _start() async {
    log.fine('_start() ${_episode.title} - ${_episode.position}');

    await AudioService.start(
      backgroundTaskEntrypoint: backgroundPlay,
      androidResumeOnClick: true,
      androidNotificationChannelName: 'Anytime Podcast Player',
      androidNotificationColor: androidNotificationColor?.value ?? Colors.orange.value,
      androidNotificationIcon: 'drawable/ic_stat_name',
      androidStopForegroundOnPause: true,
      fastForwardInterval: Duration(seconds: 30),
      rewindInterval: Duration(seconds: 10),
    );
  }

  /// Listens to events from the Audio Service plugin. We use this to trigger
  /// functions that Anytime needs to run as the audio state changes. Ideally
  /// we would like to handle all of this in the [_transitionPlayingState]
  /// stream, but as Audio Service handles input from external sources such
  /// as the notification bar or a WearOS device we need this second listener
  /// to ensure the necessary Anytime is code is run upon state change.
  void _handleAudioServiceTransitions() {
    AudioService.playbackStateStream.listen((state) {
      if (state != null && state is PlaybackState) {
        final ps = state.processingState;

        log.fine('Received state change from audio_service: ${ps.toString()}');

        switch (ps) {
          case AudioProcessingState.none:
            break;
          case AudioProcessingState.completed:
            _onComplete();
            break;
          case AudioProcessingState.stopped:
            _onStop();
            break;
          case AudioProcessingState.ready:
            if (state.playing) {
              _onPlay();
            } else {
              _onPause();
            }
            break;
          case AudioProcessingState.fastForwarding:
            _onUpdatePosition();
            break;
          case AudioProcessingState.rewinding:
            _onUpdatePosition();
            break;
          case AudioProcessingState.buffering:
            _onBuffering();
            break;
          case AudioProcessingState.error:
            _onError();
            break;
          case AudioProcessingState.connecting:
            break;
          case AudioProcessingState.skippingToPrevious:
            break;
          case AudioProcessingState.skippingToNext:
            break;
          case AudioProcessingState.skippingToQueueItem:
            break;
        }
      }
    });
  }

  /// Saves the current play position to persistent storage. This enables a
  /// podcast to continue playing where it left off if played at a later
  /// time.
  Future<void> _savePosition() async {
    var playbackState = AudioService.playbackState;

    if (_episode != null) {
      // The episode may have been updated elsewhere - re-fetch it.
      _episode = await repository.findEpisodeByGuid(_episode.guid);
      var currentPosition = playbackState.currentPosition?.inMilliseconds ?? 0;

      log.fine('_savePosition(): Current position is $currentPosition - stored position is ${_episode.position}');

      if (currentPosition != _episode.position) {
        _episode.position = currentPosition;

        _episode = await repository.saveEpisode(_episode);
      }
    } else {
      log.fine(' - Cannot save position as episode is null');
    }
  }

  /// Called when play starts. Each time we receive an event in the stream
  /// we check the current position of the episode from the audio service
  /// and then push that information out via the [_playPosition] stream
  /// to inform our listeners.
  void _startTicker() async {
    if (_positionSubscription == null) {
      _positionSubscription = _durationTicker.listen((int period) async {
        await _onUpdatePosition();
      });
    } else if (_positionSubscription.isPaused) {
      _positionSubscription.resume();
    }
  }

  void _stopTicker() async {
    if (_positionSubscription != null) {
      await _positionSubscription.cancel();

      _positionSubscription = null;
    }
  }

  /// Calculate our current chapter based on playback position, and if it's different to
  /// the currently stored chapter - update.
  void _updateChapter(int seconds, int duration) {
    if (_episode == null) {
      log.fine('Warning. Attempting to update chapter information on a null _episode');
    } else if (_episode.hasChapters && _episode.chaptersAreLoaded) {
      final chapters = _episode.chapters;

      for (var chapterPtr = 0; chapterPtr < _episode.chapters.length; chapterPtr++) {
        final startTime = chapters[chapterPtr].startTime;
        final endTime = chapterPtr == (_episode.chapters.length - 1) ? duration : chapters[chapterPtr + 1].startTime;

        if (seconds >= startTime && seconds < endTime) {
          if (chapters[chapterPtr] != _episode.currentChapter) {
            _episode.currentChapter = chapters[chapterPtr];
            _episodeEvent.sink.add(_episode);
            break;
          }
        }
      }
    }
  }

  List<String> _loadTrackDetails(String uri, int startPosition) {
    var track = <String>[
      _episode.author ?? 'Unknown Author',
      _episode.title ?? 'Unknown Title',
      _episode.imageUrl,
      uri,
      _episode.downloaded ? '1' : '0',
      startPosition.toString(),
      _episode.id == null ? '0' : _episode.id.toString(),
      _playbackSpeed.toString(),
      _episode.duration?.toString() ?? '0',
      _trimSilence ? '1' : '0',
      _volumeBoost ? '1' : '0',
    ];

    return track;
  }

  @override
  Episode get nowPlaying => _episode;

  /// Get the current playing state
  @override
  Stream<AudioState> get playingState => _playingState.stream;

  Stream<EpisodeState> get episodeListener => repository.episodeListener;

  @override
  Stream<PositionState> get playPosition => _playPosition.stream;

  @override
  Stream<Episode> get episodeEvent => _episodeEvent.stream;

  @override
  Stream<int> get playbackError => _playbackError.stream;
}

void backgroundPlay() {
  AudioServiceBackground.run(() => BackgroundPlayerTask());
}
