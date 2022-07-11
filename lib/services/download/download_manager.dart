// Copyright 2020-2022 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:anytime/entities/downloadable.dart';

class DownloadProgress {
  final String id;
  final int percentage;
  final DownloadState status;

  DownloadProgress(
    this.id,
    this.percentage,
    this.status,
  );
}

abstract class DownloadManager {
  Future<String> enqueTask(String url, String downloadPath, String fileName);
  Stream<DownloadProgress> get downloadProgress;
  void dispose();
}
