import 'dart:convert';

import 'package:flutter_riverpod_exemple/models/user.dart';
import 'package:flutter_riverpod_exemple/services/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements Client {}

class MockResponse extends Mock implements Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  final Client httpClient = MockHttpClient();
  final Response response = MockResponse();
  final ApiServices apiServices = ApiServices(httpClient: httpClient);

  setUpAll(() => registerFallbackValue(FakeUri()));

  setUp(() async {
    when(() => response.statusCode).thenReturn(200);
    when(() => httpClient.get(any())).thenAnswer((_) async => response);
  });

  test('returns a list of users if the http call completes successfully',
      () async {
    when(() => response.body).thenReturn(
      jsonEncode({
        "data": [
          {
            "id": 7,
            "email": "michael.lawson@reqres.in",
            "first_name": "Michael",
            "last_name": "Lawson",
            "avatar": "https://reqres.in/img/faces/7-image.jpg"
          },
          {
            "id": 8,
            "email": "lindsay.ferguson@reqres.in",
            "first_name": "Lindsay",
            "last_name": "Ferguson",
            "avatar": "https://reqres.in/img/faces/8-image.jpg"
          },
        ]
      }),
    );

    final users = await apiServices.getUser();

    expect(users, isA<List<User>>());
    expect(users.length, 2);
    expect(users[0].firstName, "Michael");
    expect(users[1].email, "lindsay.ferguson@reqres.in");
  });
  test('throws an exception if the http call completes with an error',
      () async {
    // Arrange
    when(() => httpClient.get(Uri.parse(
          'https://reqres.in/api/users?page=2',
        ))).thenThrow(Exception());
    // Act & Assert
    expect(apiServices.getUser(), throwsA(isA<Exception>()));
  });
}
