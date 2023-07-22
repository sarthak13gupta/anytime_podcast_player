import 'dart:async';
import 'dart:convert';

import 'package:anytime/bloc/bloc.dart';
import 'package:anytime/bloc/comments/comments_state_event.dart';
import 'package:anytime/entities/comments.dart';
import 'package:nostr_tools/nostr_tools.dart';

import '../../entities/episode.dart';

class CommentBloc extends Bloc {
  final Stream<Episode> episodeStream;
  CommentBloc({this.episodeStream}) {
    init();
  }
  final relaysList = [
    "wss://relay.damus.io",
    "wss://nostr1.tunnelsats.com",
    "wss://nostr-pub.wellorder.net",
    "wss://relay.nostr.info",
    "wss://nostr-relay.wlvs.space",
    "wss://nostr.bitcoiner.social",
    "wss://nostr-01.bolt.observer",
    "wss://relayer.fiatjaf.com",
  ];
  RelayPoolApi _relayPool;

  Set<String> _connectedRelays;

  List<Event> sortedEvents;
  String _rootId;
  bool isRootEventPresent;
  Episode currentEpisode;
  String replyToRoot;

  Map<String, Metadata> metaDatas;

  Map<String, bool> _eventMap;

  bool _isNewEventPublishing;

  bool _isAddEventToController;

  bool isRelayConnected;

  final StreamController<CommentAction> commentActionController =
      StreamController<CommentAction>.broadcast();

  Stream<CommentAction> get commentActionStream =>
      commentActionController.stream;

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

  Stream<Event> stream = StreamController<Event>.broadcast().stream;

  Stream<Message> _streamConnect;
  StreamSubscription _streamSubscription;

  Stream<Event> get eventStream => _eventController.stream;

  void init() {
    // need to get the metadata of user for the first time
    _relayPool = RelayPoolApi(relaysList: relaysList);
    metaDatas = {};
    _eventMap = {};
    sortedEvents = [];
    _isNewEventPublishing = false;
    _isAddEventToController = false;
    _isAddEventToController = false;
    isRelayConnected = false;
    _getUserMetaData();

    _listenToEpisode();
    _listenToActions();

    // get metadata of user
  }

  void _listenToActions() {
    commentActionStream.listen((event) {
      if (event is CreateRootComment) {
        createRootEvent(event.userComment);
      } else if (event is CreateReplyComment) {
        createComment(event.userComment);
      } else if (event is ReloadConnection) {
        reloadConnection();
      } else if (event is GetPubKeyEvent) {
        getPubKey();
      }
    });
  }

  // setting listener for episode
  void _listenToEpisode() {
    episodeStream.listen((episode) {
      // for the first time necessary to set the
      // relay connection to be able to call relayPool.close()
      // during reloadConnection

      if (currentEpisode == null) {
        currentEpisode = episode;
        initRelayConnection();
      }
      // reload in case of a different episode
      else if (currentEpisode != episode) {
        currentEpisode = episode;
        reloadConnection();
      }
    });
  }

  void _getUserMetaData() {
    // get pubkey of user
    getPubKey();
  }

  // create a comment
  Future<void> createComment(String content) async {
    Map<String, dynamic> eventData = <String, dynamic>{
      "created_at": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "kind": 1,
      "tags": [
        ['e', _rootId],
      ],
      "content": content,
    };
    await signEvent(eventData);
  }

  Future<void> reloadConnection() async {
    // setting each variable to its default value
    isRootEventPresent = false;
    _isAddEventToController = false;
    _isNewEventPublishing = false;
    isRelayConnected = false;
    _rootId = null;
    sortedEvents.clear();
    metaDatas.clear();
    _eventMap.clear();
    _connectedRelays.clear();

    // need to close the relay stream for a fresh connection
    // find if any condition is necessary before calling _relayPool.close()
    _relayPool.close();
    _streamSubscription?.cancel();

    // calling relay connection again
    await initRelayConnection();
  }

  Future<void> createRootEvent(String userComment) async {
    replyToRoot = userComment;
    // if no Root Event present then create one
    Map<String, dynamic> eventData = <String, dynamic>{
      "created_at": DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "kind": 1,
      "tags": [
        ['t', currentEpisode.contentUrl],
      ],
      "content":
          "comments about episode ${currentEpisode.title} at ${currentEpisode.contentUrl}",
    };
    await signEvent(eventData);
  }

  Future<void> initRelayConnection() async {
    // connecting to relays
    try {
      _streamConnect = await _relayPool.connect();

      _relayPool.on((event) {
        if (event == RelayEvent.connect) {
          isRelayConnected = true;
          // if relay is connected add this to _isConnectedController
          _isConnectedController.add(true);
        } else if (event == RelayEvent.error ||
            event == RelayEvent.disconnect) {}
        _connectedRelays = _relayPool.connectedRelays;
        if (_connectedRelays.isEmpty) {
          isRelayConnected = false;
        }
      });
    } catch (e) {
      throw Exception(e);
    }

    if (_rootId == null) {
      _relayPool.sub([
        Filter(
          kinds: [1],
          // limit: 1,
          t: [currentEpisode.contentUrl],
        )
      ]);
    } else {
      _relayPool.sub([
        Filter(
          kinds: [1],
          limit: 100,
          // denoting that this is a root level reply
          e: [_rootId],
        )
      ]);
    }

    // if no event received then will have to show that there are no comments present

    try {
      _streamSubscription = _streamConnect.listen(
        (message) {
          if (message.type == 'EVENT') {
            Event event = message.message as Event;
            if (event.kind == 1) {
              // adding the event according its creation time

              // check for being the rootEvent
              print(event.tags);
              if (event.tags[0][0] == "t" &&
                  event.tags[0][1] == currentEpisode.contentUrl) {
                _rootId = event.id;
                isRootEventPresent = true;

                _relayPool.sub([
                  Filter(
                    kinds: [1],
                    limit: 100,
                    // denoting that this is a root level reply
                    e: [_rootId],
                  )
                ]);
              } else if (event.tags[0][0] == "e" &&
                  event.tags[0][1] == _rootId) {
                _addEvent(event);

                // if event is already present in List then return to avoid duplication
                if (_isAddEventToController == false) {
                  return;
                }

                _eventController.add(event);
                // setting _addEventController to false to check for the next event to be added
                _isAddEventToController = false;
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
          }
        },
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  void _insertInDescendingOrder(Event event) {
    // using binary search to insert the new event
    int start = 0;
    int end = sortedEvents.length - 1;
    int midpoint;
    int position = start;

    if (end < 0) {
      position = 0;
    } else if (event.created_at < sortedEvents[end].created_at) {
      position = end + 1;
    } else if (event.created_at >= sortedEvents[start].created_at) {
      position = start;
    } else {
      while (true) {
        if (end <= start + 1) {
          position = end;
          break;
        }
        midpoint = (start + (end - start) / 2).floor();
        if (sortedEvents[midpoint].created_at > event.created_at) {
          start = midpoint;
        } else if (sortedEvents[midpoint].created_at > event.created_at) {
          end = midpoint;
        } else {
          position = midpoint;
        }
      }
    }
    sortedEvents.insert(position, event);
  }

  void _addEvent(Event event) {
    if (_eventMap.containsKey(event.id) == false) {
      _insertInDescendingOrder(event);
      _isAddEventToController = true;
      _eventMap[event.id] = true;
    } else {
      _isAddEventToController = false;
    }
  }

  // this method is to make sure keyPair is made before signing the sortedEvents
  Future<void> getPubKey() async {
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

  Future<void> signEventResult(Map<String, dynamic> signedEvent) async {
    final signedNostrEvent = CommentEvent.mapToEvent(signedEvent);

    await _publishNewEvent(signedNostrEvent);
  }

  Future<void> _publishNewEvent(Event signedNostrEvent) async {
    try {
      // call a loading state
      _isNewEventPublishing = true;

      // check if _relayPool is not closed
      _relayPool.publish(signedNostrEvent);
      // end the loading state
      _isNewEventPublishing = false;
    } catch (e) {
      throw Exception(e);
    }

    // if it was the root event being published
    // creating the user comment as a reply to it
    if (signedNostrEvent.tags[0][0] == 't' &&
        signedNostrEvent.tags[0][1] == currentEpisode.contentUrl) {
      _rootId = signedNostrEvent.id;
      isRootEventPresent = true;
      await createComment(replyToRoot);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _relayPool.close();
    _isConnectedController.close();
    _eventController.close();
    _publicKeyController.close();
    _signEventController.close();
  }
}
