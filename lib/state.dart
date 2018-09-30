import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:heist/db/database.dart';
import 'package:heist/db/database_model.dart';

@immutable
class GameModel {
  final FirestoreDb db;
  final Subscriptions subscriptions;

  final String playerInstallId;
  final String playerName;
  final String roomCode;
  final int bidAmount;
  final int giftAmount;

  /// Set of pending requests to avoid kicking off the same request multiple times.
  final Set<Request> requests;

  final LocalActions localActions;

  final Room room;
  final List<Player> players;
  final List<Haunt> haunts;
  final Map<String, List<Round>> rounds;

  GameModel(
      {this.db,
      this.subscriptions,
      this.playerInstallId,
      this.playerName,
      this.roomCode,
      this.bidAmount,
      this.giftAmount,
      this.requests,
      this.localActions,
      this.room,
      this.players,
      this.haunts,
      this.rounds});

  GameModel copyWith(
      {Subscriptions subscriptions,
      String playerInstallId,
      String playerName,
      String roomCode,
      int bidAmount,
      int giftAmount,
      Set<Request> requests,
      LocalActions localActions,
      Room room,
      List<Player> players,
      List<Haunt> heists,
      Map<String, List<Round>> rounds}) {
    return new GameModel(
      db: this.db,
      subscriptions: subscriptions ?? this.subscriptions,
      playerInstallId: playerInstallId ?? this.playerInstallId,
      playerName: playerName ?? this.playerName,
      roomCode: roomCode ?? this.roomCode,
      bidAmount: bidAmount ?? this.bidAmount,
      giftAmount: giftAmount ?? this.giftAmount,
      requests: requests ?? this.requests,
      localActions: localActions ?? this.localActions,
      room: room ?? this.room,
      players: players ?? this.players,
      haunts: heists ?? this.haunts,
      rounds: rounds ?? this.rounds,
    );
  }

  factory GameModel.initial(FirestoreDb db, int numPlayers) => GameModel(
      db: db,
      playerInstallId: null,
      playerName: null,
      roomCode: null,
      bidAmount: 0,
      giftAmount: 0,
      requests: Set(),
      localActions: LocalActions.initial(),
      room: Room.initial(numPlayers),
      players: [],
      haunts: [],
      rounds: {});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameModel &&
          runtimeType == other.runtimeType &&
          db == other.db &&
          subscriptions == other.subscriptions &&
          playerInstallId == other.playerInstallId &&
          playerName == other.playerName &&
          roomCode == other.roomCode &&
          bidAmount == other.bidAmount &&
          giftAmount == other.giftAmount &&
          requests == other.requests &&
          localActions == other.localActions &&
          room == other.room &&
          players == other.players &&
          haunts == other.haunts &&
          rounds == other.rounds;

  @override
  int get hashCode =>
      db.hashCode ^
      subscriptions.hashCode ^
      playerInstallId.hashCode ^
      playerName.hashCode ^
      roomCode.hashCode ^
      bidAmount.hashCode ^
      giftAmount.hashCode ^
      requests.hashCode ^
      localActions.hashCode ^
      room.hashCode ^
      players.hashCode ^
      haunts.hashCode ^
      rounds.hashCode;

  @override
  String toString() {
    return 'GameModel{db: $db, subscriptions: $subscriptions, playerInstallId: $playerInstallId, playerName: $playerName, roomCode: $roomCode, bidAmount: $bidAmount, giftAmount: $giftAmount, requests: $requests, localActions: $localActions, room: $room, players: $players, haunts: $haunts, rounds: $rounds}';
  }
}

@immutable
class Subscriptions {
  final List<StreamSubscription> subs;

  Subscriptions({this.subs});

  Subscriptions copyWith(List<StreamSubscription> subs) {
    return Subscriptions(subs: subs ?? this.subs);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subscriptions && runtimeType == other.runtimeType && subs == other.subs;

  @override
  int get hashCode => subs.hashCode;

  @override
  String toString() {
    return 'Subscriptions{subs: $subs}';
  }
}

@immutable
class LocalActions {
  /// Map of ID -> LocalAction for parts of the UI independent of firestore,
  /// e.g. Round ID -> { round end continue button tapped }
  final Map<String, Set<LocalHauntAction>> localHauntActions;
  final Map<String, Set<LocalRoundAction>> localRoundActions;

  LocalActions({this.localHauntActions, this.localRoundActions});

  factory LocalActions.initial() => LocalActions(
        localHauntActions: {},
        localRoundActions: {},
      );

  LocalActions copyWith({
    Map<String, Set<LocalHauntAction>> localHauntActions,
    Map<String, Set<LocalRoundAction>> localRoundActions,
  }) {
    return new LocalActions(
      localHauntActions: localHauntActions ?? this.localHauntActions,
      localRoundActions: localRoundActions ?? this.localRoundActions,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalActions &&
          runtimeType == other.runtimeType &&
          localHauntActions == other.localHauntActions &&
          localRoundActions == other.localRoundActions;

  @override
  int get hashCode => localHauntActions.hashCode ^ localRoundActions.hashCode;

  @override
  String toString() {
    return 'LocalActions{localHauntActions: $localHauntActions, localRoundActions: $localRoundActions}';
  }
}

enum Request {
  ValidatingRoom,
  CreatingNewRoom,
  JoiningGame,
  SubmittingTeam,
  Bidding,
  Gifting,
  ResolvingAuction,
  CompletingHaunt,
  CompletingRound,
  CompletingGame,
  GuessingBrenda,
  SelectingVisibleToAccountant,
  UpdatingRoles,
  SubmittingRoles
}

enum LocalHauntAction {
  HauntEndContinue,
}

enum LocalRoundAction {
  TeamSelectionContinue,
  RoundEndContinue,
}
