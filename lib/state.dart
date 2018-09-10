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

  /// List of pending requests to avoid kicking off the same request multiple times.
  final Set<Request> requests;

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
      requests: new Set(),
      room: new Room.initial(numPlayers),
      players: [],
      haunts: [],
      rounds: {});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameModel &&
          subscriptions == other.subscriptions &&
          playerInstallId == other.playerInstallId &&
          playerName == other.playerName &&
          roomCode == other.roomCode &&
          bidAmount == other.bidAmount &&
          giftAmount == other.giftAmount &&
          requests == other.requests &&
          room == other.room &&
          players == other.players &&
          haunts == other.haunts &&
          rounds == other.rounds;

  @override
  int get hashCode =>
      subscriptions.hashCode ^
      playerInstallId.hashCode ^
      playerName.hashCode ^
      roomCode.hashCode ^
      bidAmount.hashCode ^
      giftAmount.hashCode ^
      requests.hashCode ^
      room.hashCode ^
      players.hashCode ^
      haunts.hashCode ^
      rounds.hashCode;

  @override
  String toString() {
    return 'GameModel{db: $db, subscriptions: $subscriptions, playerInstallId: $playerInstallId, playerName: $playerName, roomCode: $roomCode, bidAmount: $bidAmount, giftAmount: $giftAmount, requests: $requests, room: $room, players: $players, heists: $haunts, rounds: $rounds}';
  }
}

@immutable
class Subscriptions {
  final List<StreamSubscription> subs;

  Subscriptions({this.subs});

  Subscriptions copyWith(List<StreamSubscription> subs) {
    return new Subscriptions(subs: subs ?? this.subs);
  }
}

enum Request {
  ValidatingRoom,
  CreatingNewRoom,
  JoiningGame,
  Bidding,
  Gifting,
  ResolvingAuction,
  CompletingHeist,
  CompletingRound,
  CompletingGame,
  GuessingBrenda,
  SelectingVisibleToAccountant,
}
