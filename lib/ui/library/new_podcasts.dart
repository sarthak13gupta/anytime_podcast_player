// Copyright 2020-2021 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:anytime/bloc/new_podcasts/new_podcasts_bloc.dart';
import 'package:anytime/bloc/new_podcasts/new_podcasts_state_event.dart';
import 'package:anytime/ui/library/new_podcasts_results.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewPodcasts extends StatefulWidget {
  final bool inlineSearch;

  NewPodcasts({this.inlineSearch});

  @override
  State<StatefulWidget> createState() => _NewPodcastsState();
}

class _NewPodcastsState extends State<NewPodcasts> {
  @override
  void initState() {
    super.initState();

    final bloc = Provider.of<NewPodcastsBloc>(context, listen: false);

    bloc.getNewPodcasts(NewPodcastsChartEvent(count: 10));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NewPodcastsBloc>(context);

    return NewPodcastsResults(data: bloc.results, inlineSearch: widget.inlineSearch);
  }
}
