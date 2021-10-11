import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelfIO;

int calculate() {
  return 6 * 7;
}

Map<String, Function> _routes = {};

typedef EphesusRoute = Response Function(Request request);

void addRoute({
  required String routePath,
  required EphesusRoute routeHandler,
}) {
  _routes[routePath] = routeHandler;
}

void startServer({
  int port = 8080,
}) async {
  var handler = const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);

  var server = await shelfIO.serve(handler, 'localhost', port);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}

Response _echoRequest(Request request) {
  for (var route in _routes.keys) {
    if (route.startsWith(request.url.path)) {
      final handler = _routes[route];
      return handler!(request);
    }
  }
  return Response.notFound('404 not found.'); //  .ok('Request for "${request.url}"');
}
