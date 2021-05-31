import 'package:flutter/foundation.dart';

/// Events
class NewPodcastsEvent {}

class NewPodcastsChartEvent extends NewPodcastsEvent {
  final int count;

  NewPodcastsChartEvent({@required this.count});
}

/// States
class NewPodcastsState {}

class NewPodcastsLoadingState extends NewPodcastsState {}

class NewPodcastsPopulatedState<T> extends NewPodcastsState {
  final T results;

  NewPodcastsPopulatedState(this.results);
}
