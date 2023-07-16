import 'dart:async';
import 'dart:convert';

import 'package:anytime/bloc/bloc.dart';
import 'package:nostr_tools/nostr_tools.dart';

import '../../entities/episode.dart';

class CommentBloc extends Bloc {
  final Stream<Episode> episodeStream;
  CommentBloc({this.episodeStream}) {
    init();
  }
  final _relayPool = RelayApi(relayUrl: 'wss://relay.damus.io');
  // final relaysList = [
  //   "wss://relay.damus.io",
  //   // "wss://nostr1.tunnelsats.com",
  //   // "wss://nostr-pub.wellorder.net",
  //   // "wss://relay.nostr.info",
  //   // "wss://nostr-relay.wlvs.space",
  //   // "wss://nostr.bitcoiner.social",
  //   // "wss://nostr-01.bolt.observer",
  //   // "wss://relayer.fiatjaf.com",
  // ];
  List<Event> events = [];
  String _rootId;
  bool isRootEventPresent = false;
  Episode currentEpisode;

  final Map<String, Metadata> metaDatas = {};

  final Map<String, bool> _eventMap = {};

  bool _isNewEventPublishing = false;

  bool _addEventToController = false;

  bool _isConnected = false;
  final StreamController<bool> _isConnectedController =
      StreamController<bool>.broadcast();

  final StreamController<Event> _eventController =
      StreamController<Event>.broadcast();

  final StreamController<String> _publicKeyController =
      StreamController<String>.broadcast();

  final StreamController<Map<String, dynamic>> _signEventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<bool> get isConnectedStream => _isConnectedController.stream;
  Stream<String> get pubKeyStream => _publicKeyController.stream;
  Stream<Map<String, dynamic>> get signEventStream =>
      _signEventController.stream;

  Map<String, dynamic> previousEvent;

  // StreamController<Message> _streamController =
  //     StreamController<Message>.broadcast();
  // Stream<Message> get _streamConnect => _streamController.stream;
  // Stream<Message> _streamConnect;
  Stream<Event> stream = StreamController<Event>.broadcast().stream;
  Stream<Message> _streamConnect = StreamController<Message>.broadcast().stream;

  Stream<Event> get eventStream => _eventController.stream;

  void init() {
    // need to get the metadata of user for the first time
    _getUserMetaData();

    _listenToEpisode();

    // get metadata of user
  }

  // setting listener for episode
  void _listenToEpisode() {
    episodeStream.listen((episode) {
      // reload in case of a different episode
      if (currentEpisode != episode) {
        currentEpisode = episode;
        _reloadConnection();
      }
    });
  }

  void _getUserMetaData() {
    // get pubkey of user
    _getPubKey();
  }

  // create a comment
  void createComment(String content) {
    Map<String, dynamic> eventData = <String, dynamic>{
      "created_at": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "kind": 1,
      "tags": [
        ['e', _rootId],
      ],
      "content": content,
    };
    signEvent(eventData);
  }

  // reload relay connection via pull to refresh
  void _reloadConnection() {
    // setting each variable to its default value
    isRootEventPresent = false;
    _addEventToController = false;
    _isNewEventPublishing = false;
    _isConnected = false;
    _rootId = null;
    events.clear();
    metaDatas.clear();
    _eventMap.clear();

    // calling relay connection again
    initRelayConnection();
  }

  Stream<Event> _fetchRootEvent() {
    // to get the root event, filter out using the tag of url of the episode

    _relayPool.sub([
      Filter(
        kinds: [1],
        // limit: 1,
        // t: ['#r', currentEpisode.contentUrl],
        t: [currentEpisode.contentUrl],
      )
    ]);

    return _streamConnect
        .where((message) => message.type == 'EVENT')
        .map((message) => message.message as Event);
  }

  void createRootEvent() {
    // if no Root Event present then create one
    Map<String, dynamic> eventData = <String, dynamic>{
      "created_at": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "kind": 1,
      "tags": [
        // ['#r', currentEpisode.contentUrl],
        ['t', currentEpisode.contentUrl],
      ],
      "content":
          "comments about episode ${currentEpisode.title} at ${currentEpisode.contentUrl}",
    };
    signEvent(eventData);
  }

  void initRelayConnection() async {
    stream = await _connectRelayPool();

    // if no event received then will have to show that there are no comments present
    stream.listen((event) {
      if (event.kind == 1) {
        // adding the event according its creation time

        // check for being the rootEvent
        print(event.tags);
        if (event.tags[0][0] == "t" &&
            event.tags[0][1] == currentEpisode.contentUrl) {
          _rootId = event.id;
          isRootEventPresent = true;

          // subscribing to replies to the root level comment
          _relayPool.sub([
            Filter(
              kinds: [1],
              limit: 100,
              // denoting that this is a root level reply
              e: [_rootId],
            )
          ]);
        } else if (event.tags[0][0] == "e" && event.tags[0][1] == _rootId) {
          _addEvent(event);
        }
        // if event is already present in List then return to avoid duplication
        if (_addEventToController == false) {
          return;
        }

        // to get the metadata of the user of the comment
        _relayPool.sub([
          Filter(kinds: [0], authors: [event.pubkey])
        ]);
      } else if (event.kind == 0) {
        Metadata metadata = Metadata.fromJson(
            jsonDecode(event.content) as Map<String, dynamic>);
        metaDatas[event.pubkey] = metadata;
      }

      if (_addEventToController) {
        _eventController.add(event);

        // setting _addEventController to false to check for the next event to be added
        _addEventToController = false;
      }
    });
  }

  Future<Stream<Event>> _connectRelayPool() async {
    _streamConnect = await _relayPool.connect();
    // final streamConnect = await _relayPool.connect();

    _relayPool.on((event) {
      if (event == RelayEvent.connect) {
        _isConnected = true;
        _isConnectedController.add(_isConnected);
      } else if (event == RelayEvent.error) {
        _isConnected = false;
        _reloadConnection();
        _isConnectedController.add(_isConnected);
      }
    });

    Stream<Event> rootEventStream = _fetchRootEvent();

    return rootEventStream;
  }

  void _addEvent(Event event) {
    if (_eventMap.containsKey(event.id) == false) {
      events.add(event);
      _addEventToController = true;
      _eventMap[event.id] = true;
    } else {
      _addEventToController = false;
    }
  }

  Future<void> _getPubKey() async {
    _publicKeyController.add('getPubKey');
  }

  Future<void> signEvent(Map<String, dynamic> eventData) async {
    _signEventController.add(eventData);
  }

  void getPubKeyResult(String pubKey) {
    print('Received public key from Breez: $pubKey');
    // we need to set the icon(user) for the commentBox

    // get user meta data using this pub key
    // set a relay connection
    // put a filter with author as the pubkey
    // limit = 1
    // as soon as we get the pubkey break the process.
  }

  void signEventResult(Map<String, dynamic> signedEvent) {
    // need to check whether to keep this if statement
    if (previousEvent == signedEvent) {
      return;
    }
    previousEvent = signedEvent;

    final signedNostrEvent = Event(
        kind: signedEvent['kind'] as int,
        tags: signedEvent['tags'] as List<List<String>>,
        content: signedEvent['content'] as String,
        created_at: signedEvent['created_at'] as int,
        id: signedEvent['id'] as String,
        sig: signedEvent['sig'] as String,
        pubkey: signedEvent['pubkey'] as String);

    _publishNewEvent(signedNostrEvent);
  }

  void _publishNewEvent(Event signedNostrEvent) {
    try {
      // call a loading state
      _isNewEventPublishing = true;
      _relayPool.publish(signedNostrEvent);
      // end the loading state
      _isNewEventPublishing = false;
    } catch (e) {
      throw Exception(e);
    }

    if (_isNewEventPublishing == false) {
      _reloadConnection();
    }
  }

  @override
  void dispose() {
    _relayPool.close();
    _isConnectedController.close();
    _eventController.close();
    _publicKeyController.close();
    _signEventController.close();
    super.dispose();
  }
}
