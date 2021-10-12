import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelfIO;

typedef EphesusRoute = Response Function(EphesusRequest request);

class EphesusRequest extends Request {
  EphesusRequest(String method, Uri requestedUri) : super(method, requestedUri);
  var queryParameters = <String, String>{};
  var urlParameters = <String, String>{};
  var body = <String, String>{};
  var innerDataBag = <String, String>{};
}

class EphesusServer {
  late HttpServer _server;

  EphesusServer({
    required int port,
  }) {
    initServer(port);
  }

  void initServer(int port) async {
    var handler = const Pipeline().addMiddleware(logRequests()).addHandler(_handleRoute);

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
    var handler = const Pipeline().addMiddleware(logRequests()).addHandler(_handleRoute);

    var server = await shelfIO.serve(handler, 'localhost', port);

    // Enable content compression
    server.autoCompress = true;

    print('Serving at http://${server.address.host}:${server.port}');
  }

  Response _handleRoute(Request rawRequest) {
    var request = rawRequest as EphesusRequest;
    var urlParameters = <String, String>{};

    for (var route in _routes.keys) {
      final currentRequestPathParts = request.url.path.split('/');
      final currentRoutePathParts = route.split('/');

      // the request is not for that route.
      if (currentRoutePathParts.length != currentRequestPathParts.length) {
        continue;
      }

      var matchCount = 0;

      for (var i = 0; i < currentRoutePathParts.length; i++) {
        // that should be a parameter.
        final currentRoutePart = currentRoutePathParts[i];
        final currentRequestPart = currentRequestPathParts[i];

        if (currentRoutePart.startsWith(':')) {
          final parameterKey = currentRoutePart.replaceAll(':', '');
          final parameterValue = currentRequestPart;
          urlParameters[parameterKey] = parameterValue;
          matchCount++;
        } else if (currentRoutePart == currentRequestPart) {
          matchCount++;
        }
      }
      request.urlParameters = urlParameters;
      request.body = rawRequest.body;
      // request.queryParameters

      if (matchCount == currentRequestPathParts.length) {
        // that is correct route, congrats! :)
        final handler = _routes[route];
        return handler!(request);
      }
    }
    return Response.notFound('404 not found.'); //  .ok('Request for "${request.url}"');
  }
}
