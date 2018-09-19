import 'dart:async';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:heist/db/database.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/keys.dart';
import 'package:heist/main.dart';
import 'package:heist/reducers/form_reducers.dart';
import 'package:heist/reducers/reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/common.dart';
import 'package:heist/widget/game.dart';
import 'package:package_info/package_info.dart';
import 'package:redux/redux.dart';

import 'middleware.dart';

class ValidateRoomAction extends MiddlewareAction {
  final BuildContext context;
  final Function() connectivityFunction;

  ValidateRoomAction(this.context, this.connectivityFunction);

  void _showRoomValidationDialog(String message) {
    showDialog(
        context: context,
        builder: (context) => new AlertDialog(
              title: const Text('Error'),
              content: new Text(message),
            ));
  }

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    withRequest(Request.ValidatingRoom, store, (store) async {
      var connectivityResult = await (connectivityFunction());
      if (connectivityResult != ConnectivityResult.none) {
        FirestoreDb db = store.state.db;
        String code = getRoom(store.state).code;
        Room room = await db.getRoomByCode(code);
        if (room == null) {
          _showRoomValidationDialog('Room with code $code does not exist.');
          return;
        }
        store.dispatch(new SavePlayerInstallIdAction(await installId()));
        String iid = getPlayerInstallId(store.state);
        bool playerExists = await db.playerExists(room.id, iid);
        if (!playerExists) {
          String playerName = getPlayerName(store.state);
          if (playerName == null || playerName.isEmpty) {
            _showRoomValidationDialog('Please enter a name.');
            return;
          }
          int numExistingPlayers = await db.getNumPlayers(room.id);
          if (numExistingPlayers >= room.numPlayers) {
            _showRoomValidationDialog('Room is full.');
            return;
          }
          bool nameAlreadyTaken = await db.playerExistsWithName(room.id, playerName);
          if (nameAlreadyTaken) {
            _showRoomValidationDialog('Name $playerName is already taken.');
            return;
          }
        }
        Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new Game(store)));
      } else {
        showNoConnectionDialog(context);
      }
    });
  }
}

class CreateRoomAction extends MiddlewareAction {
  final BuildContext context;
  final Function() connectivityFunction;

  CreateRoomAction(this.context, this.connectivityFunction);

  Future<void> _createRoom(Store<GameModel> store, String code, String appVersion) async {
    Room room = new Room(
        code: code,
        createdAt: now(),
        appVersion: appVersion,
        owner: getPlayerInstallId(store.state),
        numPlayers: store.state.room.numPlayers,
        roles: store.state.room.roles,
        visibleToAccountant: store.state.room.visibleToAccountant);
    String roomId = await store.state.db.upsertRoom(room);
    store.dispatch(new UpdateStateAction<Room>(room.copyWith(id: roomId)));
  }

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    await withRequest(Request.ValidatingRoom, store, (store) async {
      var connectivityResult = await (connectivityFunction());
      if (connectivityResult != ConnectivityResult.none) {
        store.dispatch(new SavePlayerInstallIdAction(await installId()));
        String appVersion = await _getAppVersion();
        String code = await _newRoomCode(store);
        await _createRoom(store, code, appVersion);

        NavigatorState navigatorState = Keys.navigatorKey.currentState;
        if (navigatorState != null) {
          navigatorState.push(new MaterialPageRoute(builder: (context) => new Game(store)));
        }
      } else {
        showNoConnectionDialog(context);
      }
    });
  }

  Future<String> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return '<unknown>';
    }
  }

  int _getCapitalLetterOrdinal(Random random) {
    return random.nextInt(26) + 65; // 65 is 'A' in ASCII
  }

  Future<String> _newRoomCode(Store<GameModel> store) async {
    String code = _generateRoomCode();
    while (await store.state.db.roomExistsWithCode(code)) {
      code = _generateRoomCode();
    }
    return code;
  }

  String _generateRoomCode() {
    Random random = new Random();
    List<int> ordinals =
        new List.generate(4, (i) => _getCapitalLetterOrdinal(random), growable: false);
    return new String.fromCharCodes(ordinals);
  }
}

class CompleteGameAction extends MiddlewareAction {
  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) => withRequest(
      Request.CompletingGame,
      store,
      (store) => store.state.db.completeGame(getRoom(store.state).id));
}

class AddVisibleToAccountantAction extends MiddlewareAction {
  final String playerId;

  AddVisibleToAccountantAction(this.playerId);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return withRequest(Request.SelectingVisibleToAccountant, store,
        (store) => store.state.db.addVisibleToAccountant(getRoom(store.state).id, playerId));
  }
}

class GuessBrendaAction extends MiddlewareAction {
  final String playerId;

  GuessBrendaAction(this.playerId);

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) {
    return withRequest(Request.GuessingBrenda, store,
        (store) => store.state.db.guessBrenda(getRoom(store.state).id, playerId));
  }
}
