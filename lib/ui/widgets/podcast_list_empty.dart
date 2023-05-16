import 'package:anytime/l10n/L.dart';
import 'package:flutter/material.dart';

class PodcastListEmpty extends StatelessWidget {
  const PodcastListEmpty({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.search,
            size: 75,
            color: Theme.of(context).primaryColor,
          ),
          Text(
            L.of(context).no_search_results_message,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
