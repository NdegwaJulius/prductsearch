

import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String name;

  User({required this.name});
}

class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(User(name: "Julius")); // Default name

  void setName(String name) {
    state = User(name: name);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier();
});