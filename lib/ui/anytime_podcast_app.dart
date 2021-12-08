// Copyright 2020-2021 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:anytime/api/podcast/mobile_podcast_api.dart';
import 'package:anytime/api/podcast/podcast_api.dart';
import 'package:anytime/bloc/discovery/discovery_bloc.dart';
import 'package:anytime/bloc/new_podcasts/new_podcasts_bloc.dart';
import 'package:anytime/bloc/podcast/audio_bloc.dart';
import 'package:anytime/bloc/podcast/episode_bloc.dart';
import 'package:anytime/bloc/podcast/opml_bloc.dart';
import 'package:anytime/bloc/podcast/podcast_bloc.dart';
import 'package:anytime/bloc/search/search_bloc.dart';
import 'package:anytime/bloc/settings/settings_bloc.dart';
import 'package:anytime/bloc/ui/pager_bloc.dart';
import 'package:anytime/core/environment.dart';
import 'package:anytime/entities/app_settings.dart';
import 'package:anytime/entities/podcast.dart';
import 'package:anytime/l10n/L.dart';
import 'package:anytime/repository/repository.dart';
import 'package:anytime/repository/sembast/sembast_repository.dart';
import 'package:anytime/services/audio/audio_player_service.dart';
import 'package:anytime/services/audio/mobile_audio_player_service.dart';
import 'package:anytime/services/download/download_service.dart';
import 'package:anytime/services/download/mobile_download_manager.dart';
import 'package:anytime/services/download/mobile_download_service.dart';
import 'package:anytime/services/podcast/mobile_opml_service.dart';
import 'package:anytime/services/podcast/mobile_podcast_service.dart';
import 'package:anytime/services/podcast/opml_service.dart';
import 'package:anytime/services/podcast/podcast_service.dart';
import 'package:anytime/services/settings/mobile_settings_service.dart';
import 'package:anytime/ui/library/discovery.dart';
import 'package:anytime/ui/library/downloads.dart';
import 'package:anytime/ui/library/library.dart';
import 'package:anytime/ui/library/new_podcasts.dart';
import 'package:anytime/ui/podcast/mini_player.dart';
import 'package:anytime/ui/podcast/podcast_details.dart';
import 'package:anytime/ui/search/search.dart';
import 'package:anytime/ui/settings/settings.dart';
import 'package:anytime/ui/themes.dart';
import 'package:anytime/ui/widgets/action_text.dart';
import 'package:anytime/ui/widgets/search_slide_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

var theme = Themes.lightTheme().themeData;

/// Anytime is a Podcast player. You can search and subscribe to podcasts,
/// download and stream episodes and view the latest podcast charts.
// ignore: must_be_immutable
class AnytimePodcastApp extends StatefulWidget {
  final Repository repository;
  PodcastApi podcastApi;
  DownloadService downloadService;
  PodcastService podcastService;
  AudioPlayerService audioPlayerService;
  SettingsBloc settingsBloc;
  MobileSettingsService mobileSettingsService;
  OPMLService opmlService;
  List<int> certificateAuthorityBytes;

  AnytimePodcastApp(
    this.mobileSettingsService, {
    this.certificateAuthorityBytes,
  }) : repository = SembastRepository() {
    podcastApi = MobilePodcastApi();
    downloadService = MobileDownloadService(
      repository: repository,
      downloadManager: MobileDownloaderManager(),
    );
    podcastService = MobilePodcastService(
      api: podcastApi,
      repository: repository,
      settingsService: mobileSettingsService,
    );
    audioPlayerService = MobileAudioPlayerService(
      repository: repository,
      settingsService: mobileSettingsService,
      podcastService: podcastService,
    );
    settingsBloc = SettingsBloc(mobileSettingsService);
    opmlService = MobileOPMLService(
      podcastService: podcastService,
      repository: repository,
    );

    podcastApi.addClientAuthorityBytes(certificateAuthorityBytes);
  }

  @override
  _AnytimePodcastAppState createState() => _AnytimePodcastAppState();
}

class _AnytimePodcastAppState extends State<AnytimePodcastApp> with WidgetsBindingObserver {
  ThemeData theme;
  AudioBloc audioBloc;

  @override
  void initState() {
    super.initState();

    audioBloc = Provider.of<AudioBloc>(context, listen: false);

    WidgetsBinding.instance.addObserver(this);

    audioBloc.transitionLifecycleState(LifecyleState.resume);

    widget.settingsBloc.settings.listen((event) {
      setState(() {
        var newTheme = event.theme == 'dark' ? Themes.darkTheme().themeData : Themes.lightTheme().themeData;

        /// Only update the theme if it has changed.
        if (newTheme != theme) {
          theme = newTheme;
        }
      });
    });

    if (widget.mobileSettingsService.themeDarkMode) {
      theme = Themes.darkTheme().themeData;
    } else {
      theme = Themes.lightTheme().themeData;
    }
  }

  @override
  void dispose() {
    audioBloc.transitionLifecycleState(LifecyleState.pause);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final audioBloc = Provider.of<AudioBloc>(context, listen: false);

    switch (state) {
      case AppLifecycleState.resumed:
        audioBloc.transitionLifecycleState(LifecyleState.resume);
        break;
      case AppLifecycleState.paused:
        audioBloc.transitionLifecycleState(LifecyleState.pause);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SearchBloc>(
          create: (_) => SearchBloc(
              podcastService: MobilePodcastService(
            api: widget.podcastApi,
            repository: widget.repository,
            settingsService: widget.mobileSettingsService,
          )),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<DiscoveryBloc>(
          create: (_) => DiscoveryBloc(
              podcastService: MobilePodcastService(
            api: widget.podcastApi,
            repository: widget.repository,
            settingsService: widget.mobileSettingsService,
          )),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<NewPodcastsBloc>(
          create: (_) => NewPodcastsBloc(
              podcastService: MobilePodcastService(
            api: widget.podcastApi,
            repository: widget.repository,
            settingsService: widget.mobileSettingsService,
          )),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<EpisodeBloc>(
          create: (_) => EpisodeBloc(
              podcastService: MobilePodcastService(
                api: widget.podcastApi,
                repository: widget.repository,
                settingsService: widget.mobileSettingsService,
              ),
              audioPlayerService: widget.audioPlayerService),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<PodcastBloc>(
          create: (_) => PodcastBloc(
              podcastService: widget.podcastService,
              audioPlayerService: widget.audioPlayerService,
              downloadService: widget.downloadService,
              settingsService: widget.mobileSettingsService),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<PagerBloc>(
          create: (_) => PagerBloc(),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<AudioBloc>(
          create: (_) => AudioBloc(audioPlayerService: widget.audioPlayerService),
          dispose: (_, value) => value.dispose(),
        ),
        Provider<SettingsBloc>(
          create: (_) => widget.settingsBloc,
          dispose: (_, value) => value.dispose(),
        ),
        Provider<OPMLBloc>(
          create: (_) => OPMLBloc(opmlService: widget.opmlService),
          dispose: (_, value) => value.dispose(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Anytime Podcast Player',
        localizationsDelegates: [
          const LocalisationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('de', ''),
        ],
        theme: theme,
        home: AnytimeHomePage(title: 'Anytime Podcast Player'),
      ),
    );
  }
}

class AnytimeHomePage extends StatefulWidget {
  final String title;
  final String noSubscriptionsMessage;
  final bool topBarVisible;
  final bool inlineSearch;

  AnytimeHomePage({this.title, this.noSubscriptionsMessage, this.topBarVisible = true, this.inlineSearch = false});

  @override
  _AnytimeHomePageState createState() => _AnytimeHomePageState();
}

class _AnytimeHomePageState extends State<AnytimeHomePage> {
  final log = Logger('_AnytimeHomePageState');
  Widget library;

  @override
  void initState() {
    super.initState();
    Environment.loadEnvironment();
  }

  @override
  Widget build(BuildContext context) {
    final pager = Provider.of<PagerBloc>(context);
    var settings = Provider.of<SettingsBloc>(context).currentSettings;
    final backgroundColour = Theme.of(context).scaffoldBackgroundColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.light ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Theme.of(context).bottomAppBarColor,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: backgroundColour,
        body: Column(
          children: <Widget>[
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverVisibility(
                    visible: widget.topBarVisible,
                    sliver: SliverAppBar(
                      title: TitleWidget(),
                      backgroundColor: backgroundColour,
                      floating: false,
                      pinned: true,
                      snap: false,
                      actions: <Widget>[
                        IconButton(
                          tooltip: L.of(context).search_button_label,
                          icon: Icon(Icons.search),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              SlideRightRoute(widget: Search()),
                            );
                          },
                        ),
                        PopupMenuButton<String>(
                          color: Theme.of(context).dialogBackgroundColor,
                          onSelected: _menuSelect,
                          icon: Icon(
                            Icons.more_vert,
                          ),
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                textStyle: Theme.of(context).textTheme.subtitle1,
                                value: 'rss',
                                child: Text(L.of(context).add_rss_feed_option),
                              ),
                              PopupMenuItem<String>(
                                textStyle: Theme.of(context).textTheme.subtitle1,
                                value: 'settings',
                                child: Text(L.of(context).settings_label),
                              ),
                              PopupMenuItem<String>(
                                textStyle: Theme.of(context).textTheme.subtitle1,
                                value: 'about',
                                child: Text(L.of(context).about_label),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<int>(
                      stream: pager.currentPage,
                      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                        return _fragment(snapshot.data, settings.searchProvider);
                      }),
                ],
              ),
            ),
            MiniPlayer(),
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: 64,
          child: StreamBuilder<int>(
              stream: pager.currentPage,
              initialData: 0,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                var selectedItemColor = Theme.of(context).iconTheme.color;
                var unselectedItemColor = HSLColor.fromColor(Theme.of(context).bottomAppBarColor).withLightness(0.85).toColor();
                return BottomNavigationBar(
                  elevation: Theme.of(context).bottomAppBarTheme.elevation,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Theme.of(context).bottomAppBarColor,
                  selectedIconTheme: Theme.of(context).iconTheme,
                  selectedItemColor: Theme.of(context).iconTheme.color,
                  unselectedItemColor: HSLColor.fromColor(Theme.of(context).bottomAppBarColor).withLightness(0.85).toColor(),
                  currentIndex: snapshot.data,
                  onTap: pager.changePage,
                  items: _buildNavBarItems(unselectedItemColor, selectedItemColor, context, settings),
                );
              }),
        ),
      ),
    );
  }

  Widget _fragment(int index, String searchProvider) {
    if (index == 0) {
      return Library(noSubscriptionsMessage: widget.noSubscriptionsMessage);
    } else if (index == 1) {
      return Discovery(inlineSearch: widget.inlineSearch);
    } else if (index == 2 && searchProvider == 'podcastindex') {
      return NewPodcasts(inlineSearch: widget.inlineSearch);
    } else {
      return Downloads();
    }
  }

  List<BottomNavigationBarItem> _buildNavBarItems(
      Color unselectedItemColor, Color selectedItemColor, BuildContext context, AppSettings settings) {
    var navBarItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: SvgPicture.asset('assets/icons/library.svg', color: unselectedItemColor, height: 24, width: 24),
        activeIcon: SvgPicture.asset('assets/icons/library.svg', color: selectedItemColor, height: 32, width: 32),
        label: L.of(context).library,
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset('assets/icons/discovery.svg', color: unselectedItemColor, height: 24, width: 24),
        activeIcon: SvgPicture.asset('assets/icons/discovery.svg', color: selectedItemColor, height: 32, width: 32),
        label: L.of(context).discover,
      ),
      BottomNavigationBarItem(
        icon: SvgPicture.asset('assets/icons/download.svg', color: unselectedItemColor, height: 24, width: 24),
        activeIcon: SvgPicture.asset('assets/icons/download.svg', color: selectedItemColor, height: 32, width: 32),
        label: L.of(context).downloads,
      ),
    ];
    if (settings.searchProvider == 'podcastindex') {
      navBarItems.insert(
          2,
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/icons/new_podcasts.svg', color: unselectedItemColor, height: 24, width: 24),
            activeIcon: SvgPicture.asset('assets/icons/new_podcasts.svg', color: selectedItemColor, height: 32, width: 32),
            label: L.of(context).new_podcasts,
          ));
    }
    return navBarItems;
  }

  void _menuSelect(String choice) async {
    var _textFieldController = TextEditingController();
    var _podcastBloc = Provider.of<PodcastBloc>(context, listen: false);
    var url = '';

    switch (choice) {
      case 'about':
        showAboutDialog(
            context: context,
            applicationName: 'Anytime Podcast Player',
            applicationVersion: 'v${Environment.projectVersion}',
            applicationIcon: Image.asset(
              'assets/images/anytime-logo-s.png',
              width: 52.0,
              height: 52.0,
            ),
            children: <Widget>[
              Text('\u00a9 2020-2021 Ben Hills'),
              GestureDetector(
                onTap: () {
                  _launchEmail();
                },
                child: Text(
                  'hello@anytimeplayer.app',
                  style: TextStyle(decoration: TextDecoration.underline, color: Theme.of(context).buttonColor,),
                ),
              ),
            ]);
        break;
      case 'settings':
        await Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (context) => Settings()),
        );
        break;
      case 'rss':
        await showPlatformDialog<void>(
          context: context,
          useRootNavigator: false,
          builder: (_) => BasicDialogAlert(
            title: Text(L.of(context).add_rss_feed_option),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  url = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: 'https://'),
            ),
            actions: <Widget>[
              BasicDialogAction(
                title: ActionText(
                  L.of(context).cancel_button_label,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              BasicDialogAction(
                title: ActionText(
                  L.of(context).ok_button_label,
                ),
                iosIsDefaultAction: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (context) => PodcastDetails(Podcast.fromUrl(url: url), _podcastBloc)),
                  ).then((value) => Navigator.pop(context));
                },
              ),
            ],
          ),
        );
        break;
    }
  }

  void _launchEmail() async {
    const url = 'mailto:hello@anytimeplayer.app';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class TitleWidget extends StatelessWidget {
  final TextStyle _titleTheme1 = theme.textTheme.bodyText2.copyWith(
    color: Colors.red,
    fontWeight: FontWeight.bold,
    fontFamily: 'MontserratRegular',
    fontSize: 18,
  );

  final TextStyle _titleTheme2Light = theme.textTheme.bodyText2.copyWith(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontFamily: 'MontserratRegular',
    fontSize: 18,
  );

  final TextStyle _titleTheme2Dark = theme.textTheme.bodyText2.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontFamily: 'MontserratRegular',
    fontSize: 18,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Row(
        children: <Widget>[
          Text(
            'Anytime ',
            style: _titleTheme1,
          ),
          Text(
            'Player',
            style: Theme.of(context).brightness == Brightness.light ? _titleTheme2Light : _titleTheme2Dark,
          ),
        ],
      ),
    );
  }
}
