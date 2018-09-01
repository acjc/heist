import 'package:heist/reducers/reducers.dart';
import 'package:redux/redux.dart';

final playerNameReducer =
    combineReducers<String>([new TypedReducer<String, SavePlayerNameAction>(reduce)]);

class SavePlayerNameAction extends Action<String> {
  final String _playerName;

  SavePlayerNameAction(this._playerName);

  @override
  String reduce(String state, action) {
    return _playerName;
  }
}

final playerInstallIdReducer =
    combineReducers<String>([new TypedReducer<String, SavePlayerInstallIdAction>(reduce)]);

class SavePlayerInstallIdAction extends Action<String> {
  final String _installId;

  SavePlayerInstallIdAction(this._installId);

  @override
  String reduce(String state, action) {
    return _installId;
  }
}

final roomCodeReducer =
    combineReducers<String>([new TypedReducer<String, SaveRoomCodeAction>(reduce)]);

class SaveRoomCodeAction extends Action<String> {
  final String _code;

  SaveRoomCodeAction(this._code);

  @override
  String reduce(String state, action) {
    return _code;
  }
}
