part of heist;

final requestReducer = combineReducers<Set<Request>>([
  new TypedReducer<Set<Request>, StartRequestAction>(reduce),
  new TypedReducer<Set<Request>, RequestCompleteAction>(reduce),
  new TypedReducer<Set<Request>, ClearAllPendingRequestsAction>(reduce),
]);

class StartRequestAction extends Action<Set<Request>> {

  final Request request;

  StartRequestAction(this.request);

  @override
  Set<Request> reduce(Set<Request> requests, action) {
    Set<Request> updated = new Set.of(requests);
    updated.add(request);
    return updated;
  }
}

class RequestCompleteAction extends Action<Set<Request>> {
  final Request request;

  RequestCompleteAction(this.request);

  @override
  Set<Request> reduce(Set<Request> requests, action) {
    Set<Request> updated = new Set.of(requests);
    updated.remove(request);
    return updated;
  }
}

class ClearAllPendingRequestsAction extends Action<Set<Request>> {
  @override
  Set<Request> reduce(Set<Request> requests, action) {
    return new Set();
  }
}
