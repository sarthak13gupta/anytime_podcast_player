import 'package:anytime/bloc/comments/comments_state_event.dart';
import 'package:anytime/entities/comments.dart';
import 'package:anytime/entities/episode.dart';
import 'package:anytime/ui/podcast/episode_comment_box.dart';
import 'package:flutter/material.dart';
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
  String hintText = "Add a comment...";

  final FocusNode _textFieldFocusNode = FocusNode();

  CommentBloc commentBloc;

  @override
  void initState() {
    super.initState();
    commentBloc = Provider.of<CommentBloc>(context, listen: false);
    init();
  }

  void init() {
    // getting the pubkey is necessary because we need to create the key pair
    // before we try to sign the events to be able to publish them to the relay
    commentBloc.commentActionController.add(GetPubKeyEvent());
    commentBloc.commentActionController.add(ReloadConnection());
  }

  @override
  void dispose() {
    super.dispose();
    _textFieldFocusNode.dispose();
  }

  void _createComment() async {
    if (commentBloc.isRootEventPresent == false) {
      commentBloc.commentActionController
          .add(CreateRootComment(commentController.text.trim()));
    } else {
      // commentBloc.createComment(commentController.text.trim());
      commentBloc.commentActionController
          .add(CreateReplyComment(commentController.text.trim()));
    }
    setState(() {});
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
      child: RefreshIndicator(
        onRefresh: () async {
          await commentBloc.reloadConnection();
        },
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              _textFieldFocusNode.unfocus();
            }
          },
          child: CommentBox(
            hintText: hintText,
            errorText: 'Comment cannot be blank',
            withBorder: _textFieldFocusNode.hasFocus ? true : false,
            sendButtonMethod: () {
              if (formKey.currentState.validate()) {
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
            textColor: themeData.textTheme.titleMedium.color,
            sendWidget: _textFieldFocusNode.hasFocus
                ? Icon(
                    Icons.send,
                    size: 20,
                  )
                : SizedBox.shrink(),
            child: CommentRender(
              commentBloc: commentBloc,
            ),
          ),
        ),
      ),
    );
  }
}
