import 'package:flutter/material.dart';

import '../widgets/comment_user_image.dart';

// ignore: must_be_immutable
class CommentBox extends StatefulWidget {
  final Widget child;
  final Key formKey;
  final Function() sendButtonMethod;
  final TextEditingController commentController;
  final String userImage;
  String labelText;
  String hintText;
  final String errorText;
  final Widget sendWidget;
  final Color backgroundColor;
  final Color textColor;
  final bool withBorder;
  final Widget header;
  final FocusNode focusNode;
  CommentBox({
    @required this.child,
    this.header,
    @required this.sendButtonMethod,
    this.formKey,
    this.commentController,
    this.sendWidget,
    this.userImage,
    this.labelText,
    this.focusNode,
    this.errorText,
    this.withBorder = true,
    this.backgroundColor,
    this.textColor,
    this.hintText,
  });

  @override
  State<CommentBox> createState() => _CommentBoxState();
}

class _CommentBoxState extends State<CommentBox> {
  int maxLines = 2;
  Color sendWidgetColor = Colors.grey;

  // Widget _placeholderImage(ThemeData themeData) {
  //   if (widget.userImage != null) {
  //     return CircleAvatar(
  //       backgroundImage:
  //           CommentBox.commentImageParser(imageURLorPath: widget.userImage),
  //     );
  //   }

  //   return CircleAvatar(
  //     child: Icon(
  //       Icons.person,
  //       color: themeData.iconTheme.color,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Theme(
      data: themeData,
      child: Column(
        children: [
          ListTile(
            minLeadingWidth: 35,
            tileColor: widget.backgroundColor,
            leading: Container(
              height: 35.0,
              width: 35.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: CommentUserImage(userImage: widget.userImage),
            ),
            title: Form(
              key: widget.formKey,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: themeData.colorScheme.background,
                      height: 53,
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                      // child: Card(
                      alignment: Alignment.centerLeft,
                      child: TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (value) {
                          if (value == '') {
                            setState(() {
                              sendWidgetColor = Colors.grey;
                            });
                          } else {
                            setState(() {
                              sendWidgetColor = Colors.white;
                            });
                          }
                        },
                        keyboardType: TextInputType.multiline,
                        maxLines: 2,
                        focusNode: widget.focusNode,
                        cursorColor: widget.textColor,
                        style: TextStyle(color: widget.textColor),
                        controller: widget.commentController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(
                              top: 15, bottom: 2, left: 10, right: 5),
                          isCollapsed: true,
                          hintText: widget.hintText,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          enabledBorder: !widget.withBorder
                              ? InputBorder.none
                              : OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: widget.textColor),
                                ),
                          focusedBorder: !widget.withBorder
                              ? InputBorder.none
                              : OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: widget.textColor),
                                ),
                          border: !widget.withBorder
                              ? InputBorder.none
                              : OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: widget.textColor),
                                ),
                          focusColor: widget.textColor,
                          labelStyle: TextStyle(color: widget.textColor),
                        ),
                      ),
                    ),
                  ),
                  widget.focusNode.hasFocus
                      ? IconButton(
                          alignment: Alignment.centerRight,
                          icon: Icon(
                            Icons.send_sharp,
                            size: 25,
                            color: sendWidgetColor,
                          ),
                          onPressed: () {
                            // print(
                            //     "widget.commentController.text ${widget.commentController.text}");
                            if (widget.commentController.text != '') {
                              widget.sendButtonMethod();
                            }
                          },
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ),
          Divider(
            thickness: 1,
            height: 0.5,
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
