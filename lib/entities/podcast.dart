// Copyright 2020-2021 Ben Hills. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:podcast_search/podcast_search.dart' as search;

import 'episode.dart';

class Podcast {
  int id;
  final String guid;
  final String url;
  final String link;
  final String title;
  final String description;
  final String imageUrl;
  final String thumbImageUrl;
  final String copyright;
  DateTime subscribedDate;
  List<Episode> episodes;
  Value value;

  Podcast({
    @required this.guid,
    @required this.url,
    @required this.link,
    @required this.title,
    this.id,
    this.description,
    this.imageUrl,
    this.thumbImageUrl,
    this.copyright,
    this.subscribedDate,
    this.episodes,
    this.value,
  }) {
    episodes ??= [];
  }

  Podcast.fromSearchResultItem(search.Item item)
      : guid = item.guid,
        url = item.feedUrl,
        link = item.feedUrl,
        title = item.trackName,
        description = '',
        imageUrl = item.artworkUrl600 ?? item.artworkUrl100,
        thumbImageUrl = item.artworkUrl60,
        copyright = item.artistName;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'guid': guid,
      'title': title ?? '',
      'copyright': copyright ?? '',
      'description': description ?? '',
      'url': url,
      'imageUrl': imageUrl ?? '',
      'thumbImageUrl': thumbImageUrl ?? '',
      'subscribedDate': subscribedDate?.millisecondsSinceEpoch.toString() ?? '',
      'value': value?.toJson(),
    };
  }

  static Podcast fromMap(int key, Map<String, dynamic> podcast) {
    final sds = podcast['subscribedDate'] as String;
    DateTime sd;

    if (sds.isNotEmpty && sds != 'null') {
      sd = DateTime.fromMicrosecondsSinceEpoch(int.parse(podcast['subscribedDate'] as String));
    }

    return Podcast(
        id: key,
        guid: podcast['guid'] as String,
        link: podcast['link'] as String,
        title: podcast['title'] as String,
        copyright: podcast['copyright'] as String,
        description: podcast['description'] as String,
        url: podcast['url'] as String,
        imageUrl: podcast['imageUrl'] as String,
        thumbImageUrl: podcast['thumbImageUrl'] as String,
        subscribedDate: sd,
        value: Value.fromJson(podcast['value'] as Map<String, dynamic>));
  }

  bool get subscribed => id != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Podcast && runtimeType == other.runtimeType && guid == other.guid && url == other.url;

  @override
  int get hashCode => guid.hashCode ^ url.hashCode;
}

class Value {
  final ValueModel model;
  final List<ValueDestination> destinations;

  Value(this.model, this.destinations);

  static Value fromJson(Map<String, dynamic> json) {
    final model = ValueModel.fromJson(json['model'] as Map<String, dynamic>);
    final destinations = <ValueDestination>[];
    final destinationsJson = json['destinations'];
    if (destinationsJson is List) {
      destinationsJson.forEach((d) {
        if (d is Map<String, dynamic>) {
          destinations.add(ValueDestination.fromJson(d));
        }
      });
    }
    return Value(model, destinations);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'model': model.toJson(), 'destinations': destinations.map((d) => d.toJson()).toList()};
  }
}

class ValueModel {
  final String type;
  final String method;
  final String suggested;

  ValueModel({this.type, this.method, this.suggested});

  static ValueModel fromJson(Map<String, dynamic> json) {
    return ValueModel(type: json['type'] as String, method: json['method'] as String, suggested: json['suggested'] as String);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'type': type, 'method': method, 'suggested': suggested};
  }
}

class ValueDestination {
  final String name;
  final String address;
  final String type;
  final double split;

  ValueDestination({this.name, this.address, this.type, this.split});

  static ValueDestination fromJson(Map<String, dynamic> json) {
    var split = json['split'];
    if (split is String) {
      split = double.tryParse(split as String);
    }
    return ValueDestination(
      name: json['name'] as String,
      address: json['address'] as String,
      type: json['type'] as String,
      split: (split as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'name': name, 'address': address, 'type': type, 'split': split};
  }
}
