import 'package:anytime/bloc/comments/comments_bloc.dart';
import 'package:anytime/entities/comment_model.dart';
import 'package:anytime/ui/podcast/comment_child.dart';
import 'package:flutter/material.dart';

import 'package:nostr_tools/nostr_tools.dart';

import '../../entities/time_ago.dart';
import '../widgets/delayed_progress_indicator.dart';

class CommentRender extends StatefulWidget {
  final CommentBloc commentBloc;
  const CommentRender({Key key, this.commentBloc}) : super(key: key);

  @override
  State<CommentRender> createState() => _CommentRenderState();
}

class _CommentRenderState extends State<CommentRender> {
  List<Event> _events = [];
  Map<String, Metadata> _metaDatas = {};

  Stream<Event> relayStream;

  @override
  void initState() {
    super.initState();
    _init();
    _setCommentListener();
  }

  void _init() {
    _events = widget.commentBloc.sortedEvents;
    _metaDatas = widget.commentBloc.metaDatas;
  }

  void _setCommentListener() {
    widget.commentBloc.eventStream.listen((Event event) {
      setState(() {
        _events = widget.commentBloc.sortedEvents;
        _metaDatas = widget.commentBloc.metaDatas;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Event>(
      stream: widget.commentBloc.eventStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_events.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      final metadata = _metaDatas[event.pubkey];
                      final userRootComment = CommentModel(
                          metadata?.displayName ??
                              (metadata?.display_name ??
                                  Nip19()
                                      .npubEncode(event.pubkey)
                                      .substring(0, 11)),
                          metadata?.picture,
                          event.content,
                          TimeAgo.format(event.created_at),
                          '',
                          event.id,
                          false);

                      return CommentChild(userRootComment);
                    },
                  ),
                ),
              SizedBox(
                height: 10,
              ),
              DelayedCircularProgressIndicator(),
            ],
          );
        }
        if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              final metadata = _metaDatas[event.pubkey];
              final userRootComment = CommentModel(
                  metadata?.displayName ??
                      (metadata?.display_name ??
                          Nip19().npubEncode(event.pubkey).substring(0, 11)),
                  metadata?.picture,
                  event.content,
                  TimeAgo.format(event.created_at),
                  '',
                  event.id,
                  false);

              return CommentChild(userRootComment);
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('${snapshot.error}'),
          );
        } else {
          return DelayedCircularProgressIndicator();
        }
      },
    );
  }
}
