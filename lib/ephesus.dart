import 'dart:io';
import 'dart:mirrors';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelfIO;

class RestController {
  final String route;
  const RestController({this.route = ''});
}

class GetRoute {
  final String route;
  const GetRoute({this.route = ''});
}

class PostRoute {
  final String route;
  const PostRoute({this.route = ''});
}

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
    parseAnnotedRotes();
    initServer(port);
  }

  void parseAnnotedRotes() {
    // find all classes that uses RestController as aannotion
    var mirrorSystem = currentMirrorSystem();
    mirrorSystem.libraries.forEach((lk, l) {
      l.declarations.forEach((dk, d) {
        if (d is ClassMirror) {
          var cm = d;
          cm.metadata.forEach((md) {
            var metadata = md;
            // if (metadata.type == reflectClass(RestController) && metadata.getField(#id).reflectee == '/313') {
            if (metadata.type == reflectClass(RestController)) {
              print('found: ${cm.simpleName}');
              cm.declarations.forEach((key, value) {
                print(value);
                value.metadata.forEach((methodAnnotion) {
                  if (methodAnnotion.type == reflectClass(GetRoute)) {
                    // get route.
                    print('found a get route. $value ');
                  }
                  if (methodAnnotion.type == reflectClass(PostRoute)) {
                    // get route.
                    print('found a post route. $value ');
                  }
                });
              });
            }
          });
        }
      });
    });

/*     var model = IndexController();

    InstanceMirror mirror = reflect(model);

    // this is Map<Symbol,DeclarationMirror> contains properties (VariableMirrors) ,constructors and methods (MethodMirror) of
    // a Model mirror instance
    var mirrorDeclarations = mirror.type.declarations;

    mirror.invoke(Symbol('get'), []);

    mirrorDeclarations.forEach((symbol, member) {
      print(member is VariableMirror);

      if (member is VariableMirror) {
        print("A List of Instance Mirror of Annotation ${member.metadata}");
        // result:A List of Instance Mirror of Annotation [InstanceMirror on Instance of 'Annotation']

        //find a specific metadata
        InstanceMirror annotation = member.metadata.firstWhere((mirror) => mirror.type.simpleName == #Annotation, orElse: null);
        print("the Instance Mirror of Annotation ${annotation}");
        //result: the Instance Mirror of Annotation InstanceMirror on Instance of 'Annotation'

        //get reflectee, property value, using a Symbol
        print("Annotation param value = ${annotation.getField(#param).reflectee}");
      }
      //result: Annotation param value = value example
    }); */
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
