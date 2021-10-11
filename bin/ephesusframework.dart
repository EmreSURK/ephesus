import 'package:ephesusframework/ephesusframework.dart' as ephesus;
import 'package:shelf/shelf.dart';

void main(List<String> arguments) {
  ephesus.startServer();
  ephesus.addRoute(routePath: 'users', routeHandler: usersRoute);
}

Response usersRoute(Request request) {
  final c = request.context;
  return Response.ok('usersRoute ${request.context}');
}
