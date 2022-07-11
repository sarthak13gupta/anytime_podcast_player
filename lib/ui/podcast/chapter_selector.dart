// Copyright 2020-2022 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:anytime/bloc/podcast/audio_bloc.dart';
import 'package:anytime/entities/chapter.dart';
import 'package:anytime/entities/episode.dart';
import 'package:anytime/ui/widgets/platform_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// A [Widget] for displaying a list of Podcast chapters for those
/// podcasts that support that chapter tag.
// ignore: must_be_immutable
class ChapterSelector extends StatefulWidget {
  final ItemScrollController itemScrollController = ItemScrollController();
  Episode episode;
  Chapter chapter;
  StreamSubscription positionSubscription;
  var chapters = <Chapter>[];

  ChapterSelector({
    this.episode,
  }) {
    if (episode.chapters != null) {
      chapters = episode.chapters.where((c) => c.toc).toList(growable: false);
    }
  }

  @override
  State<ChapterSelector> createState() => _ChapterSelectorState();
}

class _ChapterSelectorState extends State<ChapterSelector> {
  @override
  void initState() {
    super.initState();

    final audioBloc = Provider.of<AudioBloc>(context, listen: false);
    Chapter lastChapter;

    // Listen for changes in position. If the change in position results in
    // a change in chapter we scroll to it. This ensures that the current
    // chapter is always visible.
    // TODO: Jump only if current chapter is not visible.
    widget.positionSubscription = audioBloc.playPosition.listen((event) {
      var episode = event.episode;

      if (widget.itemScrollController.isAttached) {
        lastChapter ??= episode.currentChapter;

        if (lastChapter != episode.currentChapter) {
          lastChapter = episode.currentChapter;

          if (!episode.chaptersLoading && episode.chapters.isNotEmpty) {
            var index = widget.episode.chapters.indexWhere((element) => element == lastChapter);

            if (index >= 0) {
              widget.itemScrollController.scrollTo(index: index, duration: Duration(milliseconds: 250));
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioBloc = Provider.of<AudioBloc>(context);

    return StreamBuilder<Episode>(
        stream: audioBloc.nowPlaying,
        builder: (context, snapshot) {
          return !snapshot.hasData || snapshot.data.chaptersLoading
              ? Align(
                  alignment: Alignment.center,
                  child: PlatformProgressIndicator(),
                )
              : ScrollablePositionedList.builder(
                  initialScrollIndex: _initialIndex(snapshot.data),
                  itemScrollController: widget.itemScrollController,
                  itemCount: snapshot.data.chapters.length,
                  itemBuilder: (context, i) {
                    final index = i < 0 ? 0 : i;
                    final chapter = snapshot.data.chapters[index];
                    final chapterSelected = chapter == snapshot.data.currentChapter;
                    final textStyle = Theme.of(context).textTheme.bodyText1.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSecondary,
                        );

                    /// We should be able to use the selectedTileColor property but, if we do, when
                    /// we scroll the currently selected item out of view, the selected colour is
                    /// still visible behind the transport control. This is a little hack, but fixes
                    /// the issue until I can get ListTile to work correctly.
                    return Container(
                      color: chapterSelected ? Theme.of(context).selectedRowColor : Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                        child: ListTile(
                          onTap: () {
                            audioBloc.transitionPosition(chapter.startTime.toDouble());
                          },
                          selected: chapterSelected,
                          // selectedTileColor: Theme.of(context).selectedRowColor,
                          // tileColor: Colors.pink,
                          leading: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              '${index + 1}.',
                              style: textStyle,
                            ),
                          ),
                          title: Text(
                            snapshot.data.chapters[index].title?.trim(),
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 3,
                            style: textStyle,
                          ),
                          trailing: Text(
                            _formatStartTime(snapshot.data.chapters[index].startTime),
                            style: textStyle,
                          ),
                        ),
                      ),
                    );
                  },
                );
        });
  }

  @override
  void dispose() {
    widget.positionSubscription?.cancel();
    super.dispose();
  }

  int _initialIndex(Episode e) {
    var init = 0;

    if (e != null && e.currentChapter != null) {
      init = e.chapters.indexWhere((c) => c == e.currentChapter);

      if (init < 0) {
        init = 0;
      }
    }

    return init;
  }

  String _formatStartTime(double startTime) {
    var time = Duration(seconds: startTime.ceil());
    var result = '';

    if (time.inHours > 0) {
      result =
          '${time.inHours}:${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${time.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    } else {
      result = '${time.inMinutes}:${time.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }

    return result;
  }
}
