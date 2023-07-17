import 'package:comment_box/comment/comment.dart';
// import 'package:commentsplatform/commentsPage.dart';
// import 'package:commentsplatform/user_model.dart';
import 'package:flutter/material.dart';

import '../../entities/comment_model.dart';

class CommentChild extends StatefulWidget {
  final CommentModel userRootComment;

  CommentChild(this.userRootComment);

  @override
  State<CommentChild> createState() => _CommentChildState();
}

class _CommentChildState extends State<CommentChild> {
  Widget userCommentTree = Container();

  Widget rootCommentWidget(BuildContext context) {
    final themeData = Theme.of(context);

    return Theme(
      data: themeData,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: CircleAvatar(
                    foregroundColor: Colors.white,
                    radius: 50,
                    backgroundImage: CommentBox.commentImageParser(
                        imageURLorPath: widget.userRootComment.userPic)),
              ),
              title: Text(
                '@${widget.userRootComment.userName} • ${widget.userRootComment.date}',
                style: themeData.primaryTextTheme.bodySmall,
              ),
              subtitle: Text(
                widget.userRootComment.userMessage,
                style: themeData.primaryTextTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return rootCommentWidget(context);
  }
}
