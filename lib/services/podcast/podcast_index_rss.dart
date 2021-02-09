import 'dart:core';
import 'package:dart_rss/util/helpers.dart';
import 'package:xml/xml.dart';

class PodcastIndexRssFeed {
  final Value value;

  PodcastIndexRssFeed({this.value});

  factory PodcastIndexRssFeed.parse(String xmlString) {
    var document = XmlDocument.parse(xmlString);
    XmlElement channelElement;
    try {
      channelElement = document.findAllElements('channel').first;
    } on StateError {
      throw ArgumentError('channel not found');
    }

    return PodcastIndexRssFeed(
      value: Value.parse(findElementOrNull(channelElement, 'podcast:value')),
    );
  }
}

class Value {
  final String type;
  final String method;
  final String suggested;
  final List<ValueRecipient> recipients;

  Value._({this.type, this.method, this.suggested, this.recipients});

  factory Value.parse(XmlElement element) {
    if (element == null) {
      return null;
    }

    return Value._(
        type: element.getAttribute('type'),
        method: element.getAttribute('method'),
        suggested: element.getAttribute('suggested'),
        recipients: element.findAllElements('podcast:valueRecipient').map((e) => ValueRecipient.parse(e)).toList());
  }

  factory Value.fromJson(Map<String, dynamic> map) {
    if (map == null) {
      return null;
    }

    final recipients = <ValueRecipient>[];
    final recipientsJson = map['recipients'] as List<Map<String, dynamic>>;
    recipientsJson.forEach((d) {
      if (d is Map<String, dynamic>) {
        recipients.add(ValueRecipient.fromJson(d));
      }
    });

    return Value._(
        type: map['type'] as String,
        method: map['method'] as String,
        suggested: map['suggested'] as String,
        recipients: recipients);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'method': method,
      'suggested': suggested,
      'recipients': recipients.map((d) => d.toJson()).toList()
    };
  }
}

class ValueRecipient {
  final String name;
  final String address;
  final String type;
  final double split;

  ValueRecipient({this.name, this.address, this.type, this.split});
  factory ValueRecipient.parse(XmlElement element) {
    return ValueRecipient(
        name: element.getAttribute('name'),
        address: element.getAttribute('address'),
        type: element.getAttribute('type'),
        split: _parseDouble(element.getAttribute('split')));
  }

  static ValueRecipient fromJson(Map<String, dynamic> json) {
    var split = json['split'] as double;
    return ValueRecipient(
      name: json['name'] as String,
      address: json['address'] as String,
      type: json['type'] as String,
      split: split,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'name': name, 'address': address, 'type': type, 'split': split};
  }
}

double _parseDouble(String text) {
  if (text == null) {
    return null;
  }
  return double.parse(text);
}
