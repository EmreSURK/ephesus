import 'package:ephesusframework/ephesus.dart';
import 'package:shelf/shelf.dart';

void main(List<String> arguments) {
  EphesusServer(port: 8080)
      .addRoute(
        routePath: 'users',
        routeHandler: usersRoute,
      )
      .addRoute(
        routePath: 'user',
        routeHandler: userRoute,
      )
      .addRoute(
        routePath: 'user/:userID',
        routeHandler: userRoute,
      );
}

Response usersRoute(Request request) {
  final c = request.context;
  return Response.ok('usersRoute ${request.context}');
}

Response userRoute(Request request) {
  final c = request.context;
  return Response.ok('userRoute ${request.context}');
}
