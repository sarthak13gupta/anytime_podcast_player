class CommentAction {}

/// Events
class CreateRootComment extends CommentAction {
  final String userComment;
  CreateRootComment(this.userComment);
}

class CreateReplyComment extends CommentAction {
  final String userComment;
  CreateReplyComment(this.userComment);
}

class ReloadConnection extends CommentAction {
  ReloadConnection();
}

class GetUserPubKey extends CommentAction {
  GetUserPubKey();
}

class Login extends CommentAction {
  Login();
}

/// State
class CommentLoadingState extends CommentAction {}
