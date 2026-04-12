import '../../core/network/api_client.dart';
import '../../domain/models/user_model.dart';

class ContactsRepository {
  final ApiClient _api;

  ContactsRepository(this._api);

  Future<List<UserModel>> getContacts() async {
    try {
      final response = await _api.client.get('/contacts');
      return (response.data as List)
          .map((u) => UserModel.fromJson(u))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<UserModel?> searchUser(String query) async {
    try {
      final response = await _api.client.get('/users/search?q=$query');
      if (response.data != null) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> addContact(String userId) async {
    await _api.client.post('/contacts', data: {'contactId': userId});
  }

  Future<void> removeContact(String userId) async {
    await _api.client.delete('/contacts/$userId');
  }
}
