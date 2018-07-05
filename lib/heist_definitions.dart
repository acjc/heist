part of heist;

class HeistDefinition {
  final int numPlayers;
  final int price;

  const HeistDefinition({@required this.numPlayers, @required this.price});
}

/// total players -> { order -> heist }
const Map<int, Map<int, HeistDefinition>> heistDefinitions = {
  2: {
    1: const HeistDefinition(numPlayers: 2, price: 12),
    2: const HeistDefinition(numPlayers: 2, price: 12),
    3: const HeistDefinition(numPlayers: 2, price: 12),
    4: const HeistDefinition(numPlayers: 2, price: 12),
    5: const HeistDefinition(numPlayers: 2, price: 12),
  },
  5: {
    1: const HeistDefinition(numPlayers: 2, price: 12),
    2: const HeistDefinition(numPlayers: 3, price: 12),
    3: const HeistDefinition(numPlayers: 2, price: 12),
    4: const HeistDefinition(numPlayers: 3, price: 12),
    5: const HeistDefinition(numPlayers: 3, price: 12),
  },
  6: {},
  7: {},
  8: {},
  9: {},
  10: {},
};
