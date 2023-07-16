import 'package:anytime/entities/comment_model.dart';
import 'package:anytime/entities/episode.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:flutter/material.dart';
import 'package:nostr_tools/nostr_tools.dart';
import 'package:provider/provider.dart';

import '../../bloc/comments/comments_bloc.dart';
import 'comment_list.dart';
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
  String labelText = "Add a comment...";
  List<CommentModel> rootUserdata = CommentModel.filedata;

  final FocusNode _textFieldFocusNode = FocusNode();

  CommentBloc commentBloc;

  @override
  void initState() {
    super.initState();
    commentBloc = Provider.of<CommentBloc>(context, listen: false);
    commentBloc.init();
  }

  @override
  void dispose() {
    super.dispose();
    _textFieldFocusNode.dispose();
  }

  void _createComment() {
    final List<Event> events = commentBloc.events;
    // also re loading the messages.
    // call create comment method inside the comments_Bloc\

    // first check whether this is the first comment

    if (commentBloc.isRootEventPresent == false) {
      setState(() {
        commentBloc.createRootEvent();
        commentBloc.createComment(commentController.text.trim());
      });
    } else {
      setState(() {
        commentBloc.createComment(commentController.text.trim());
      });
    }
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
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            _textFieldFocusNode.unfocus();
          }
        },
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
              _createComment();
              commentController.clear();
              FocusScope.of(context).unfocus();
            } else {
              formKey.currentState.setState(() {});
            }
          },
          focusNode: _textFieldFocusNode,
          formKey: formKey,
          commentController: commentController,
          // textColor: themeData.textTheme.titleMedium.color,
          sendWidget: _textFieldFocusNode.hasFocus
              ? Icon(
                  Icons.send,
                  size: 30,
                )
              : SizedBox.shrink(),
          child: CommentRender(
            commentBloc: commentBloc,
          ),
        ),
      ),
    );
  }
}
