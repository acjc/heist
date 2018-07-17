part of heist;

final playerReducer = combineReducers<List<Player>>([
  new TypedReducer<List<Player>, UpdateStateAction<List<Player>>>(reduce),
]);

final playerNameReducer = combineReducers<String>([
  new TypedReducer<String, SetPlayerNameAction>(reduce)
]);

class SetPlayerNameAction extends Action<String> {

  final String _playerName;

  SetPlayerNameAction(this._playerName);

  @override
  String reduce(String state, action) {
    return _playerName;
  }
}

final playerInstallIdReducer = combineReducers<String>([
  new TypedReducer<String, SetPlayerInstallIdAction>(reduce)
]);

class SetPlayerInstallIdAction extends Action<String> {

  final String _installId;

  SetPlayerInstallIdAction(this._installId);

  @override
  String reduce(String state, action) {
    return _installId;
  }
}