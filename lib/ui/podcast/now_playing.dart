// Copyright 2020-2022 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:anytime/bloc/podcast/audio_bloc.dart';
import 'package:anytime/entities/episode.dart';
import 'package:anytime/l10n/L.dart';
import 'package:anytime/services/audio/audio_player_service.dart';
import 'package:anytime/state/sleep_policy.dart';
import 'package:anytime/ui/podcast/chapter_selector.dart';
import 'package:anytime/ui/podcast/dot_decoration.dart';
import 'package:anytime/ui/podcast/now_playing_floating_player.dart';
import 'package:anytime/ui/podcast/now_playing_options.dart';
import 'package:anytime/ui/podcast/playback_error_listener.dart';
import 'package:anytime/ui/podcast/player_position_controls.dart';
import 'package:anytime/ui/podcast/player_transport_controls.dart';
import 'package:anytime/ui/widgets/delayed_progress_indicator.dart';
import 'package:anytime/ui/widgets/placeholder_builder.dart';
import 'package:anytime/ui/widgets/podcast_html.dart';
import 'package:anytime/ui/widgets/podcast_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// This is the full-screen player Widget which is invoked by touching the mini player.
/// This displays the podcast image, episode notes and standard playback controls.
///
/// TODO: The fade in/out transition applied when scrolling the queue is the first implementation.
/// Using [Opacity] is a very inefficient way of achieving this effect, but will do as a place
/// holder until a better animation can be achieved.
class NowPlaying extends StatefulWidget {
  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> with WidgetsBindingObserver {
  StreamSubscription<AudioState> playingStateSubscription;
  var textGroup = AutoSizeGroup();
  double opacity, scrollPos = 0.0;
  double baseSize = 48.0;
  Future<bool> isLoaded;
  bool isEmbedded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final audioBloc = Provider.of<AudioBloc>(context, listen: false);
    var popped = false;

    // If the episode finishes we can close.
    playingStateSubscription = audioBloc.playingState.where((state) => state == AudioState.stopped).listen((playingState) async {
      // Prevent responding to multiple stop events after we've popped and lost context.
      if (!popped) {
        Navigator.pop(context);
        popped = true;
      }
    });

    audioBloc.sleepPolicy
        .where((policy) => !policy.feedbackGiven)
        .listen((policy) => _policyChanged(policy));
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isLoaded = Future<bool>.value(true);
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    playingStateSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioBloc = Provider.of<AudioBloc>(context, listen: false);
    final playerBuilder = PlayerControlsBuilder.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final double bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return StreamBuilder<Episode>(
        stream: audioBloc.nowPlaying,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          var duration = snapshot.data == null ? 0 : snapshot.data.duration;
          final transportBuilder = playerBuilder?.builder(duration);
          isEmbedded = transportBuilder != null;
          baseSize = isEmbedded ? 24.0 : 48.0;

          return NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              setState(() {
                opacity = scrollPos =
                    (notification.extent - notification.minExtent) / (notification.maxExtent - notification.minExtent);
              });

              return true;
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                DefaultTabController(
                    length: snapshot.data.hasChapters ? 3 : 2,
                    initialIndex: snapshot.data.hasChapters ? 1 : 0,
                    child: Scaffold(
                      appBar: AppBar(
                        systemOverlayStyle: SystemUiOverlayStyle(
                          statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
                          systemNavigationBarColor: Theme.of(context).bottomAppBarColor,
                          statusBarColor: Colors.transparent,
                        ),
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                        elevation: 0.0,
                        leading: IconButton(
                          tooltip: L.of(context).minimise_player_window_button_label,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Theme.of(context).primaryIconTheme.color,
                          ),
                          onPressed: () => {
                            Navigator.pop(context),
                          },
                        ),
                        flexibleSpace: PlaybackErrorListener(
                          margin: isEmbedded ? baseSize + 64.0 : baseSize + 4.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              EpisodeTabBar(
                                chapters: snapshot.data.hasChapters,
                              ),
                            ],
                          ),
                        ),
                      ),
                      body: Column(
                        children: [
                          Expanded(
                            child: EpisodeTabBarView(
                              episode: snapshot.data,
                              chapters: snapshot.data.hasChapters,
                            ),
                          ),
                          if (isEmbedded) ...[
                            transportBuilder(context),
                          ],
                          if (!isEmbedded) ...[
                            SizedBox(
                              height: 148.0,
                              child: NowPlayingTransport(),
                            ),
                            SizedBox(height: baseSize)
                          ],
                        ],
                      ),
                    )),
                if (scrollPos > 0)
                  Padding(
                    padding: isEmbedded ? EdgeInsets.only(bottom: bottomPadding + 64) : EdgeInsets.zero,
                    child: Opacity(
                      opacity: opacity,
                      child: Column(
                        children: [
                          FloatingPlayer(),
                          Expanded(
                            child: Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                FutureBuilder(
                  future: isLoaded,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: isEmbedded ? EdgeInsets.only(bottom: bottomPadding + 64) : EdgeInsets.zero,
                        child: NowPlayingOptionsSelector(scrollPos: scrollPos, baseSize: baseSize, isEmbedded: isEmbedded),
                      );
                    }
                    return SizedBox();
                  },
                ),
              ],
            ),
          );
        });
  }

  void _policyChanged(SleepPolicy policy) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final texts = L.of(context);
    final double bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    if (scaffoldMessenger != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: baseSize + (isEmbedded ? bottomPadding + 64.0 : 4.0)),
          content: Text(
            policy is SleepPolicyOff ? texts.sleep_episode_function_toggled_off : texts.sleep_episode_function_toggled_on,
          ),
        ),
      );
      policy.feedbackGiven = true;
    }
  }
}

/// This class is responsible for rendering the tab selection at the top of the screen. It displays
/// two or three tabs depending upon whether the current episode supports (and contains) chapters.
class EpisodeTabBar extends StatelessWidget {
  final bool chapters;

  const EpisodeTabBar({
    Key key,
    this.chapters = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: DotDecoration(colour: Theme.of(context).primaryColor),
      tabs: [
        if (chapters)
          Tab(
            child: Align(
              alignment: Alignment.center,
              child: Text(L.of(context).chapters_label),
            ),
          ),
        Tab(
          child: Align(
            alignment: Alignment.center,
            child: Text(L.of(context).episode_label),
          ),
        ),
        Tab(
          child: Align(
            alignment: Alignment.center,
            child: Text(L.of(context).notes_label),
          ),
        ),
      ],
    );
  }
}

/// This class is responsible for rendering the tab body containing the chapter selection view (if
/// the episode supports chapters), the episode details (image and description) and the show
/// notes view.
class EpisodeTabBarView extends StatelessWidget {
  final Episode episode;
  final AutoSizeGroup textGroup;
  final bool chapters;

  EpisodeTabBarView({
    Key key,
    this.episode,
    this.textGroup,
    this.chapters = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioBloc = Provider.of<AudioBloc>(context);

    return TabBarView(
      children: [
        if (chapters)
          ChapterSelector(
            episode: episode,
          ),
        StreamBuilder<Episode>(
            stream: audioBloc.nowPlaying,
            builder: (context, snapshot) {
              final e = snapshot.hasData ? snapshot.data : episode;

              return NowPlayingEpisode(
                episode: e,
                imageUrl: e.positionalImageUrl,
                textGroup: textGroup,
              );
            }),
        NowPlayingShowNotes(title: episode.title, description: episode.description),
      ],
    );
  }
}

class NowPlayingEpisode extends StatelessWidget {
  final String imageUrl;
  final Episode episode;
  final AutoSizeGroup textGroup;

  const NowPlayingEpisode({
    @required this.imageUrl,
    @required this.episode,
    @required this.textGroup,
  });

  @override
  Widget build(BuildContext context) {
    final placeholderBuilder = PlaceholderBuilder.of(context);

    return OrientationBuilder(
      builder: (context, orientation) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: MediaQuery.of(context).orientation == Orientation.portrait
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: PodcastImage(
                        key: Key('nowplaying$imageUrl'),
                        url: imageUrl,
                        width: MediaQuery.of(context).size.width * .75,
                        height: MediaQuery.of(context).size.height * .75,
                        fit: BoxFit.contain,
                        borderRadius: 6.0,
                        placeholder: placeholderBuilder != null
                            ? placeholderBuilder?.builder()(context)
                            : DelayedCircularProgressIndicator(),
                        errorPlaceholder: placeholderBuilder != null
                            ? placeholderBuilder?.errorBuilder()(context)
                            : Image(image: AssetImage('assets/images/anytime-placeholder-logo.png')),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: NowPlayingEpisodeDetails(
                        episode: episode,
                        textGroup: textGroup,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: PodcastImage(
                        key: Key('nowplaying$imageUrl'),
                        url: imageUrl,
                        height: 280,
                        width: 280,
                        fit: BoxFit.contain,
                        borderRadius: 8.0,
                        placeholder: placeholderBuilder != null
                            ? placeholderBuilder?.builder()(context)
                            : DelayedCircularProgressIndicator(),
                        errorPlaceholder: placeholderBuilder != null
                            ? placeholderBuilder?.errorBuilder()(context)
                            : Image(image: AssetImage('assets/images/anytime-placeholder-logo.png')),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: NowPlayingEpisodeDetails(
                        episode: episode,
                        textGroup: textGroup,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class NowPlayingEpisodeDetails extends StatelessWidget {
  final Episode episode;
  final AutoSizeGroup textGroup;

  const NowPlayingEpisodeDetails({
    Key key,
    this.episode,
    this.textGroup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chapterTitle = episode?.currentChapter?.title ?? '';
    final chapterUrl = episode?.currentChapter?.url ?? '';

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoSizeText(
              episode?.title ?? '',
              group: textGroup,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              minFontSize: 12.0,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
              maxLines: episode.hasChapters ? 4 : 5,
            ),
          ),
        ),
        if (episode.hasChapters)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 4.0, 0.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: AutoSizeText(
                      chapterTitle ?? '',
                      group: textGroup,
                      minFontSize: 12.0,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ),
                      maxLines: 3,
                    ),
                  ),
                  chapterUrl.isEmpty
                      ? const SizedBox(
                          height: 0,
                          width: 0,
                        )
                      : IconButton(
                          icon: Icon(Icons.link),
                          color: Theme.of(context).primaryIconTheme.color,
                          onPressed: () {
                            _chapterLink(chapterUrl);
                          }),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _chapterLink(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch chapter link: $url';
    }
  }
}

class NowPlayingShowNotes extends StatelessWidget {
  final String title;
  final String description;

  const NowPlayingShowNotes({
    @required this.title,
    @required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            left: 16.0,
            right: 16.0,
          ),
          child: PodcastHtml(content: description),
        ),
      ),
    );
  }
}

class NowPlayingTransport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(
          height: 0.0,
        ),
        PlayerPositionControls(),
        PlayerTransportControls(),
      ],
    );
  }
}

class PlayerControlsBuilder extends InheritedWidget {
  final WidgetBuilder Function(int duration) builder;

  PlayerControlsBuilder({
    Key key,
    @required this.builder,
    @required Widget child,
  })  : assert(builder != null),
        assert(child != null),
        super(key: key, child: child);

  static PlayerControlsBuilder of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlayerControlsBuilder>();
  }

  @override
  bool updateShouldNotify(PlayerControlsBuilder oldWidget) {
    return builder != oldWidget.builder;
  }
}
