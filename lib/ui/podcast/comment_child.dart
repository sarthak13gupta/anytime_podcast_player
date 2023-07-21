import 'package:anytime/ui/podcast/episode_comment_box.dart';
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

  Widget _placeholderImage(ThemeData themeData) {
    if (widget.userRootComment.userPic != null) {
      return CircleAvatar(
        // foregroundColor: Colors.white,
        radius: 30,
        backgroundImage: CommentBox.commentImageParser(
            imageURLorPath: widget.userRootComment.userPic),
      );
    }

    return CircleAvatar(
      // foregroundColor: Colors.white,
      radius: 30,
      child: Icon(
        Icons.person,
        color: themeData.iconTheme.color,
      ),
    );
  }

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
                height: 35.0,
                width: 35.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: _placeholderImage(themeData),
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
