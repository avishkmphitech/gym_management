/// Prototype HTTP client placeholder — swap for Dio/http when backend is live.
///
/// All member/trainer/reception data currently comes from Riverpod mock providers.
class ApiClient {
  const ApiClient({this.baseUrl = 'https://api.fitcore.mock/v1'});

  final String baseUrl;

  Future<Map<String, dynamic>> get(String path) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    throw ApiNotConnectedException(
      'GET $path — backend not connected. Prototype uses in-app mock providers.',
    );
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    throw ApiNotConnectedException(
      'POST $path — backend not connected. Prototype uses in-app mock providers.',
    );
  }
}

class ApiNotConnectedException implements Exception {
  ApiNotConnectedException(this.message);
  final String message;

  @override
  String toString() => message;
}

final apiClient = ApiClient();
