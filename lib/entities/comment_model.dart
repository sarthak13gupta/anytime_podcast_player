class CommentModel {
  String userName;
  String userPic;
  String userMessage;
  String date;
  String replyTo;
  String id;
  bool showReplies;
  CommentModel(
    this.userName,
    this.userPic,
    this.userMessage,
    this.date,
    this.replyTo,
    this.id,
    this.showReplies,
  );

  static Map<String, List<CommentModel>> threadedReplies = {};
  static bool isreply = false;
  static String labelText = "Write a comment...";
  static String replyToId = "";

  static List<CommentModel> filedata = [];

  static void replyToUserComment(CommentModel userRootComment) {
    // userRootComment.showReplies = !userRootComment.showReplies;

    // reply to root comment
    isreply = !isreply;
    if (isreply) {
      replyToId = userRootComment.id;
      labelText = "reply to ${userRootComment.userName}";
    } else {
      labelText = "Write a comment...";
      replyToId = "";
    }
  }

  // static Widget userCommentTreeWidget(
  //     CommentModel user, Function updateReplyData, Function updateCommentRender) {
  //   final userRootComment = Comment(
  //     avatar: user.userPic,
  //     userName: user.userName,
  //     content: user.userMessage,
  //   );

  //   List<Comment> userChildComment = formUserChildCommentList(user.id);

  //   return CommentsThread(user, userRootComment, userChildComment,
  //       updateReplyData, updateCommentRender);
  // }

  // static List<Comment> formUserChildCommentList(String rootId) {
  //   List<CommentModel>? userCommentRepliesList = threadedReplies[rootId];

  //   if (userCommentRepliesList == null) return <Comment>[];

  //   List<Comment> userChildCommentList =
  //       userCommentRepliesList.map((userChild) {
  //     return Comment(
  //         avatar: userChild.userPic,
  //         userName: userChild.userName,
  //         content: userChild.userMessage);
  //   }).toList();

  // return userChildCommentList;
}
