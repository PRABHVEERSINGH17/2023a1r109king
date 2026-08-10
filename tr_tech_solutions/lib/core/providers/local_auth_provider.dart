import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True when a device-local account session is active.
final localAuthProvider = StateProvider<bool>((ref) => false);
