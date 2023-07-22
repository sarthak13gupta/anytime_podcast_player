import 'package:flutter/material.dart';

class CommentUserImage extends StatefulWidget {
  final String userImage;
  CommentUserImage({Key key, this.userImage}) : super(key: key);

  @override
  State<CommentUserImage> createState() => _CommentUserImageState();
}

class _CommentUserImageState extends State<CommentUserImage> {
  ImageProvider commentImageParser({String imageURLorPath}) {
    try {
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
    } catch (e) {
      //throw error
      throw Exception('Error parsing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    if (widget.userImage != null) {
      return CircleAvatar(
        backgroundImage: commentImageParser(imageURLorPath: widget.userImage),
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
