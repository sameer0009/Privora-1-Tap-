import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/security/crypto_service.dart';
import '../../core/security/auth_manager.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/contacts_repository.dart';
import '../../data/repositories/chat_repository.dart';

// Base services
final apiClientProvider = Provider((ref) => ApiClient());
final cryptoServiceProvider = Provider((ref) => CryptoService());
final authManagerProvider = Provider((ref) => AuthManager());

// Repositories
final authRepositoryProvider = Provider((ref) {
  final api = ref.watch(apiClientProvider);
  final crypto = ref.watch(cryptoServiceProvider);
  final authManager = ref.watch(authManagerProvider);
  return AuthRepository(api, crypto, authManager);
});

final contactsRepositoryProvider = Provider((ref) {
  final api = ref.watch(apiClientProvider);
  return ContactsRepository(api);
});

final chatRepositoryProvider = Provider((ref) {
  final api = ref.watch(apiClientProvider);
  final crypto = ref.watch(cryptoServiceProvider);
  return ChatRepository(api, crypto);
});
