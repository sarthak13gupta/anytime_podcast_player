import 'package:anytime/entities/comment_model.dart';
import 'package:anytime/entities/episode.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

import 'comment_List.dart';
import 'comment_child.dart';

class EpisodeComments extends StatefulWidget {
  final Episode episode;
  EpisodeComments(this.episode, {Key key}) : super(key: key);

  @override
  State<EpisodeComments> createState() => _EpisodeCommentsState();
}

class _EpisodeCommentsState extends State<EpisodeComments> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  String labelText = "Write a comment...";
  List<CommentModel> rootUserdata = CommentModel.filedata;

  // RelayPoolApi relayPool = RelayPoolApi(relaysList: []);
  // final relaysList = [
  //   "wss://relay.damus.io",
  //   "wss://nostr1.tunnelsats.com",
  //   "wss://nostr-pub.wellorder.net",
  //   "wss://relay.nostr.info",
  //   "wss://nostr-relay.wlvs.space",
  //   "wss://nostr.bitcoiner.social",
  //   "wss://nostr-01.bolt.observer",
  //   "wss://relayer.fiatjaf.com",
  // ];

  @override
  void initState() {
    super.initState();

    // relayPool = RelayPoolApi(relaysList: relaysList);

    // connectToRelays();
  }

  @override
  void dispose() {
    // relayPool.close();
    super.dispose();
  }

  // void connectToRelays() async {
  //   // final Map<String, Map<String, bool>> relayList = {
  //   //   "wss://relay.damus.io": {"read": true, "write": true},
  //   //   "wss://nostr1.tunnelsats.com": {"read": true, "write": true},
  //   //   "wss://nostr-pub.wellorder.net": {"read": true, "write": true},
  //   //   "wss://relay.nostr.info": {"read": true, "write": true},
  //   //   "wss://nostr-relay.wlvs.space": {"read": true, "write": true},
  //   //   "wss://nostr.bitcoiner.social": {"read": true, "write": true},
  //   //   "wss://nostr-01.bolt.observer": {"read": true, "write": true},
  //   //   "wss://relayer.fiatjaf.com": {"read": true, "write": true},
  //   // };

  //   final stream = await relayPool.connect();

  //   relayPool.on((event) {
  //     if (event == RelayEvent.connect) {
  //       print('[+] connected to: ${relayPool.connectedRelays}');
  //     } else if (event == RelayEvent.error) {
  //       print('[!] failed to connect to: ${relayPool.failedRelays}');
  //     }
  //   });

  //   relayPool.sub([
  //     Filter(
  //       kinds: [1],
  //       limit: 10,
  //       since: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  //     )
  //   ]);

  //   await for (var message in stream) {
  //     if (message.type == 'Event') {
  //       Event event = message.message as Event;
  //       if (event.kind == 1) {
  //         var value = CommentModel(event.id, 'assets/icons/person.png',
  //             event.content, event.created_at as DateTime, '', event.id, false);

  //         rootUserdata.insert(0, value);
  //         CommentModel.filedata = rootUserdata;
  //       }
  //     }
  //   }

  //   stream.listen((Message message) {
  //     if (message.type == 'EVENT') {
  //       Event event = message.message as Event;
  //       print('[+] Received event: ${event.content}');
  //     }
  //   });
  // }

  String generateRandomId() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  Widget rootComment(List<CommentModel> data) {
    return ListView(
      children: data.map(
        (user) {
          return CommentChild(user);
        },
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Theme(
      data: themeData,
      child: CommentBox(
        userImage: CommentBox.commentImageParser(
          imageURLorPath: "assets/icons/person.png",
        ),
        labelText: labelText,
        errorText: 'Comment cannot be blank',
        withBorder: false,
        sendButtonMethod: () {
          if (formKey.currentState.validate()) {
            // Rest of your code

            setState(() {
              String id = generateRandomId();
              // var value = CommentModel(
              //   id,
              //   'assets/icons/person.png',
              //   commentController.text,
              //   DateTime.now(),
              //   '',
              //   id,
              //   false,
              // );

              // if (isReply) {
              //   value.replyTo = replyToId;
              //   if (rootUserReplies.containsKey(replyToId)) {
              //     rootUserReplies[replyToId]!.add(value);
              //   } else {
              //     rootUserReplies[replyToId] = [value];
              //   }
              // } else {

              // rootUserdata.insert(0, value);
              // CommentModel.filedata = rootUserdata;
              // }
            });
            commentController.clear();
            FocusScope.of(context).unfocus();
          } else {
            print("Not validated");
          }
        },
        formKey: formKey,
        commentController: commentController,
        backgroundColor: themeData.primaryColor,
        textColor: themeData.textTheme.titleMedium.color,
        sendWidget: Icon(
          Icons.send_sharp,
          size: 30,
          // color: themeData.primaryIconTheme.color,
        ),
        // child: rootComment(rootUserdata),
        child: CommentRender(),
      ),
      // ),
      //   ],
      // ),
    );
  }
}
