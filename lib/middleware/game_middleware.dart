import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:heist/db/database.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/haunt_definitions.dart';
import 'package:heist/main.dart';
import 'package:heist/reducers/form_reducers.dart';
import 'package:heist/reducers/reducers.dart';
import 'package:heist/reducers/request_reducers.dart';
import 'package:heist/reducers/subscription_reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';

import 'middleware.dart';

class JoinGameAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    String roomId = getRoom(store.state).id;
    assert(roomId != null);
    String playerName = getPlayerName(store.state);
    assert(playerName != null && playerName.isNotEmpty);

    FirestoreDb db = store.state.db;
    String installId = getPlayerInstallId(store.state);

    if (!haveJoinedGame(store.state) && !(await db.playerExists(roomId, installId))) {
      return db.upsertPlayer(new Player(installId: installId, name: playerName), roomId);
    }
  }
}

class SetUpNewGameAction extends MiddlewareAction {
  List<String> _getRemainingRoles(Room room, List<Player> players) {
    List<String> roles = new List.of(room.roles);
    assert(roles.length == players.length);

    Set<String> assignedRoles =
        players.where((p) => p.role != null && p.role.isNotEmpty).map((p) => p.role).toSet();
    return roles.where((r) => !assignedRoles.contains(r)).toList();
  }

  List<int> _getRemainingOrders(List<Player> players) {
    Set<int> assignedOrders = players.where((p) => p.order != null).map((p) => p.order).toSet();
    List<int> remainingOrders = new List.generate(players.length, (i) => i + 1);
    remainingOrders.retainWhere((o) => !assignedOrders.contains(o));
    return remainingOrders;
  }

  void _assignRoles(Store<GameModel> store) {
    Room room = getRoom(store.state);
    List<Player> players = getPlayers(store.state);

    List<String> remainingRoles = _getRemainingRoles(room, players);
    List<int> remainingOrders = _getRemainingOrders(players);
    List<Player> unassignedPlayers =
        players.where((p) => p.order == null && (p.role == null || p.role.isEmpty)).toList();
    Random random = new Random();
    for (Player player in unassignedPlayers) {
      String role = remainingRoles.removeAt(random.nextInt(remainingRoles.length));
      int order = remainingOrders.removeAt(random.nextInt(remainingOrders.length));
      store.state.db.upsertPlayer(player.copyWith(role: role, order: order), room.id);
    }
  }

  Future<String> _createFirstHaunt(Store<GameModel> store) async {
    FirestoreDb db = store.state.db;
    Room room = getRoom(store.state);
    List<Haunt> haunts = getHaunts(store.state);
    if (haunts.isEmpty) {
      Haunt haunt = await db.getHaunt(room.id, 1);
      if (haunt != null) {
        return haunt.id;
      }
      HauntDefinition hauntDefinition = hauntDefinitions[room.numPlayers][1];
      Haunt newHaunt = new Haunt(
          price: hauntDefinition.price,
          numPlayers: hauntDefinition.numPlayers,
          maximumBid: hauntDefinition.maximumBid,
          order: 1,
          startedAt: now());
      return db.upsertHaunt(newHaunt, room.id);
    }
    return haunts[0].id;
  }

  Future<void> _createFirstRound(Store<GameModel> store, String hauntId) async {
    FirestoreDb db = store.state.db;
    String roomId = getRoom(store.state).id;
    if (!hasRounds(store.state) && !(await db.roundExists(roomId, hauntId, 1))) {
      String newLeader = getPlayers(store.state).singleWhere((p) => p.order == 1).id;
      Round round =
          new Round(order: 1, haunt: hauntId, leader: newLeader, team: new Set(), startedAt: now());
      return db.upsertRound(round, roomId);
    }
  }

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    _assignRoles(store);
    // TODO: create all haunts now to minimise how often we have to create new documents in the database
    String hauntId = await _createFirstHaunt(store);
    return _createFirstRound(store, hauntId);
  }
}

class LoadGameAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    await loadGame(store);
    _addGameSetUpListener(store);
  }

  void _completeRequest(Store<GameModel> store, Request request) {
    if (requestInProcess(store.state, request)) {
      store.dispatch(new RequestCompleteAction(request));
    }
  }

  void _clearSetUpRequests(Store<GameModel> store) {
    _completeRequest(store, Request.CreatingNewRoom);
    _completeRequest(store, Request.JoiningGame);
  }

  void _setUpGame(Store<GameModel> store, GameModel gameModel) {
    if (!roomIsAvailable(gameModel)) {
      return;
    }

    if (waitingForPlayers(gameModel)) {
      if (!haveJoinedGame(gameModel) && !requestInProcess(gameModel, Request.JoiningGame)) {
        store.dispatch(new StartRequestAction(Request.JoiningGame));
        store.dispatch(new JoinGameAction());
      }
      return;
    }

    if (isNewGame(gameModel)) {
      if (amOwner(gameModel) && !requestInProcess(gameModel, Request.CreatingNewRoom)) {
        store.dispatch(new StartRequestAction(Request.CreatingNewRoom));
        store.dispatch(new SetUpNewGameAction());
      }
      return;
    }
  }

  void _addGameSetUpListener(Store<GameModel> store) {
    store.onChange
        .takeWhile(
            (gameModel) => getSubscriptions(gameModel).subs.isNotEmpty && !gameIsReady(gameModel))
        .listen((gameModel) => _setUpGame(store, gameModel),
            onDone: () => _clearSetUpRequests(store), onError: (e) => _clearSetUpRequests(store));
  }

  Future<void> loadGame(Store<GameModel> store) async {
    store.dispatch(new SavePlayerInstallIdAction(await installId()));

    FirestoreDb db = store.state.db;
    Room room = getRoom(store.state);
    String roomId = room.id ?? (await db.getRoomByCode(room.code)).id;
    List<Haunt> haunts = await db.getHaunts(roomId);

    _subscribe(store, roomId, haunts);
  }

  StreamSubscription<Room> _roomSubscription(Store<GameModel> store, String id) {
    return store.state.db.listenOnRoom(id, (room) {
      store.dispatch(new UpdateStateAction<Room>(room));
    });
  }

  StreamSubscription<List<Player>> _playerSubscription(Store<GameModel> store, String roomId) {
    return store.state.db.listenOnPlayers(
        roomId, (players) => store.dispatch(new UpdateStateAction<List<Player>>(players)));
  }

  StreamSubscription<List<Haunt>> _hauntSubscription(Store<GameModel> store, String roomId) {
    return store.state.db.listenOnHaunts(
        roomId, (haunts) => store.dispatch(new UpdateStateAction<List<Haunt>>(haunts)));
  }

  StreamSubscription<List<Round>> _roundSubscriptions(Store<GameModel> store, String roomId) {
    return store.state.db.listenOnRounds(roomId, (rounds) {
      Map<String, List<Round>> roundMap = groupBy(rounds, (r) => r.haunt);
      roundMap.values.forEach((rs) => rs.sort((r1, r2) => r1.order.compareTo(r2.order)));
      store.dispatch(new UpdateStateAction<Map<String, List<Round>>>(roundMap));
    });
  }

  void _subscribe(Store<GameModel> store, String roomId, List<Haunt> haunts) {
    assert(roomId != null);

    List<StreamSubscription> subs = [
      _roomSubscription(store, roomId),
      _playerSubscription(store, roomId),
      _hauntSubscription(store, roomId),
      _roundSubscriptions(store, roomId)
    ];

    Subscriptions subscriptions = new Subscriptions(subs: subs);
    store.dispatch(new AddSubscriptionsAction(subscriptions));
  }
}
