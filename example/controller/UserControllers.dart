import 'package:shelf/shelf.dart';

import '../models/UserModel.dart';

class Usercontrollers {
  Future<List<UserModel>> getUsers() async {
    return [];
  }

  Future<UserModel?> getUser(int userId) async {
    return null;
  }

  Future<UserModel> createUser(UserModel user) async {
    return user;
  }

  void deleteUser(int userId) async {}
}
