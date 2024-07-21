import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_exemple/services/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod_exemple/models/user.dart';
import 'package:flutter_riverpod_exemple/screens/home_page.dart';

// Mock classes for http.Client and http.Response
class MockHttpClient extends Mock implements http.Client {}

class MockHttpResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockHttpClient;
  late MockHttpResponse mockHttpResponse;
  setUpAll(() => registerFallbackValue(FakeUri()));

  setUp(() {
    HttpOverrides.global = null;

    mockHttpClient = MockHttpClient();
    mockHttpResponse = MockHttpResponse();
  });

  testWidgets('HomePage shows loading indicator when loading',
      (WidgetTester tester) async {
    // Arrange
    when(() => mockHttpClient.get(any())).thenAnswer((_) async {
      return Future.delayed(Duration(seconds: 1), () => mockHttpResponse);
    });

    final container = ProviderContainer(
      overrides: [
        httpClientProvider.overrideWithValue(mockHttpClient),
      ],
    );

    // Act
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    // Assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('HomePage shows list of users when data is loaded',
      (WidgetTester tester) async {
    // Arrange
    final mockUsers = [
      User(
          id: 1,
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          avatar: 'https://reqres.in/img/faces/1-image.jpg'),
      User(
          id: 2,
          firstName: 'Jane',
          lastName: 'Doe',
          email: 'jane.doe@example.com',
          avatar: 'https://reqres.in/img/faces/2-image.jpg'),
    ];

    when(() => mockHttpResponse.statusCode).thenReturn(200);
    when(() => mockHttpResponse.body).thenReturn(jsonEncode({
      "data": mockUsers.map((user) => user.toJson()).toList(),
    }));
    when(() => mockHttpClient.get(any()))
        .thenAnswer((_) async => mockHttpResponse);

    final container = ProviderContainer(
      overrides: [
        httpClientProvider.overrideWithValue(mockHttpClient),
      ],
    );

    // Act
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Wait for the future to complete

    // Assert
    expect(find.text('John'), findsOneWidget);
    expect(find.text('Jane'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('HomePage shows error message when an error occurs',
      (WidgetTester tester) async {
    // Arrange
    when(() => mockHttpClient.get(any()))
        .thenAnswer((_) async => http.Response('Not Found', 404));

    final container = ProviderContainer(
      overrides: [
        httpClientProvider.overrideWithValue(mockHttpClient),
      ],
    );

    // Act
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Wait for the future to complete

    // Assert
    expect(find.text('Not Found'), findsOneWidget);
  });
}
