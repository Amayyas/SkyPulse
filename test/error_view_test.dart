import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skypulse/services/weather_exception.dart';
import 'package:skypulse/widgets/error_view.dart';

/// The point of these tests is not that the wording is pretty. It is that a
/// failure reaches the user as something they can act on, and that the raw
/// exception text never does.
void main() {
  Future<void> pump(WidgetTester tester, Object error) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(error: error, onRetry: () {}),
        ),
      ),
    );
  }

  group('ErrorView', () {
    testWidgets('an invalid API key says so, and explains the delay', (
      tester,
    ) async {
      await pump(tester, const InvalidApiKeyException());

      expect(find.text('Clé API invalide'), findsOneWidget);
      expect(find.textContaining('deux heures'), findsOneWidget);
    });

    testWidgets('an unknown city names the city that was searched for', (
      tester,
    ) async {
      await pump(tester, const CityNotFoundException('Zzzzzz'));

      expect(find.textContaining('Zzzzzz'), findsOneWidget);
    });

    testWidgets('a rate limit tells the user to wait', (tester) async {
      await pump(tester, const RateLimitException());

      expect(find.text('Trop de requêtes'), findsOneWidget);
    });

    testWidgets('a dead network is named as such', (tester) async {
      await pump(tester, const NoConnectionException('Failed host lookup'));

      expect(find.text('Pas de connexion'), findsOneWidget);
    });

    testWidgets('a server error is not blamed on the user', (tester) async {
      await pump(tester, const WeatherApiException(503));

      expect(find.textContaining('503'), findsOneWidget);
      expect(find.textContaining('pas de votre fait'), findsOneWidget);
    });

    testWidgets('an unknown error degrades to a generic message', (
      tester,
    ) async {
      await pump(tester, StateError('some internal failure'));

      expect(find.text('Une erreur est survenue'), findsOneWidget);
    });

    // The screen used to render `Text('Erreur de chargement: $error')`, which
    // produced things like `ClientException: Failed host lookup:
    // 'api.openweathermap.org'`. Meaningless to a user, and it leaks internals.
    testWidgets('the raw exception text is never rendered', (tester) async {
      const errors = <WeatherException>[
        InvalidApiKeyException(),
        CityNotFoundException('Paris'),
        RateLimitException(),
        NoConnectionException('Failed host lookup: api.openweathermap.org'),
        WeatherApiException(500),
        MalformedResponseException('type cast failed at main.temp'),
      ];

      for (final error in errors) {
        await pump(tester, error);

        expect(
          find.textContaining(error.message),
          findsNothing,
          reason: 'the technical message of $error leaked into the UI',
        );
        expect(
          find.textContaining('Exception'),
          findsNothing,
          reason: 'an exception class name leaked into the UI for $error',
        );
      }
    });

    testWidgets('every failure offers a way out', (tester) async {
      var retried = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              error: const NoConnectionException('offline'),
              onRetry: () => retried++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Réessayer'));
      expect(retried, 1);
    });
  });
}
