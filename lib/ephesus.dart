import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelfIO;

typedef EphesusRoute = Response Function(Request request);

class EphesusServer {
  late HttpServer _server;

  EphesusServer({
    required int port,
  }) {
    initServer(port);
  }

  void initServer(int port) async {
    var handler = const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);

    _server = await shelfIO.serve(handler, 'localhost', port);

    // Enable content compression
    _server.autoCompress = true;

    print('Serving at http://${_server.address.host}:${_server.port}');
  }

  final Map<String, Function> _routes = {};

  EphesusServer addRoute({
    required String routePath,
    required EphesusRoute routeHandler,
  }) {
    _routes[routePath] = routeHandler;
    return this;
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
      if (route == request.url.path) {
        final handler = _routes[route];
        return handler!(request);
      }
    }
    return Response.notFound('404 not found.'); //  .ok('Request for "${request.url}"');
  }
}
