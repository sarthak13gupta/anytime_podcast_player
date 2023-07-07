import 'package:comment_box/comment/comment.dart';
// import 'package:commentsplatform/commentsPage.dart';
// import 'package:commentsplatform/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';

import '../../entities/comment_model.dart';

class CommentChild extends StatefulWidget {
  CommentModel userRootComment;
  // Function updateReplyData;
  // CommentChild(this.userRootComment, this.updateReplyData, {super.key});

  CommentChild(this.userRootComment);

  @override
  State<CommentChild> createState() => _CommentChildState();
}

class _CommentChildState extends State<CommentChild> {
  Widget userCommentTree = Container();
  // Map<String, List<CommentModel>> rootUserReplies = CommentModel.threadedReplies;

  void updateCommentRender() {
    setState(() {
      // widget.userRootComment.showReplies = !widget.userRootComment.showReplies;
    });
  }

  // void renderCommentTree(CommentModel data) {
  //   setState(() {
  //     // CommentModel user;
  //     data.showReplies = !data.showReplies;
  //     if (data.showReplies) {
  //       userCommentTree = CommentModel.userCommentTreeWidget(
  //           data, widget.updateReplyData, updateCommentRender);
  //     }

  //     // widget.updateReplyData();
  //   });
  // }

  // Text dateTimeFormat(DateTime date) {
  //   DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
  //   String dateTime = dateFormat.format(date);

  //   return Text(dateTime);
  // }

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

            // Padding(
            //     padding:const EdgeInsets.symmetric(horizontal: 16, vertical: 8),,
            //     child:Text(
            //       widget.userRootComment.userMessage,
            //       style: themeData.primaryTextTheme.bodyLarge, ,
            //   ),
            // DefaultTextStyle(
            // style: Theme.of(context).textTheme.caption.copyWith(
            //     color: Colors.grey[700], fontWeight: FontWeight.bold),
            // child:
            // Padding(
            //   padding: const EdgeInsets.only(top: 4, left: 20),
            //   child: Row(
            //     children: [
            //       const SizedBox(
            //         width: 8,
            //       ),
            //       GestureDetector(onTap: () {}, child: const Text('Like')),
            //       const SizedBox(
            //         width: 24,
            //       ),
            //       GestureDetector(
            //           onTap: () {
            //             // setState(() {
            //             //   CommentModel.replyToUserComment(widget.userRootComment);
            //             //   widget.updateReplyData();
            //             // });
            //           },
            //           child: const Text('Reply')),
            //     ],
            //   ),
            // ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return rootCommentWidget(context);
    // print(
    //     'widget.userRootComment.showReplies: ${widget.userRootComment.showReplies}');
    // return widget.userRootComment.showReplies
    //     ? userCommentTree
    //     : rootCommentWidget(context);
  }
}
