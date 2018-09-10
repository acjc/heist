import 'package:heist/db/database_model.dart';
import 'package:redux/redux.dart';

import 'reducers.dart';

final hauntReducer = combineReducers<List<Haunt>>([
  new TypedReducer<List<Haunt>, UpdateStateAction<List<Haunt>>>(reduce),
]);
