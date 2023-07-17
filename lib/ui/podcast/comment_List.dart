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

    // to make sure relay is reconnected on disconnection
    // widget.commentBloc.isConnectedStream.listen((event) {
    //   _connectRelay();
    // });
  }

  void _init() {
    _events = widget.commentBloc.events;
    _metaDatas = widget.commentBloc.metaDatas;
  }

  void _setCommentListener() {
    widget.commentBloc.eventStream.listen((Event event) {
      setState(() {
        _events = widget.commentBloc.events;
        _metaDatas = widget.commentBloc.metaDatas;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Event>(
      stream: widget.commentBloc.eventStream,
      builder: (context, snapshot) {
        if (_events.isNotEmpty) {
          return ListView.builder(
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              final metadata = _metaDatas[event.pubkey];
              final userRootComment = CommentModel(
                  metadata?.displayName ??
                      (metadata?.display_name ??
                          Nip19().npubEncode(event.pubkey).substring(0, 11)),
                  metadata?.picture ?? 'assets/icons/person.png',
                  event.content,
                  TimeAgo.format(event.created_at),
                  '',
                  event.id,
                  false);

              return CommentChild(userRootComment);
            },
          );
          // }
          // else if (snapshot.connectionState == ConnectionState.waiting &&
          //     _events.isNotEmpty) {
          //   return const Center(child: Text('Loading....'));
        } else if (_events.isEmpty) {
          return const Center(child: Text('No Comments Made...'));
        }
        // else if (snapshot.hasError) {
        //   return Center(child: Text('Error: ${snapshot.error}'));
        // }
        else {
          return DelayedCircularProgressIndicator();
        }
        return Container(); // Return a default widget in case none of the conditions match
      },
    );
  }
}
