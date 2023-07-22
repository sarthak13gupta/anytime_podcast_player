import 'package:anytime/bloc/comments/comments_state_event.dart';
import 'package:anytime/entities/episode.dart';
import 'package:anytime/ui/podcast/episode_comment_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/comments/comments_bloc.dart';
import 'comment_list.dart';

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
  String userImage;

  CommentBloc commentBloc;

  @override
  void initState() {
    super.initState();
    commentBloc = Provider.of<CommentBloc>(context, listen: false);
    init();
  }

  void init() {
    commentBloc.commentActionController.add(GetUserPubKey());
    commentBloc.commentActionController.add(ReloadConnection());

    commentBloc.userMetaDataStream.listen((metadata) {
      if (metadata != null) {
        setState(() {
          userImage = metadata.picture;
        });
      }
    });
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
      commentBloc.commentActionController
          .add(CreateReplyComment(commentController.text.trim()));
    }
    setState(() {});
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
            userImage: userImage,
            hintText: hintText,
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
