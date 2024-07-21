import "dart:convert";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod_exemple/models/user.dart";
import "package:http/http.dart" as http;

final userProvider = Provider<ApiServices>((ref) => ApiServices(
      httpClient: ref.watch(httpClientProvider),
    ));

class ApiServices {
  ApiServices({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final _baseUrl = 'https://reqres.in/api/users?page=2';

  Future<List<User>> getUser() async {
    http.Response response = await _httpClient.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List result = jsonDecode(response.body)["data"];
      return result.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception(response.reasonPhrase);
    }
  }
}

final httpClientProvider = Provider<http.Client>((ref) => http.Client());
