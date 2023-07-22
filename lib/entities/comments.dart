import 'package:nostr_tools/nostr_tools.dart';

class CommentModel {
  String userName;
  String userPic;
  String userMessage;
  String date;
  String replyTo;
  String id;
  bool showReplies;
  CommentModel({
    this.userName,
    this.userPic,
    this.userMessage,
    this.date,
    this.replyTo,
    this.id,
    this.showReplies,
  });
}

class CommentEvent {
  static Event mapToEvent(Map<String, dynamic> comment) {
    return Event(
      kind: comment['kind'] as int,
      tags: comment['tags'] as List<List<String>>,
      content: comment['content'] as String,
      created_at: comment['created_at'] as int,
      id: comment['id'] as String,
      sig: comment['sig'] as String,
      pubkey: comment['pubkey'] as String,
    );
  }
}
