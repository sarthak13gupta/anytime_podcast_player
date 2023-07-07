import 'dart:convert';

import 'package:anytime/entities/comment_model.dart';
import 'package:anytime/ui/podcast/comment_child.dart';
import 'package:flutter/material.dart';

import 'package:nostr_tools/nostr_tools.dart';

import '../../entities/time_ago.dart';

class CommentRender extends StatefulWidget {
  const CommentRender({Key key}) : super(key: key);

  @override
  State<CommentRender> createState() => _CommentRenderState();
}

class _CommentRenderState extends State<CommentRender> {
  final relaysList = [
    "wss://relay.damus.io",
    // "wss://nostr1.tunnelsats.com",
    // "wss://nostr-pub.wellorder.net",
    // "wss://relay.nostr.info",
    // "wss://nostr-relay.wlvs.space",
    // "wss://nostr.bitcoiner.social",
    // "wss://nostr-01.bolt.observer",
    // "wss://relayer.fiatjaf.com",
  ];

  bool _isConnected = false;
  final _relayPool = RelayApi(relayUrl: 'wss://relay.damus.io');
  // RelayPoolApi _relayPool = RelayPoolApi(relaysList: []);

  final List<Event> _events = [];
  final Map<String, Metadata> _metaDatas = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _relayPool.close();
    super.dispose();
  }

  Stream get relayStream async* {
    final stream = await _relayPool.connect();

    _relayPool.on((event) {
      if (event == RelayEvent.connect) {
        setState(() => _isConnected = true);
      } else if (event == RelayEvent.error) {
        setState(() => _isConnected = false);
      }
    });

    _relayPool.sub([
      Filter(
        kinds: [1],
        limit: 100,
      )
    ]);

    await for (var message in stream) {
      if (message.type == 'EVENT') {
        Event event = message.message as Event;

        if (event.kind == 1) {
          _events.add(event);
          _relayPool.sub([
            Filter(kinds: [0], authors: [event.pubkey])
          ]);
        } else if (event.kind == 0) {
          Metadata metadata = Metadata.fromJson(
              jsonDecode(event.content) as Map<String, dynamic>);
          _metaDatas[event.pubkey] = metadata;
        }
      }
      yield message;
    }
  }

  @override
  Widget build(BuildContext context) {
    // _relayPool = RelayPoolApi(relaysList: relaysList);

    return StreamBuilder<dynamic>(
      stream: relayStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              final metadata = _metaDatas[event.pubkey];
              final userRootComment = CommentModel(
                  metadata?.displayName ??
                      (metadata?.display_name ?? event.pubkey),
                  metadata?.picture ?? 'assets/icons/person.png',
                  event.content,
                  TimeAgo.format(event.created_at),
                  '',
                  event.id,
                  false);

              return CommentChild(userRootComment);
            },
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text('Loading....'));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return Container(); // Return a default widget in case none of the conditions match
      },
    );
  }
}
