import 'package:anytime/entities/comment_model.dart';
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
  List<CommentModel> rootUserdata = CommentModel.filedata;

  final FocusNode _textFieldFocusNode = FocusNode();

  CommentBloc commentBloc;

  @override
  void initState() {
    super.initState();
    commentBloc = Provider.of<CommentBloc>(context, listen: false);
    // commentBloc.init();
    commentBloc.getPubKey();
    commentBloc.reloadConnection();

    // getting the pubkey is necessary because we need to create the key pair
    // before we try to sign the events to be able to publish them to the relay
  }

  @override
  void dispose() {
    super.dispose();
    _textFieldFocusNode.dispose();
  }

  void _createComment() async {
    if (commentBloc.isRootEventPresent == false) {
      await commentBloc.createRootEvent(commentController.text.trim());
    } else {
      commentBloc.createComment(commentController.text.trim());
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
            // userImage: Icon(Icons.person),
            // // CommentBox.commentImageParser(
            // //   imageURLorPath: "assets/icons/person.png",
            // // ),
            hintText: hintText,
            errorText: 'Comment cannot be blank',
            withBorder: _textFieldFocusNode.hasFocus ? true : false,
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
