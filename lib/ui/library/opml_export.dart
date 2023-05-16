// Copyright 2020-2022 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:anytime/bloc/podcast/opml_bloc.dart';
import 'package:anytime/l10n/L.dart';
import 'package:anytime/state/opml_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OPMLExport extends StatefulWidget {
  const OPMLExport({
    Key? key,
  }) : super(key: key);

  @override
  State<OPMLExport> createState() => _OPMLExportState();
}

class _OPMLExportState extends State<OPMLExport> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<OPMLBloc>(context, listen: false);
    final width = MediaQuery.of(context).size.width - 60.0;

    return SizedBox(
      height: 80,
      width: width,
      child: StreamBuilder<OPMLState>(
          initialData: OPMLNoneState(),
          stream: bloc.opmlState,
          builder: (context, snapshot) {
            if (snapshot.data is OPMLCompletedState) {
              Navigator.pop(context);
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: CircularProgressIndicator.adaptive(),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      L.of(context).settings_export_opml,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  @override
  void initState() {
    super.initState();

    final bloc = Provider.of<OPMLBloc>(context, listen: false);

    bloc.opmlEvent(OPMLExportEvent());
  }
}
