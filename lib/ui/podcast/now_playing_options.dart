// Copyright 2020-2022 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:anytime/bloc/podcast/queue_bloc.dart';
import 'package:anytime/l10n/L.dart';
import 'package:anytime/state/queue_event_state.dart';
import 'package:anytime/ui/widgets/action_text.dart';
import 'package:anytime/ui/widgets/draggable_episode_tile.dart';
import 'package:anytime/ui/widgets/slider_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:provider/provider.dart';

class NowPlayingOptionsSelector extends StatefulWidget {
  final double scrollPos;
  final double baseSize;
  final bool isEmbedded;

  NowPlayingOptionsSelector({Key key, this.scrollPos, this.baseSize, this.isEmbedded}) : super(key: key);

  @override
  State<NowPlayingOptionsSelector> createState() => _NowPlayingOptionsSelectorState();
}

/// This class places a draggable scrollable sheet at the bottom of the page. Dragging the
/// sheep up will display additional options for playback which initially is the queue.
class _NowPlayingOptionsSelectorState extends State<NowPlayingOptionsSelector> {
  bool showContainer = false;
  double o = 0.0;

  @override
  Widget build(BuildContext context) {
    final queueBloc = Provider.of<QueueBloc>(context, listen: false);
    final topMargin = widget.baseSize + MediaQuery.of(context).viewPadding.top;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final floatingPlayerHeight = 64.0;
    final windowHeight = MediaQuery.of(context).size.height;
    final minSize = widget.baseSize / (windowHeight - widget.baseSize);
    final maxSize = (windowHeight - topMargin - (floatingPlayerHeight - widget.baseSize)) / windowHeight;
    final l10n = L.of(context);

    final ColorTween sheetColor = ColorTween(begin: theme.scaffoldBackgroundColor, end: theme.bottomAppBarColor);

    final ColorTween labelColor = ColorTween(
      begin: theme.primaryIconTheme.color,
      end: theme.iconTheme.color,
    );

    return DraggableScrollableSheet(
      initialChildSize: minSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      // Why does enabling snap stop the slider working altogether?
      // snap: true,
      // snapSizes: [minSize, maxSize],
      builder: (BuildContext context, ScrollController scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Material(
            color: theme.backgroundColor.withOpacity(widget.scrollPos > 0 ? 0 : 1),
            child: Container(
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: widget.isEmbedded ? theme.backgroundColor : theme.highlightColor,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0),
                  ),
                ),
                color: sheetColor.animate(AlwaysStoppedAnimation(widget.scrollPos)).value,
              ),
              height: MediaQuery.of(context).size.height -
                  floatingPlayerHeight -
                  MediaQuery.of(context).viewPadding.top -
                  (widget.isEmbedded ? 64.0 - 8.0 : 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: widget.baseSize,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SliderHandle(scrollPos: widget.scrollPos, isMinimized: widget.isEmbedded),
                        Padding(
                          padding: widget.isEmbedded ? EdgeInsets.zero : EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            l10n.up_next_queue_label.toUpperCase(),
                            style: textTheme.button.copyWith(
                              color: labelColor.animate(AlwaysStoppedAnimation(widget.scrollPos)).value,
                              fontSize: widget.isEmbedded ? 9 : textTheme.button.fontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: theme.highlightColor, height: 0),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 24.0, 8.0),
                        child: Text(
                          l10n.now_playing_queue_label,
                          style: textTheme.headline6.copyWith(color: theme.iconTheme.color),
                        ),
                      ),
                    ],
                  ),
                  StreamBuilder<QueueState>(
                    initialData: QueueEmptyState(),
                    stream: queueBloc.queue,
                    builder: (context, snapshot) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                        child: DraggableEpisodeTile(
                          key: Key('detileplaying'),
                          episode: snapshot.data.playing,
                          draggable: false,
                        ),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 24.0, 8.0),
                        child: Text(
                          l10n.up_next_queue_label,
                          style: textTheme.headline6.copyWith(color: theme.iconTheme.color),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 24.0, 8.0),
                        child: TextButton(
                          onPressed: () {
                            showPlatformDialog<void>(
                              context: context,
                              useRootNavigator: false,
                              builder: (_) => BasicDialogAlert(
                                title: Text(
                                  l10n.queue_clear_label_title,
                                ),
                                content: Text(l10n.queue_clear_label),
                                actions: <Widget>[
                                  BasicDialogAction(
                                    title: ActionText(
                                      l10n.cancel_button_label,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  BasicDialogAction(
                                    title: ActionText(
                                      theme.platform == TargetPlatform.iOS
                                          ? l10n.queue_clear_button_label.toUpperCase()
                                          : l10n.queue_clear_button_label,
                                    ),
                                    iosIsDefaultAction: true,
                                    iosIsDestructiveAction: true,
                                    onPressed: () {
                                      queueBloc.queueEvent(QueueClearEvent());
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            l10n.clear_queue_button_label,
                            style: textTheme.subtitle2.copyWith(fontSize: 12.0, color: theme.iconTheme.color),
                          ),
                        ),
                      ),
                    ],
                  ),
                  StreamBuilder<QueueState>(
                      initialData: QueueEmptyState(),
                      stream: queueBloc.queue,
                      builder: (context, snapshot) {
                        return snapshot.hasData && snapshot.data.queue.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: theme.dividerColor,
                                      border: Border.all(
                                        color: theme.dividerColor,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Text(
                                      l10n.empty_queue_message,
                                      style: textTheme.subtitle1.copyWith(color: theme.iconTheme.color),
                                    ),
                                  ),
                                ),
                              )
                            : Expanded(
                                child: ReorderableListView.builder(
                                  buildDefaultDragHandles: false,
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: snapshot.hasData ? snapshot.data.queue.length : 0,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Dismissible(
                                      key: ValueKey('disqueue${snapshot.data.queue[index].guid}'),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) {
                                        queueBloc.queueEvent(QueueRemoveEvent(episode: snapshot.data.queue[index]));
                                      },
                                      child: DraggableEpisodeTile(
                                        key: ValueKey('tilequeue${snapshot.data.queue[index].guid}'),
                                        index: index,
                                        episode: snapshot.data.queue[index],
                                      ),
                                    );
                                  },
                                  onReorder: (int oldIndex, int newIndex) {
                                    /// Seems odd to have to do this, but this -1 was taken from
                                    /// the Flutter docs.
                                    if (oldIndex < newIndex) {
                                      newIndex -= 1;
                                    }

                                    queueBloc.queueEvent(QueueMoveEvent(
                                      episode: snapshot.data.queue[oldIndex],
                                      oldIndex: oldIndex,
                                      newIndex: newIndex,
                                    ));
                                  },
                                ),
                              );
                      }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
