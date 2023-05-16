// Copyright 2020-2022 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:ui';

import 'package:anytime/l10n/generated/anytime_texts.dart';
import 'package:anytime/l10n/generated/anytime_texts_de.dart';
import 'package:anytime/l10n/generated/anytime_texts_en.dart';
import 'package:anytime/l10n/generated/anytime_texts_es.dart';
import 'package:anytime/l10n/generated/anytime_texts_fi.dart';
import 'package:anytime/l10n/generated/anytime_texts_fr.dart';
import 'package:anytime/l10n/generated/anytime_texts_it.dart';
import 'package:anytime/l10n/generated/anytime_texts_pt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class L {
  L(this.localizations, this.overrides);

  static L load(Locale locale, Map<String, Map<String, String>>? overrides) {
    final localization = localeMap[locale.languageCode] ?? AppLocalizationsEn();
    return L(localization, overrides);
  }

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L) ?? L(AppLocalizationsEn(), {});
  }

  static get localeMap => {
        'de': AppLocalizationsDe(),
        'en': AppLocalizationsEn(),
        'es': AppLocalizationsEs(),
        'fi': AppLocalizationsFi(),
        'fr': AppLocalizationsFr(),
        'it': AppLocalizationsIt(),
        'pt': AppLocalizationsPt(),
      };

  final AppLocalizations localizations;
  Map<String, Map<String, String>>? overrides;

  /// Message definitions start here
  String? message(String name) {
    if (overrides == null || (overrides != null && overrides!.isEmpty) || (overrides != null && !overrides!.containsKey(name))) {
      return null;
    } else {
      return overrides![name]![localizations.localeName] ?? 'Missing translation for $name and locale $localizations';
    }
  }

  String get app_title => message('app_title') ?? localizations.app_title;

  String get app_title_short => message('app_title_short') ?? localizations.app_title_short;

  String get library => message('library') ?? localizations.library;

  String get discover => message('discover') ?? localizations.discover;

  String get new_podcasts => message('new_podcasts') ?? localizations.new_podcasts;

  String get downloads => message('downloads') ?? localizations.downloads;

  String get subscribe_button_label => message('subscribe_button_label') ?? localizations.subscribe_button_label;

  String get unsubscribe_button_label => message('unsubscribe_button_label') ?? localizations.unsubscribe_button_label;

  String get cancel_button_label => message('cancel_button_label') ?? localizations.cancel_button_label;

  String get ok_button_label => message('ok_button_label') ?? localizations.ok_button_label;

  String get subscribe_label => message('subscribe_label') ?? localizations.subscribe_label;

  String get unsubscribe_label => message('unsubscribe_label') ?? localizations.unsubscribe_label;

  String get unsubscribe_message => message('unsubscribe_message') ?? localizations.unsubscribe_message;

  String get search_for_podcasts_hint => message('search_for_podcasts_hint') ?? localizations.search_for_podcasts_hint;

  String get no_subscriptions_message => message('no_subscriptions_message') ?? localizations.no_subscriptions_message;

  String get delete_label => message('delete_label') ?? localizations.delete_label;

  String get delete_button_label => message('delete_button_label') ?? localizations.delete_button_label;

  String get mark_played_label => message('mark_played_label') ?? localizations.mark_played_label;

  String get mark_unplayed_label => message('mark_unplayed_label') ?? localizations.mark_unplayed_label;

  String get delete_episode_confirmation =>
      message('delete_episode_confirmation') ?? localizations.delete_episode_confirmation;

  String get delete_episode_title => message('delete_episode_title') ?? localizations.delete_episode_title;

  String get no_downloads_message => message('no_downloads_message') ?? localizations.no_downloads_message;

  String get no_search_results_message =>
      message('no_search_results_message') ?? localizations.no_search_results_message;

  String get no_podcast_details_message =>
      message('no_podcast_details_message') ?? localizations.no_podcast_details_message;

  String get play_button_label => message('play_button_label') ?? localizations.play_button_label;

  String get pause_button_label => message('pause_button_label') ?? localizations.pause_button_label;

  String get download_episode_button_label =>
      message('download_episode_button_label') ?? localizations.download_episode_button_label;

  String get delete_episode_button_label =>
      message('delete_episode_button_label') ?? localizations.delete_episode_button_label;

  String get close_button_label => message('close_button_label') ?? localizations.close_button_label;

  String get search_button_label => message('search_button_label') ?? localizations.search_button_label;

  String get clear_search_button_label =>
      message('clear_search_button_label') ?? localizations.clear_search_button_label;

  String get search_back_button_label => message('search_back_button_label') ?? localizations.search_back_button_label;

  String get minimise_player_window_button_label =>
      message('minimise_player_window_button_label') ?? localizations.minimise_player_window_button_label;

  String get rewind_button_label => message('rewind_button_label') ?? localizations.rewind_button_label;

  String get fast_forward_button_label =>
      message('fast_forward_button_label') ?? localizations.fast_forward_button_label;

  String get about_label => message('about_label') ?? localizations.about_label;

  String get mark_episodes_played_label =>
      message('mark_episodes_played_label') ?? localizations.mark_episodes_played_label;

  String get mark_episodes_not_played_label =>
      message('mark_episodes_not_played_label') ?? localizations.mark_episodes_not_played_label;

  String get stop_download_confirmation =>
      message('stop_download_confirmation') ?? localizations.stop_download_confirmation;

  String get stop_download_button_label =>
      message('stop_download_button_label') ?? localizations.stop_download_button_label;

  String get stop_download_title => message('stop_download_title') ?? localizations.stop_download_title;

  String get settings_mark_deleted_played_label =>
      message('settings_mark_deleted_played_label') ?? localizations.settings_mark_deleted_played_label;

  String get settings_download_sd_card_label =>
      message('settings_download_sd_card_label') ?? localizations.settings_download_sd_card_label;

  String get settings_download_switch_card =>
      message('settings_download_switch_card') ?? localizations.settings_download_switch_card;

  String get settings_download_switch_internal =>
      message('settings_download_switch_internal') ?? localizations.settings_download_switch_internal;

  String get settings_download_switch_label =>
      message('settings_download_switch_label') ?? localizations.settings_download_switch_label;

  String get cancel_option_label => message('cancel_option_label') ?? localizations.cancel_option_label;

  String get settings_theme_switch_label =>
      message('settings_theme_switch_label') ?? localizations.settings_theme_switch_label;

  String get playback_speed_label => message('playback_speed_label') ?? localizations.playback_speed_label;

  String get show_notes_label => message('show_notes_label') ?? localizations.show_notes_label;

  String get search_provider_label => message('search_provider_label') ?? localizations.search_provider_label;

  String get settings_label => message('settings_label') ?? localizations.settings_label;

  String get go_back_button_label => message('go_back_button_label') ?? localizations.go_back_button_label;

  String get continue_button_label => message('continue_button_label') ?? localizations.continue_button_label;

  String get consent_message => message('consent_message') ?? localizations.consent_message;

  String get episode_label => message('episode_label') ?? localizations.episode_label;

  String get chapters_label => message('chapters_label') ?? localizations.chapters_label;

  String get notes_label => message('notes_label') ?? localizations.notes_label;

  String get podcast_funding_dialog_header =>
      message('podcast_funding_dialog_header') ?? localizations.podcast_funding_dialog_header;

  String get settings_auto_open_now_playing =>
      message('settings_auto_open_now_playing') ?? localizations.settings_auto_open_now_playing;

  String get error_no_connection => message('error_no_connection') ?? localizations.error_no_connection;

  String get error_playback_fail => message('error_playback_fail') ?? localizations.error_playback_fail;

  String get add_rss_feed_option => message('add_rss_feed_option') ?? localizations.add_rss_feed_option;

  String get settings_import_opml => message('settings_import_opml') ?? localizations.settings_import_opml;

  String get settings_export_opml => message('settings_export_opml') ?? localizations.settings_export_opml;

  String get label_opml_importing => message('label_opml_importing') ?? localizations.label_opml_importing;

  String get settings_auto_update_episodes =>
      message('settings_auto_update_episodes') ?? localizations.settings_auto_update_episodes;

  String get settings_auto_update_episodes_never =>
      message('settings_auto_update_episodes_never') ?? localizations.settings_auto_update_episodes_never;

  String get settings_auto_update_episodes_heading =>
      message('settings_auto_update_episodes_heading') ?? localizations.settings_auto_update_episodes_heading;

  String get settings_auto_update_episodes_always =>
      message('settings_auto_update_episodes_always') ?? localizations.settings_auto_update_episodes_always;

  String get settings_auto_update_episodes_10min =>
      message('settings_auto_update_episodes_10min') ?? localizations.settings_auto_update_episodes_10min;

  String get settings_auto_update_episodes_30min =>
      message('settings_auto_update_episodes_30min') ?? localizations.settings_auto_update_episodes_30min;

  String get settings_auto_update_episodes_1hour =>
      message('settings_auto_update_episodes_1hour') ?? localizations.settings_auto_update_episodes_1hour;

  String get settings_auto_update_episodes_3hour =>
      message('settings_auto_update_episodes_3hour') ?? localizations.settings_auto_update_episodes_3hour;

  String get settings_auto_update_episodes_6hour =>
      message('settings_auto_update_episodes_6hour') ?? localizations.settings_auto_update_episodes_6hour;

  String get settings_auto_update_episodes_12hour =>
      message('settings_auto_update_episodes_12hour') ?? localizations.settings_auto_update_episodes_12hour;

  String get new_episodes_label => message('new_episodes_label') ?? localizations.new_episodes_label;

  String get new_episodes_view_now_label =>
      message('new_episodes_view_now_label') ?? localizations.new_episodes_view_now_label;

  String get settings_personalisation_divider_label =>
      message('settings_personalisation_divider_label') ?? localizations.settings_personalisation_divider_label;

  String get settings_episodes_divider_label =>
      message('settings_episodes_divider_label') ?? localizations.settings_episodes_divider_label;

  String get settings_playback_divider_label =>
      message('settings_playback_divider_label') ?? localizations.settings_playback_divider_label;

  String get settings_data_divider_label =>
      message('settings_data_divider_label') ?? localizations.settings_data_divider_label;

  String get audio_effect_trim_silence_label =>
      message('audio_effect_trim_silence_label') ?? localizations.audio_effect_trim_silence_label;

  String get audio_effect_volume_boost_label =>
      message('audio_effect_volume_boost_label') ?? localizations.audio_effect_volume_boost_label;

  String get audio_settings_playback_speed_label =>
      message('audio_settings_playback_speed_label') ?? localizations.audio_settings_playback_speed_label;

  String get sleep_episode_function_header =>
      message('sleep_episode_function_header') ?? localizations.sleep_episode_function_header;

  String get sleep_episode_function_turn_off =>
      message('sleep_episode_function_turn_off') ?? localizations.sleep_episode_function_turn_off;

  String get sleep_episode_function_toggled_on =>
      message('sleep_episode_function_toggled_on') ?? localizations.sleep_episode_function_toggled_on;

  String get sleep_episode_function_toggled_off =>
      message('sleep_episode_function_toggled_off') ?? localizations.sleep_episode_function_toggled_off;

  String get sleep_episode_function_end_of_episode =>
      message('sleep_episode_function_end_of_episode') ?? localizations.sleep_episode_function_end_of_episode;

  String get sleep_episode_function_5_minutes =>
      message('sleep_episode_function_5_minutes') ?? localizations.sleep_episode_function_5_minutes;

  String get sleep_episode_function_15_minutes =>
      message('sleep_episode_function_15_minutes') ?? localizations.sleep_episode_function_15_minutes;

  String get sleep_episode_function_30_minutes =>
      message('sleep_episode_function_30_minutes') ?? localizations.sleep_episode_function_30_minutes;

  String get sleep_episode_function_45_minutes =>
      message('sleep_episode_function_45_minutes') ?? localizations.sleep_episode_function_45_minutes;

  String get sleep_episode_function_60_minutes =>
      message('sleep_episode_function_60_minutes') ?? localizations.sleep_episode_function_60_minutes;

  String get empty_queue_message => message('empty_queue_message') ?? localizations.empty_queue_message;

  String get clear_queue_button_label => message('clear_queue_button_label') ?? localizations.clear_queue_button_label;

  String get now_playing_queue_label => message('now_playing_queue_label') ?? localizations.now_playing_queue_label;

  String get up_next_queue_label => message('up_next_queue_label') ?? localizations.up_next_queue_label;

  String get more_label => message('more_label') ?? localizations.more_label;

  String get queue_add_label => message('queue_add_label') ?? localizations.queue_add_label;

  String get queue_remove_label => message('queue_remove_label') ?? localizations.queue_remove_label;

  String get opml_import_button_label => message('opml_import_button_label') ?? localizations.opml_import_button_label;

  String get opml_export_button_label => message('opml_export_button_label') ?? localizations.opml_export_button_label;

  String get opml_import_export_label => message('opml_import_export_label') ?? localizations.opml_import_export_label;

  String get queue_clear_label => message('queue_clear_label') ?? localizations.queue_clear_label;

  String get queue_clear_button_label => message('queue_clear_button_label') ?? localizations.queue_clear_button_label;

  String get queue_clear_label_title => message('queue_clear_label_title') ?? localizations.queue_clear_label_title;

  String get layout_label => message('layout_label') ?? localizations.layout_label;

  String get proceed_button_label => message('proceed_button_label') ?? localizations.proceed_button_label;

  String get non_secure_connection_dialog_header =>
      message('non_secure_connection_dialog_header') ?? localizations.non_secure_connection_dialog_header;

  String get non_secure_connection_message =>
      message('non_secure_connection_message') ?? localizations.non_secure_connection_message;
}

class LocalisationsDelegate extends LocalizationsDelegate<L> {
  const LocalisationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<L> load(Locale locale) => SynchronousFuture<L>(L.load(locale, null));

  @override
  bool shouldReload(LocalisationsDelegate old) => false;
}

class EmbeddedLocalisationsDelegate extends LocalizationsDelegate<L> {
  Map<String, Map<String, String>>? messages = {};

  EmbeddedLocalisationsDelegate({@required this.messages});

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<L> load(Locale locale) => SynchronousFuture<L>(L.load(locale, messages));

  @override
  bool shouldReload(EmbeddedLocalisationsDelegate old) => false;
}
