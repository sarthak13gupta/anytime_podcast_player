// Copyright 2020-2022 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:anytime/bloc/podcast/podcast_bloc.dart';
import 'package:anytime/entities/podcast.dart';
import 'package:anytime/ui/podcast/podcast_details.dart';
import 'package:anytime/ui/widgets/tile_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PodcastTile extends StatelessWidget {
  final Podcast podcast;

  const PodcastTile({
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    final podcastBloc = Provider.of<PodcastBloc>(context);

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
              settings: RouteSettings(name: 'podcastdetails'),
              builder: (context) => PodcastDetails(podcast, podcastBloc)),
        );
      },
      leading: Hero(
        key: Key('tilehero${podcast.imageUrl}:${podcast.link}'),
        tag: '${podcast.imageUrl}:${podcast.link}',
        child: TileImage(
          url: podcast.imageUrl,
          size: 60,
        ),
      ),
      title: Text(
        podcast.title!,
        maxLines: 1,
      ),
      subtitle: Text(
        podcast.copyright ?? '',
        maxLines: 2,
      ),
      isThreeLine: false,
    );
  }
}
