// Copyright 2020-2022 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:anytime/core/extensions.dart';
import 'package:anytime/entities/episode.dart';
import 'package:anytime/entities/podcast.dart';
import 'package:anytime/entities/queue.dart';
import 'package:anytime/repository/repository.dart';
import 'package:anytime/repository/sembast/sembast_database_service.dart';
import 'package:anytime/state/episode_state.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast.dart';

/// An implementation of [Repository] that is backed by Sembast.
class SembastRepository extends Repository {
  final log = Logger('SembastRepository');

  final _podcastSubject = BehaviorSubject<Podcast?>();
  final _episodeSubject = BehaviorSubject<EpisodeState>();

  final _podcastStore = intMapStoreFactory.store('podcast');
  final StoreRef<int?, Map<String, Object?>> _episodeStore = intMapStoreFactory.store('episode');
  final _queueStore = intMapStoreFactory.store('queue');

  final _queueGuids = <String?>[];

  late DatabaseService _databaseService;

  Future<Database> get _db async => _databaseService.database;

  final StreamController<bool> _backupDatabaseController = StreamController<bool>.broadcast();
  final StreamController<bool> _reloadDatabaseController = StreamController<bool>.broadcast();

  SembastRepository({
    bool cleanup = true,
    String databaseName = 'anytime.db',
  }) {
    _databaseService = DatabaseService(databaseName);
    _listenReloadDBRequests();

    if (cleanup) {
      _deleteOrphanedEpisodes().then((value) {
        log.fine('Orphan episodes cleanup complete');
      });
    }
  }

  /// Saves the [Podcast] instance and associated [Episode]s. Podcasts are
  /// only stored when we subscribe to them, so at the point we store a
  /// new podcast we store the current [DateTime] to mark the
  /// subscription date.
  @override
  Future<Podcast?> savePodcast(Podcast? podcast) async {
    log.fine('Saving podcast ${podcast!.url}');

    final finder = Finder(filter: Filter.equals('guid', podcast.guid));
    final RecordSnapshot<int, Map<String, Object?>>? snapshot = await _podcastStore.findFirst(await _db, finder: finder);

    podcast.lastUpdated = DateTime.now();

    if (snapshot == null) {
      podcast.subscribedDate = DateTime.now();
      podcast.id = await _podcastStore.add(await _db, podcast.toMap());
    } else {
      await _podcastStore.update(await _db, podcast.toMap(), finder: finder);
    }

    await _saveEpisodes(podcast.episodes);

    _podcastSubject.add(podcast);

    return podcast;
  }

  @override
  Future<List<Podcast>> subscriptions() async {
    final finder = Finder(sortOrders: [
      SortOrder('title'),
    ]);

    final List<RecordSnapshot<int, Map<String, Object?>>> subscriptionSnapshot = await _podcastStore.find(
      await _db,
      finder: finder,
    );

    final subs = subscriptionSnapshot.map((snapshot) {
      final subscription = Podcast.fromMap(snapshot.key, snapshot.value);

      return subscription;
    }).toList();

    return subs;
  }

  @override
  Future<void> deletePodcast(Podcast? podcast) async {
    final db = await _db;

    await db.transaction((txn) async {
      final podcastFinder = Finder(filter: Filter.byKey(podcast!.id));
      final episodeFinder = Finder(filter: Filter.equals('pguid', podcast.guid));

      await _podcastStore.delete(
        txn,
        finder: podcastFinder,
      );

      await _episodeStore.delete(
        txn,
        finder: episodeFinder,
      );
    });
  }

  @override
  Future<Podcast?> findPodcastById(num? id) async {
    final finder = Finder(filter: Filter.byKey(id));

    final RecordSnapshot<int, Map<String, Object?>>? snapshot = await _podcastStore.findFirst(await _db, finder: finder);

    if (snapshot != null) {
      var p = Podcast.fromMap(snapshot.key, snapshot.value);

      // Now attach all episodes for this podcast
      p.episodes = await findEpisodesByPodcastGuid(p.guid);

      return p;
    }

    return null;
  }

  @override
  Future<Podcast?> findPodcastByGuid(String? guid) async {
    final finder = Finder(filter: Filter.equals('guid', guid));

    final RecordSnapshot<int, Map<String, Object?>>? snapshot = await _podcastStore.findFirst(await _db, finder: finder);

    if (snapshot != null) {
      var p = Podcast.fromMap(snapshot.key, snapshot.value);

      // Now attach all episodes for this podcast
      p.episodes = await findEpisodesByPodcastGuid(p.guid);

      return p;
    }

    return null;
  }

  @override
  Future<List<Episode>> findAllEpisodes() async {
    final finder = Finder(
      sortOrders: [SortOrder('publicationDate', false)],
    );

    final List<RecordSnapshot<int?, Map<String, Object?>>> recordSnapshots = await _episodeStore.find(await _db, finder: finder);

    final results = recordSnapshots.map((snapshot) {
      final episode = Episode.fromMap(snapshot.key, snapshot.value);

      return episode;
    }).toList();

    return results;
  }

  @override
  Future<Episode?> findEpisodeById(int? id) async {
    final Map<String, Object?>? snapshot = await _episodeStore.record(id).get(await _db);

    return snapshot == null ? null : Episode.fromMap(id, snapshot);
  }

  @override
  Future<Episode?> findEpisodeByGuid(String? guid) async {
    final finder = Finder(filter: Filter.equals('guid', guid));

    final RecordSnapshot<int?, Map<String, Object?>>? snapshot = await _episodeStore.findFirst(await _db, finder: finder);

    return snapshot == null ? null : Episode.fromMap(snapshot.key, snapshot.value);
  }

  @override
  Future<List<Episode>> findEpisodesByPodcastGuid(String? pguid) async {
    final finder = Finder(
      filter: Filter.equals('pguid', pguid),
      sortOrders: [SortOrder('publicationDate', false)],
    );

    final List<RecordSnapshot<int?, Map<String, Object?>>> recordSnapshots = await _episodeStore.find(await _db, finder: finder);

    final results = recordSnapshots.map((snapshot) {
      final episode = Episode.fromMap(snapshot.key, snapshot.value);

      return episode;
    }).toList();

    return results;
  }

  @override
  Future<List<Episode>> findDownloadsByPodcastGuid(String? pguid) async {
    final finder = Finder(
      filter: Filter.and([
        Filter.equals('pguid', pguid),
        Filter.equals('downloadPercentage', '100'),
      ]),
      sortOrders: [SortOrder('publicationDate', false)],
    );

    final List<RecordSnapshot<int?, Map<String, Object?>>> recordSnapshots = await _episodeStore.find(await _db, finder: finder);

    final results = recordSnapshots.map((snapshot) {
      final episode = Episode.fromMap(snapshot.key, snapshot.value);

      return episode;
    }).toList();

    return results;
  }

  @override
  Future<List<Episode>> findDownloads() async {
    final finder =
        Finder(filter: Filter.equals('downloadPercentage', '100'), sortOrders: [SortOrder('publicationDate', false)]);

    final List<RecordSnapshot<int?, Map<String, Object?>>> recordSnapshots = await _episodeStore.find(await _db, finder: finder);

    final results = recordSnapshots.map((snapshot) {
      final episode = Episode.fromMap(snapshot.key, snapshot.value);

      return episode;
    }).toList();

    return results;
  }

  @override
  Future<void> deleteEpisode(Episode episode) async {
    final finder = Finder(filter: Filter.byKey(episode.id));

    final RecordSnapshot<int?, Map<String, Object?>>? snapshot = await _episodeStore.findFirst(await _db, finder: finder);

    if (snapshot == null) {
      // Oops!
    } else {
      await _episodeStore.delete(await _db, finder: finder);
      _episodeSubject.add(EpisodeDeleteState(episode));
    }
  }

  @override
  Future<void> deleteEpisodes(List<Episode> episodes) async {
    var d = await _db;

    if (episodes.isNotEmpty) {
      for (var chunk in episodes.chunk(100)) {
        await d.transaction((txn) async {
          var futures = <Future<int>>[];

          for (var episode in chunk) {
            final finder = Finder(filter: Filter.byKey(episode.id));

            futures.add(_episodeStore.delete(txn, finder: finder));
          }

          if (futures.isNotEmpty) {
            await Future.wait(futures);
          }
        });
      }
    }
  }

  @override
  Future<Episode> saveEpisode(Episode? episode, [bool? updateIfSame = false]) async {
    var e = await _saveEpisode(episode!, updateIfSame);

    _episodeSubject.add(EpisodeUpdateState(e));

    return e;
  }

  @override
  Future<List<Episode?>> loadQueue() async {
    var episodes = <Episode?>[];

    final RecordSnapshot<int, Map<String, Object?>>? snapshot = await _queueStore.record(1).getSnapshot(await _db);

    if (snapshot != null) {
      var queue = Queue.fromMap(snapshot.key, snapshot.value);

      var episodeFinder = Finder(filter: Filter.inList('guid', queue.guids as List<Object>));

      final List<RecordSnapshot<int?, Map<String, Object?>>> recordSnapshots = await _episodeStore.find(await _db, finder: episodeFinder);

      episodes = recordSnapshots.map((snapshot) {
        final episode = Episode.fromMap(snapshot.key, snapshot.value);

        return episode;
      }).toList();
    }

    return episodes;
  }

  @override
  Future<void> saveQueue(List<Episode?> episodes) async {
    for (var e in episodes) {
      if (e!.pguid == null || e.pguid!.isEmpty) {
        _saveEpisode(e, false);
      }
    }

    var guids = episodes.map((e) => e!.guid).toList();

    /// Only bother saving if the queue has changed
    if (!listEquals(guids, _queueGuids)) {
      final queue = Queue(guids: guids);

      await _queueStore.record(1).put(await _db, queue.toMap());

      _queueGuids.clear();
      _queueGuids.addAll(guids);
    }
  }

  Future<void> _deleteOrphanedEpisodes() async {
    final threshold = DateTime.now().subtract(Duration(days: 60)).millisecondsSinceEpoch;

    final filter = Filter.and([
      Filter.equals('downloadState', 0),
      Filter.lessThan('lastUpdated', threshold),
    ]);

    final orphaned = <Episode>[];
    final pguids = <String?>[];
    final List<RecordSnapshot<int?, Map<String, Object?>>> episodes = await _episodeStore.find(await _db, finder: Finder(filter: filter));

    // First, find all podcasts
    for (var podcast in await _podcastStore.find(await _db)) {
      pguids.add(podcast.value['guid'] as String?);
    }

    for (var episode in episodes) {
      final pguid = episode.value['pguid'] as String?;
      final podcast = pguids.contains(pguid);

      if (!podcast) {
        orphaned.add(Episode.fromMap(episode.key, episode.value));
      }
    }

    await deleteEpisodes(orphaned);
  }

  /// Saves a list of episodes to the repository. To improve performance we
  /// split the episodes into chunks of 100 and save any that have been updated
  /// in that chunk in a single transaction.
  Future<void> _saveEpisodes(List<Episode>? episodes) async {
    var d = await _db;
    var dateStamp = DateTime.now();

    if (episodes != null && episodes.isNotEmpty) {
      for (var chunk in episodes.chunk(100)) {
        await d.transaction((txn) async {
          var futures = <Future<int>>[];

          for (var episode in chunk) {
            episode.lastUpdated = dateStamp;

            if (episode.id == null) {
              futures.add(_episodeStore.add(txn, episode.toMap()).then((id) => (episode.id = id)!));
            } else {
              final finder = Finder(filter: Filter.byKey(episode.id));

              var existingEpisode = await findEpisodeById(episode.id);

              if (existingEpisode == null || existingEpisode != episode) {
                futures.add(_episodeStore.update(txn, episode.toMap(), finder: finder));
              }
            }
          }

          if (futures.isNotEmpty) {
            await Future.wait(futures);
          }
        });
      }
    }
  }

  Future<Episode> _saveEpisode(Episode episode, bool? updateIfSame) async {
    final finder = Finder(filter: Filter.byKey(episode.id));

    final RecordSnapshot<int?, Map<String, Object?>>? snapshot = await _episodeStore.findFirst(await _db, finder: finder);

    if (snapshot == null) {
      episode.lastUpdated = DateTime.now();
      episode.id = await _episodeStore.add(await _db, episode.toMap());
    } else {
      var e = Episode.fromMap(episode.id, snapshot.value);
      episode.lastUpdated = DateTime.now();

      if (updateIfSame! || episode != e) {
        await _episodeStore.update(await _db, episode.toMap(), finder: finder);
      }
    }

    return episode;
  }

  @override
  Future<Episode?> findEpisodeByTaskId(String? taskId) async {
    final finder = Finder(filter: Filter.equals('downloadTaskId', taskId));
    final RecordSnapshot<int?, Map<String, Object?>>? snapshot = await _episodeStore.findFirst(await _db, finder: finder);

    return snapshot == null ? null : Episode.fromMap(snapshot.key, snapshot.value);
  }

  @override
  Future<void> close() async {
    final d = await _db;

    await d.close();
  }

  void _listenReloadDBRequests() {
    _reloadDatabaseController.stream.listen((event) async => await _databaseService.reloadDatabase());
  }

  @override
  Stream<EpisodeState> get episodeListener => _episodeSubject.stream;

  @override
  Stream<Podcast?> get podcastListener => _podcastSubject.stream;

  @override
  Stream<bool> get backupDatabaseListener => _backupDatabaseController.stream;

  @override
  Sink<bool> get backupDatabaseSink => _backupDatabaseController.sink;

  @override
  Sink<bool> get reloadDatabaseSink => _reloadDatabaseController.sink;
}
