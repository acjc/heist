import 'package:flutter/foundation.dart';

const String Scare = 'SCARE';
const String Steal = 'STEAL';
const String Tickle = 'TICKLE';

class HauntDefinition {
  final int numPlayers;
  final int price;
  final int maximumBid;

  const HauntDefinition(
      {@required this.numPlayers, @required this.price, @required this.maximumBid});
}

/// total players -> { order -> haunt }
const Map<int, Map<int, HauntDefinition>> hauntDefinitions = {
  2: {
    1: const HauntDefinition(numPlayers: 2, price: 8, maximumBid: 5),
    2: const HauntDefinition(numPlayers: 2, price: 8, maximumBid: 5),
    3: const HauntDefinition(numPlayers: 2, price: 8, maximumBid: 5),
    4: const HauntDefinition(numPlayers: 2, price: 8, maximumBid: 5),
    5: const HauntDefinition(numPlayers: 2, price: 8, maximumBid: 5),
  },
  3: {
    1: const HauntDefinition(numPlayers: 3, price: 8, maximumBid: 5),
    2: const HauntDefinition(numPlayers: 3, price: 8, maximumBid: 5),
    3: const HauntDefinition(numPlayers: 3, price: 8, maximumBid: 5),
    4: const HauntDefinition(numPlayers: 3, price: 8, maximumBid: 5),
    5: const HauntDefinition(numPlayers: 3, price: 8, maximumBid: 5),
  },
  4: {
    1: const HauntDefinition(numPlayers: 3, price: 8, maximumBid: 5),
    2: const HauntDefinition(numPlayers: 3, price: 8, maximumBid: 5),
    3: const HauntDefinition(numPlayers: 3, price: 8, maximumBid: 5),
    4: const HauntDefinition(numPlayers: 3, price: 8, maximumBid: 5),
    5: const HauntDefinition(numPlayers: 3, price: 8, maximumBid: 5),
  },
  5: {
    1: const HauntDefinition(numPlayers: 2, price: 12, maximumBid: 5),
    2: const HauntDefinition(numPlayers: 3, price: 16, maximumBid: 6),
    3: const HauntDefinition(numPlayers: 2, price: 12, maximumBid: 5),
    4: const HauntDefinition(numPlayers: 3, price: 16, maximumBid: 6),
    5: const HauntDefinition(numPlayers: 3, price: 16, maximumBid: 6),
  },
  6: {
    1: const HauntDefinition(numPlayers: 2, price: 12, maximumBid: 5),
    2: const HauntDefinition(numPlayers: 3, price: 20, maximumBid: 6),
    3: const HauntDefinition(numPlayers: 4, price: 24, maximumBid: 7),
    4: const HauntDefinition(numPlayers: 3, price: 20, maximumBid: 6),
    5: const HauntDefinition(numPlayers: 4, price: 26, maximumBid: 7),
  },
  7: {
    1: const HauntDefinition(numPlayers: 2, price: 12, maximumBid: 5),
    2: const HauntDefinition(numPlayers: 3, price: 20, maximumBid: 6),
    3: const HauntDefinition(numPlayers: 4, price: 24, maximumBid: 7),
    4: const HauntDefinition(numPlayers: 3, price: 20, maximumBid: 6),
    5: const HauntDefinition(numPlayers: 4, price: 26, maximumBid: 7),
  },
  8: {
    1: const HauntDefinition(numPlayers: 3, price: 14, maximumBid: 6),
    2: const HauntDefinition(numPlayers: 4, price: 24, maximumBid: 7),
    3: const HauntDefinition(numPlayers: 4, price: 24, maximumBid: 7),
    4: const HauntDefinition(numPlayers: 5, price: 26, maximumBid: 8),
    5: const HauntDefinition(numPlayers: 5, price: 28, maximumBid: 8),
  },
  9: {},
  10: {},
};
