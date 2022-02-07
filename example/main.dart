import 'package:ephesusframework/ephesus.dart';

void main(List<String> arguments) {
  EphesusServer(port: 8080).startServer();
}

@RestController()
class IndexController {
  @GetRoute()
  String get() {
    print('get route');
    return '';
  }

  @PostRoute()
  String create() {
    print('post route');
    return '';
  }
}
