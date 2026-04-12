import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/security/crypto_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/contacts_repository.dart';
import '../../data/repositories/chat_repository.dart';

// Base services
final apiClientProvider = Provider((ref) => ApiClient());
final cryptoServiceProvider = Provider((ref) => CryptoService());

// Repositories
final authRepositoryProvider = Provider((ref) {
  final api = ref.watch(apiClientProvider);
  final crypto = ref.watch(cryptoServiceProvider);
  return AuthRepository(api, crypto);
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
