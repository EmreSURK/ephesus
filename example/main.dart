import 'package:ephesusframework/ephesus.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

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
        routePath: 'users/:userID/fav/:commentID',
        routeHandler: singleUserRoute,
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

Response singleUserRoute(Request request) {
  final c = request.context;
  return Response.ok('userRoute ${request.context}');
}
