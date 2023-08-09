import 'package:flutter/material.dart';

class CommentUserImage extends StatefulWidget {
  final String userImage;
  CommentUserImage({Key key, this.userImage}) : super(key: key);

  @override
  State<CommentUserImage> createState() => _CommentUserImageState();
}

class _CommentUserImageState extends State<CommentUserImage> {
  ImageProvider commentImageParser({String imageURLorPath}) {
    //check if imageURLorPath
    if (imageURLorPath is String) {
      if (imageURLorPath.startsWith('http')) {
        return NetworkImage(imageURLorPath);
      } else {
        return AssetImage(imageURLorPath);
      }
    } else {
      return imageURLorPath as ImageProvider;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    if (widget.userImage != null) {
      return CircleAvatar(
        backgroundImage: commentImageParser(
          imageURLorPath: widget.userImage,
        ),
        onBackgroundImageError: (exception, stackTrace) {
          throw (exception);
        },
      );
    }

    return CircleAvatar(
      child: Icon(
        Icons.person,
        color: themeData.iconTheme.color,
      ),
    );
  }
}
