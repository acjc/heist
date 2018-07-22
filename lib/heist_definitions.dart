import 'package:flutter/foundation.dart';

const String Succeed = 'SUCCEED';
const String Steal = 'STEAL';
const String Fail = 'FAIL';

class HeistDefinition {
  final int numPlayers;
  final int price;
  final int maximumBid;

  const HeistDefinition(
      {@required this.numPlayers, @required this.price, @required this.maximumBid});
}

/// total players -> { order -> heist }
const Map<int, Map<int, HeistDefinition>> heistDefinitions = {
  2: {
    1: const HeistDefinition(numPlayers: 2, price: 8, maximumBid: 5),
    2: const HeistDefinition(numPlayers: 2, price: 8, maximumBid: 5),
    3: const HeistDefinition(numPlayers: 2, price: 8, maximumBid: 5),
    4: const HeistDefinition(numPlayers: 2, price: 8, maximumBid: 5),
    5: const HeistDefinition(numPlayers: 2, price: 8, maximumBid: 5),
  },
  3: {
    1: const HeistDefinition(numPlayers: 3, price: 8, maximumBid: 5),
    2: const HeistDefinition(numPlayers: 3, price: 8, maximumBid: 5),
    3: const HeistDefinition(numPlayers: 3, price: 8, maximumBid: 5),
    4: const HeistDefinition(numPlayers: 3, price: 8, maximumBid: 5),
    5: const HeistDefinition(numPlayers: 3, price: 8, maximumBid: 5),
  },
  5: {
    1: const HeistDefinition(numPlayers: 2, price: 12, maximumBid: 5),
    2: const HeistDefinition(numPlayers: 3, price: 16, maximumBid: 6),
    3: const HeistDefinition(numPlayers: 2, price: 12, maximumBid: 5),
    4: const HeistDefinition(numPlayers: 3, price: 16, maximumBid: 6),
    5: const HeistDefinition(numPlayers: 3, price: 16, maximumBid: 6),
  },
  6: {
    1: const HeistDefinition(numPlayers: 2, price: 12, maximumBid: 5),
    2: const HeistDefinition(numPlayers: 3, price: 20, maximumBid: 6),
    3: const HeistDefinition(numPlayers: 4, price: 24, maximumBid: 7),
    4: const HeistDefinition(numPlayers: 3, price: 20, maximumBid: 6),
    5: const HeistDefinition(numPlayers: 4, price: 24, maximumBid: 7),
  },
  7: {
    1: const HeistDefinition(numPlayers: 2, price: 14, maximumBid: 5),
    2: const HeistDefinition(numPlayers: 3, price: 22, maximumBid: 6),
    3: const HeistDefinition(numPlayers: 4, price: 26, maximumBid: 7),
    4: const HeistDefinition(numPlayers: 3, price: 22, maximumBid: 6),
    5: const HeistDefinition(numPlayers: 4, price: 26, maximumBid: 7),
  },
  8: {},
  9: {},
  10: {},
};
