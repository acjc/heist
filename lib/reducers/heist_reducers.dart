import 'package:heist/db/database_model.dart';
import 'package:redux/redux.dart';

import 'reducers.dart';

final heistReducer = combineReducers<List<Heist>>([
  new TypedReducer<List<Heist>, UpdateStateAction<List<Heist>>>(reduce),
]);
