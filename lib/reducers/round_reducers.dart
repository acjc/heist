import 'package:heist/db/database_model.dart';
import 'package:redux/redux.dart';

import 'reducers.dart';

final roundReducer = combineReducers<Map<String, List<Round>>>([
  TypedReducer<Map<String, List<Round>>, UpdateStateAction<Map<String, List<Round>>>>(reduce),
]);
