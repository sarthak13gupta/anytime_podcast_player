
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'anytime_texts_de.dart';
import 'anytime_texts_en.dart';
import 'anytime_texts_es.dart';
import 'anytime_texts_fi.dart';
import 'anytime_texts_fr.dart';
import 'anytime_texts_it.dart';
import 'anytime_texts_pt.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations returned
/// by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'gen_l10n/anytime_texts.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('it'),
    Locale('pt')
  ];

  /// Full title for the application
  ///
  /// In en, this message translates to:
  /// **'Anytime Podcast Player'**
  String get app_title;

  /// Title for the application
  ///
  /// In en, this message translates to:
  /// **'Anytime Player'**
  String get app_title_short;

  /// Library tab label
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// Discover tab label
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// Downloads tab label
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// Subscribe button label
  ///
  /// In en, this message translates to:
  /// **'FOLLOW'**
  String get subscribe_button_label;

  /// Unsubscribe button label
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unsubscribe_button_label;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel_button_label;

  /// OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok_button_label;

  /// Subscribe label
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get subscribe_label;

  /// Unsubscribe label
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unsubscribe_label;

  /// Displayed when the user unsubscribes from a podcast.
  ///
  /// In en, this message translates to:
  /// **'Unfollowing will delete all downloaded episodes of this podcast.'**
  String get unsubscribe_message;

  /// Hint displayed on search bar when the user clicks the search icon.
  ///
  /// In en, this message translates to:
  /// **'Search for podcasts'**
  String get search_for_podcasts_hint;

  /// Delete label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete_label;

  /// Delete label
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete_button_label;

  /// Mark as played
  ///
  /// In en, this message translates to:
  /// **'Mark Played'**
  String get mark_played_label;

  /// Mark as unplayed
  ///
  /// In en, this message translates to:
  /// **'Mark Unplayed'**
  String get mark_unplayed_label;

  /// User is asked to confirm when they attempt to delete an episode
  ///
  /// In en, this message translates to:
  /// **'Are you sure you wish to delete this episode?'**
  String get delete_episode_confirmation;

  /// Delete label
  ///
  /// In en, this message translates to:
  /// **'Delete Episode'**
  String get delete_episode_title;

  /// Displayed on the library tab when the user has no subscriptions
  ///
  /// In en, this message translates to:
  /// **'You do not have any downloaded episodes'**
  String get no_downloads_message;

  /// Displayed on the library tab when the user has no subscriptions
  ///
  /// In en, this message translates to:
  /// **'No podcasts found'**
  String get no_search_results_message;

  /// No description provided for @no_subscriptions_message.
  ///
  /// In en, this message translates to:
  /// **'Tap the Discovery button below or use the search bar above to find your first podcast'**
  String get no_subscriptions_message;

  /// Displayed on the podcast details page when the details could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Could not load podcast episodes. Please check your connection.'**
  String get no_podcast_details_message;

  /// Semantic label for the play button
  ///
  /// In en, this message translates to:
  /// **'Play episode'**
  String get play_button_label;

  /// Semantic label for the pause button
  ///
  /// In en, this message translates to:
  /// **'Pause episode'**
  String get pause_button_label;

  /// Semantic label for the download episode button
  ///
  /// In en, this message translates to:
  /// **'Download episode'**
  String get download_episode_button_label;

  /// Semantic label for the delete episode
  ///
  /// In en, this message translates to:
  /// **'Delete episode'**
  String get delete_episode_button_label;

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close_button_label;

  /// Search button label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search_button_label;

  /// Search button label
  ///
  /// In en, this message translates to:
  /// **'Clear search text'**
  String get clear_search_button_label;

  /// Search button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get search_back_button_label;

  /// Search button label
  ///
  /// In en, this message translates to:
  /// **'Minimise player window'**
  String get minimise_player_window_button_label;

  /// Rewind button tooltip
  ///
  /// In en, this message translates to:
  /// **'Rewind episode 30 seconds'**
  String get rewind_button_label;

  /// Fast forward tooltip
  ///
  /// In en, this message translates to:
  /// **'Fast-forward episode 30 seconds'**
  String get fast_forward_button_label;

  /// About menu item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about_label;

  /// Mark all episodes played menu item
  ///
  /// In en, this message translates to:
  /// **'Mark all episodes as played'**
  String get mark_episodes_played_label;

  /// Mark all episodes not-played menu item
  ///
  /// In en, this message translates to:
  /// **'Mark all episodes as not played'**
  String get mark_episodes_not_played_label;

  /// User is asked to confirm when they wish to stop the active download.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you wish to stop this download and delete the episode?'**
  String get stop_download_confirmation;

  /// Stop label
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop_download_button_label;

  /// Stop download label
  ///
  /// In en, this message translates to:
  /// **'Stop Download'**
  String get stop_download_title;

  /// Mark deleted episodes as played setting
  ///
  /// In en, this message translates to:
  /// **'Mark deleted episodes as played'**
  String get settings_mark_deleted_played_label;

  /// Download episodes to SD card setting
  ///
  /// In en, this message translates to:
  /// **'Download episodes to SD card'**
  String get settings_download_sd_card_label;

  /// Displayed when user switches from internal storage to SD card
  ///
  /// In en, this message translates to:
  /// **'New downloads will be saved to the SD card. Existing downloads will remain on internal storage.'**
  String get settings_download_switch_card;

  /// Displayed when user switches from internal SD card to internal storage
  ///
  /// In en, this message translates to:
  /// **'New downloads will be saved to internal storage. Existing downloads will remain on the SD card.'**
  String get settings_download_switch_internal;

  /// Dialog label for storage switch
  ///
  /// In en, this message translates to:
  /// **'Change storage location'**
  String get settings_download_switch_label;

  /// Cancel option label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel_option_label;

  /// Dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get settings_theme_switch_label;

  /// Set playback speed icon label
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get playback_speed_label;

  /// Set show notes icon label
  ///
  /// In en, this message translates to:
  /// **'Show notes'**
  String get show_notes_label;

  /// Set search provider label
  ///
  /// In en, this message translates to:
  /// **'Search provider'**
  String get search_provider_label;

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_label;

  /// Go-back button label
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get go_back_button_label;

  /// Continue button label
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_button_label;

  /// Display when first accessing external funding link
  ///
  /// In en, this message translates to:
  /// **'This funding link will take you to an external site where you will be able to directly support the show. Links are provided by the podcast authors and is not controlled by Breez.'**
  String get consent_message;

  /// Tab label on now playing screen.
  ///
  /// In en, this message translates to:
  /// **'Episode'**
  String get episode_label;

  /// Tab label on now playing screen.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chapters_label;

  /// Tab label on now playing screen.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes_label;

  /// Header on podcast funding consent dialog
  ///
  /// In en, this message translates to:
  /// **'Podcast Funding'**
  String get podcast_funding_dialog_header;

  /// Displayed when user switches to use full screen player automatically
  ///
  /// In en, this message translates to:
  /// **'Full screen player mode on episode start'**
  String get settings_auto_open_now_playing;

  /// Displayed when attempting to start streaming an episode with no data connection
  ///
  /// In en, this message translates to:
  /// **'Unable to play episode. Please check your connection and try again.'**
  String get error_no_connection;

  /// Displayed when attempting to start streaming an episode with no data connection
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred during playback. Please check your connection and try again.'**
  String get error_playback_fail;

  /// Option label for adding manual RSS feed url
  ///
  /// In en, this message translates to:
  /// **'Add RSS Feed'**
  String get add_rss_feed_option;

  /// Option label importing OPML file
  ///
  /// In en, this message translates to:
  /// **'Import OPML'**
  String get settings_import_opml;

  /// Option label exporting OPML file
  ///
  /// In en, this message translates to:
  /// **'Export OPML'**
  String get settings_export_opml;

  /// Label for importing OPML dialog
  ///
  /// In en, this message translates to:
  /// **'Importing'**
  String get label_opml_importing;

  /// Option label for auto updating of episodes
  ///
  /// In en, this message translates to:
  /// **'Refresh episodes on details screen after'**
  String get settings_auto_update_episodes_heading;

  /// Option label for auto updating of episodes
  ///
  /// In en, this message translates to:
  /// **'Auto update episodes'**
  String get settings_auto_update_episodes;

  /// Option label for auto updating of episodes
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get settings_auto_update_episodes_never;

  /// Option label for auto updating of episodes
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get settings_auto_update_episodes_always;

  /// Option label for auto updating of episodes
  ///
  /// In en, this message translates to:
  /// **'10 minutes since last update'**
  String get settings_auto_update_episodes_10min;

  /// Option label for auto updating of episodes
  ///
  /// In en, this message translates to:
  /// **'30 minutes since last update'**
  String get settings_auto_update_episodes_30min;

  /// Option label for auto updating of episodes
  ///
  /// In en, this message translates to:
  /// **'1 hour since last update'**
  String get settings_auto_update_episodes_1hour;

  /// Option label for auto updating of episodes
  ///
  /// In en, this message translates to:
  /// **'3 hours since last update'**
  String get settings_auto_update_episodes_3hour;

  /// Option label for auto updating of episodes
  ///
  /// In en, this message translates to:
  /// **'6 hours since last update'**
  String get settings_auto_update_episodes_6hour;

  /// Option label for auto updating of episodes
  ///
  /// In en, this message translates to:
  /// **'12 hours since last update'**
  String get settings_auto_update_episodes_12hour;

  /// Option label for new episodes snackbar
  ///
  /// In en, this message translates to:
  /// **'New episodes are available'**
  String get new_episodes_label;

  /// Option action label for new episodes snackbar
  ///
  /// In en, this message translates to:
  /// **'VIEW NOW'**
  String get new_episodes_view_now_label;

  /// Settings divider label for personalisation
  ///
  /// In en, this message translates to:
  /// **'PERSONALISATION'**
  String get settings_personalisation_divider_label;

  /// Settings divider label for episodes
  ///
  /// In en, this message translates to:
  /// **'EPISODES'**
  String get settings_episodes_divider_label;

  /// Settings divider label for playback
  ///
  /// In en, this message translates to:
  /// **'PLAYBACK'**
  String get settings_playback_divider_label;

  /// Settings divider label for data
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get settings_data_divider_label;

  /// Label for trim silence toggle
  ///
  /// In en, this message translates to:
  /// **'Trim Silence'**
  String get audio_effect_trim_silence_label;

  /// Label for volume boost toggle
  ///
  /// In en, this message translates to:
  /// **'Volume Boost'**
  String get audio_effect_volume_boost_label;

  /// Label for playback settings widget
  ///
  /// In en, this message translates to:
  /// **'Playback Speed'**
  String get audio_settings_playback_speed_label;

  /// Displayed when there are no items left in the queue
  ///
  /// In en, this message translates to:
  /// **'Your queue is empty'**
  String get empty_queue_message;

  /// Clear queue button label
  ///
  /// In en, this message translates to:
  /// **'CLEAR QUEUE'**
  String get clear_queue_button_label;

  /// Now playing label on queue
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get now_playing_queue_label;

  /// Up next label on queue
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get up_next_queue_label;

  /// More label
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more_label;

  /// Queue add label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get queue_add_label;

  /// Queue remove label
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get queue_remove_label;

  /// OPML Import button label
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get opml_import_button_label;

  /// OPML Export button label
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get opml_export_button_label;

  /// OPML Import/Export label
  ///
  /// In en, this message translates to:
  /// **'OPML Import/Export'**
  String get opml_import_export_label;

  /// Shown on dialog box when clearing queue
  ///
  /// In en, this message translates to:
  /// **'Are you sure you wish to clear the queue?'**
  String get queue_clear_label;

  /// Shown on dialog box when clearing queue
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get queue_clear_button_label;

  /// Shown on dialog box when clearing queue
  ///
  /// In en, this message translates to:
  /// **'Clear Queue'**
  String get queue_clear_label_title;

  /// Layout menu label
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get layout_label;

  /// No description provided for @sleep_episode_function_header.
  ///
  /// In en, this message translates to:
  /// **'Sleep after'**
  String get sleep_episode_function_header;

  /// No description provided for @sleep_episode_function_turn_off.
  ///
  /// In en, this message translates to:
  /// **'Turn off timer'**
  String get sleep_episode_function_turn_off;

  /// No description provided for @sleep_episode_function_toggled_on.
  ///
  /// In en, this message translates to:
  /// **'Your sleep timer is on.'**
  String get sleep_episode_function_toggled_on;

  /// No description provided for @sleep_episode_function_toggled_off.
  ///
  /// In en, this message translates to:
  /// **'Your sleep timer is off.'**
  String get sleep_episode_function_toggled_off;

  /// No description provided for @sleep_episode_function_end_of_episode.
  ///
  /// In en, this message translates to:
  /// **'End of Episode'**
  String get sleep_episode_function_end_of_episode;

  /// No description provided for @sleep_episode_function_5_minutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get sleep_episode_function_5_minutes;

  /// No description provided for @sleep_episode_function_15_minutes.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get sleep_episode_function_15_minutes;

  /// No description provided for @sleep_episode_function_30_minutes.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get sleep_episode_function_30_minutes;

  /// No description provided for @sleep_episode_function_45_minutes.
  ///
  /// In en, this message translates to:
  /// **'45 minutes'**
  String get sleep_episode_function_45_minutes;

  /// No description provided for @sleep_episode_function_60_minutes.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get sleep_episode_function_60_minutes;

  /// No description provided for @proceed_button_label.
  ///
  /// In en, this message translates to:
  /// **'Proceed anyway'**
  String get proceed_button_label;

  /// No description provided for @non_secure_connection_dialog_header.
  ///
  /// In en, this message translates to:
  /// **'Your connection is not private'**
  String get non_secure_connection_dialog_header;

  /// No description provided for @non_secure_connection_message.
  ///
  /// In en, this message translates to:
  /// **'The site isn\'t using a private connection. Someone might be able to see or change the information you send or get through this site. Contact the site owner to ask that they secure the site and your data with HTTPS.'**
  String get non_secure_connection_message;

  /// No description provided for @new_podcasts.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get new_podcasts;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fi', 'fr', 'it', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fi': return AppLocalizationsFi();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
