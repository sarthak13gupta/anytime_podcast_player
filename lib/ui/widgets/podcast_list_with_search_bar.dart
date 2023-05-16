import 'package:anytime/ui/search/search_bar.dart' as sb;
import 'package:anytime/ui/widgets/podcast_list.dart';
import 'package:anytime/ui/widgets/podcast_list_empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:podcast_search/podcast_search.dart' as search;

class PodcastListWithSearchBar extends StatelessWidget {
  final search.SearchResult results;

  const PodcastListWithSearchBar({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return results.items.isEmpty
        ? SliverFillRemaining(
            child: Column(
              children: [
                sb.SearchBar(),
                Expanded(
                  child: const PodcastListEmpty(),
                ),
                // Search bar has 56 dp of height so adding this extra padding we get a perfect alignment
                SizedBox(height: 56),
              ],
            ),
          )
        : SliverToBoxAdapter(
            child: ShrinkWrappingViewport(
              offset: ViewportOffset.zero(),
              slivers: [
                SliverToBoxAdapter(child: sb.SearchBar()),
                PodcastList(
                  results: results,
                ),
              ],
            ),
          );
  }
}
