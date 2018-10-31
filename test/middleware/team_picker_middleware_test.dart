import 'package:heist/db/database_model.dart';
import 'package:heist/middleware/bidding_middleware.dart';
import 'package:heist/middleware/team_picker_middleware.dart';
import 'package:heist/selectors/selectors.dart';
import 'package:heist/state.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  test('test pick and remove player', () async {
    Store<GameModel> store = await initGame();
    String myId = getSelf(store.state).id;

    await handle(store, PickPlayerMiddlewareAction(myId, 1));
    Player onlyTeamMember = currentTeam(store.state).single;
    expect(onlyTeamMember.id, myId);
    expect(onlyTeamMember.name, '_name');

    await handle(store, RemovePlayerMiddlewareAction(myId, 1));
    expect(currentTeam(store.state), isEmpty);
  });

  test('test resolve auction winners', () async {
    Store<GameModel> store = await initGame();
    Player me = getSelf(store.state);

    List<Player> otherPlayers = getOtherPlayers(store.state);
    for (Player player in otherPlayers) {
      await handle(store, new SubmitBidAction(player.id, 9));
    }
    await handle(store, new SubmitBidAction(me.id, 10));

    await handle(store, new ResolveAuctionWinnersAction());
    expect(currentTeam(store.state), containsAll([me, otherPlayers[0]]));
  });
}
