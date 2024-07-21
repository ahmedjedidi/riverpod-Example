import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_exemple/services/services.dart';

import '../models/user.dart';

final userDataProvider = FutureProvider<List<User>>(
  (ref) async => ref.watch(userProvider).getUser(),
);
