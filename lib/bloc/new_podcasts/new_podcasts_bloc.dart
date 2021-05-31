// Copyright 2020-2021 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:anytime/bloc/bloc.dart';
import 'package:anytime/bloc/new_podcasts/new_podcasts_state_event.dart';
import 'package:anytime/services/podcast/podcast_service.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:podcast_search/podcast_search.dart' as pcast;
import 'package:rxdart/rxdart.dart';

/// A BLoC to interact with the New Podcasts UI page and the [PodcastService] to
/// fetch the iTunes charts. As charts will not change very frequently the
/// results are cached for [cacheMinutes].
class NewPodcastsBloc extends Bloc {
  static const cacheMinutes = 30;
  final log = Logger('NewPodcastsBloc');
  final PodcastService podcastService;

  final BehaviorSubject<NewPodcastsEvent> _newPodcastsInput = BehaviorSubject<NewPodcastsEvent>();

  Stream<NewPodcastsState> _newPodcastsResults;
  pcast.SearchResult _resultsCache;

  NewPodcastsBloc({@required this.podcastService}) {
    _init();
  }

  void _init() {
    _newPodcastsResults = _newPodcastsInput.switchMap<NewPodcastsState>((NewPodcastsEvent event) => _mostRecent(event));
  }

  Stream<NewPodcastsState> _mostRecent(NewPodcastsEvent event) async* {
    yield NewPodcastsLoadingState();

    if (event is NewPodcastsChartEvent) {
      if (_resultsCache == null || DateTime.now().difference(_resultsCache.processedTime).inMinutes > cacheMinutes) {
        _resultsCache = await podcastService.mostRecent();
      }

      yield NewPodcastsPopulatedState<pcast.SearchResult>(_resultsCache);
    }
  }

  @override
  void dispose() {
    _newPodcastsInput.close();
  }

  void Function(NewPodcastsEvent) get getNewPodcasts => _newPodcastsInput.add;

  Stream<NewPodcastsState> get results => _newPodcastsResults;
}
