import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavProvider = StateProvider<int>((ref) => 0);

final bottomNavbarVisibilityProvider = StateProvider<bool>((ref) => true);