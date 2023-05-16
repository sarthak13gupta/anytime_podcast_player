// Copyright 2020-2021. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:podcast_search/podcast_search.dart' as psapi;

/// A class that represents value for value payment information
/// for a [Podcast] or an [Episode].
/// Part of the [podcast namespace](https://github.com/Podcastindex-org/podcast-namespace)
class Value {
  final String? type;
  final String? method;
  final String? suggested;
  List<ValueRecipient> recipients;

  Value({
    required this.type,
    required this.method,
    required this.suggested,
    this.recipients = const <ValueRecipient>[],
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'method': method,
      'suggested': suggested,
      'recipients': (recipients).map((recipient) => recipient.toMap()).toList(growable: false),
    };
  }

  static Value fromMap(Map<String, dynamic> value) {
    var recipients = <ValueRecipient>[];
    if (value['recipients'] != null) {
      for (var recipient in (value['recipients'] as List)) {
        if (recipient is Map<String, dynamic>) {
          recipients.add(ValueRecipient.fromMap(recipient));
        }
      }
    }

    return Value(
      type: value['type'] as String?,
      method: value['method'] as String?,
      suggested: value['suggested'] as String?,
      recipients: recipients,
    );
  }

  static Value? fromPodcastSearchValue(psapi.Value? v) {
    if (v == null) return null;

    List<ValueRecipient> recipients = v.recipients.map((r) =>
      ValueRecipient(
        type: r.type,
        address: r.address,
        split: r.split,
        name: r.name,
        customKey: r.customKey,
        customValue: r.customValue,
        fee: r.fee,
      )
    ).toList();

    return Value(
        type: v.type,
        method: v.method,
        suggested: v.suggested,
        recipients: recipients
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Value
              && runtimeType == other.runtimeType
              && type == other.type
              && method == other.method
              && suggested == other.suggested;

  @override
  int get hashCode => type.hashCode ^ method.hashCode ^ suggested.hashCode;
}

class ValueRecipient {
  final String? type;
  final String? address;
  final String? split;
  final String? name;
  final String? customKey;
  final String? customValue;
  final String? fee;

  ValueRecipient({
    required this.type,
    required this.address,
    required this.split,
    this.name,
    this.customKey,
    this.customValue,
    this.fee,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'address': address,
      'split': split,
      'name': name,
      'customKey': customKey,
      'customValue': customValue,
      'fee': fee,
    };
  }

  static ValueRecipient fromMap(Map<String, dynamic> valueRecipient) {
    return ValueRecipient(
      type: valueRecipient['type'] as String?,
      address: valueRecipient['address'] as String?,
      split: valueRecipient['split'] as String?,
      name: valueRecipient['name'] as String?,
      customKey: valueRecipient['customKey'] as String?,
      customValue: valueRecipient['customValue'] as String?,
      fee: valueRecipient['fee'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ValueRecipient
              && runtimeType == other.runtimeType
              && type == other.type
              && address == other.address
              && split == other.split;

  @override
  int get hashCode => type.hashCode ^ address.hashCode ^ split.hashCode;
}
