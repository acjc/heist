part of heist;

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
    1: const HeistDefinition(numPlayers: 2, price: 12, maximumBid: 5),
    2: const HeistDefinition(numPlayers: 2, price: 12, maximumBid: 5),
    3: const HeistDefinition(numPlayers: 2, price: 12, maximumBid: 5),
    4: const HeistDefinition(numPlayers: 2, price: 12, maximumBid: 5),
    5: const HeistDefinition(numPlayers: 2, price: 12, maximumBid: 5),
  },
  5: {
    1: const HeistDefinition(numPlayers: 2, price: 12, maximumBid: 5),
    2: const HeistDefinition(numPlayers: 3, price: 12, maximumBid: 5),
    3: const HeistDefinition(numPlayers: 2, price: 12, maximumBid: 5),
    4: const HeistDefinition(numPlayers: 3, price: 12, maximumBid: 5),
    5: const HeistDefinition(numPlayers: 3, price: 12, maximumBid: 5),
  },
  6: {},
  7: {},
  8: {},
  9: {},
  10: {},
};
