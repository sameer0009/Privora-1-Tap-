import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_model.dart';
import '../../data/repositories/contacts_repository.dart';
import 'base_providers.dart';

class ContactsState {
  final List<UserModel> contacts;
  final bool isLoading;
  final String? error;

  ContactsState({this.contacts = const [], this.isLoading = false, this.error});
}

class ContactsNotifier extends Notifier<ContactsState> {
  @override
  ContactsState build() => ContactsState();

  Future<void> getContacts() async {
    state = ContactsState(contacts: state.contacts, isLoading: true);
    try {
      final repository = ref.read(contactsRepositoryProvider);
      final contacts = await repository.getContacts();
      state = ContactsState(contacts: contacts, isLoading: false);
    } catch (e) {
      state = ContactsState(contacts: state.contacts, isLoading: false, error: e.toString());
    }
  }

  Future<void> addContact(String userId) async {
    try {
      final repository = ref.read(contactsRepositoryProvider);
      await repository.addContact(userId);
      await getContacts();
    } catch (e) {
      state = ContactsState(contacts: state.contacts, isLoading: false, error: e.toString());
    }
  }

  Future<UserModel?> searchUser(String query) async {
    final repository = ref.read(contactsRepositoryProvider);
    return await repository.searchUser(query);
  }
}

final contactsProvider = NotifierProvider<ContactsNotifier, ContactsState>(ContactsNotifier.new);
