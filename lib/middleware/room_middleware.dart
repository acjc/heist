import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:heist/db/database_model.dart';
import 'package:heist/main.dart';
import 'package:heist/reducers/reducers.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:heist/widget/game.dart';
import 'package:package_info/package_info.dart';
import 'package:redux/redux.dart';

import 'middleware.dart';

class CreateRoomAction extends MiddlewareAction {
  Future<String> _createRoom(Store<GameModel> store, String code, String appVersion) {
    return store.state.db.upsertRoom(new Room(
        code: code,
        createdAt: now(),
        appVersion: appVersion,
        owner: getPlayerInstallId(store.state),
        numPlayers: store.state.room.numPlayers,
        roles: store.state.room.roles));
  }

  @override
  Future<void> handle(Store<GameModel> store, action, NextDispatcher next) async {
    String appVersion = await _getAppVersion();
    String code = await _newRoomCode(store);
    String roomId = await _createRoom(store, code, appVersion);
    store.dispatch(new UpdateStateAction<Room>(await store.state.db.getRoom(roomId)));

    NavigatorState navigatorState = navigatorKey.currentState;
    if (navigatorState != null) {
      navigatorState.push(new MaterialPageRoute(builder: (context) => new Game(store)));
    }
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
