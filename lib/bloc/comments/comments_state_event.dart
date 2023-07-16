import 'package:anytime/entities/comment_model.dart';

class CommentEvent {}

/// Events
class CreateCommentEvent extends CommentEvent {
  final CommentModel comment;
  CreateCommentEvent(this.comment);
}

class ConnectRelayPoolEvent extends CommentEvent {
  final List<String> relayList;
  ConnectRelayPoolEvent(this.relayList);
}

class GetPubKeyEvent extends CommentEvent {
  GetPubKeyEvent();
}

class SignCommentEvent extends CommentEvent {
  final Map<String, dynamic> event;
  SignCommentEvent(this.event);
}

class PublishCommentEvent extends CommentEvent {
  final Map<String, dynamic> event;
  PublishCommentEvent(this.event);
}

/// State
class CommentLoadingState extends CommentEvent {}
