import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ClientIdentity {
  static const String _clientIdKey = 'controllerhub_client_id';

  static Future<String> getClientId() async {
    final preferences =
        await SharedPreferences.getInstance();

    final existing =
        preferences.getString(_clientIdKey);

    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final String clientId =
        const Uuid().v4();

    await preferences.setString(
      _clientIdKey,
      clientId,
    );

    return clientId;
  }
}