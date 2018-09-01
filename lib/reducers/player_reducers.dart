import 'package:heist/db/database_model.dart';
import 'package:heist/reducers/reducers.dart';
import 'package:redux/redux.dart';

final playerReducer = combineReducers<List<Player>>([
  new TypedReducer<List<Player>, UpdateStateAction<List<Player>>>(reduce),
]);
