import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:j1_router/router.dart";
import "package:mocktail/mocktail.dart";

import "test_wrapper.dart";

class MockRouter extends Mock implements J1Router {}

class MockRoute extends Mock implements J1Route {}

class MockBuildContext extends Fake implements BuildContext {}

const _homeRoute = J1Route<EmptyRouteConfig>(parts: [PathSegment("/")], configParser: EmptyRouteConfig.parser);

void main() {
  final router = MockRouter();

  setUpAll(() {
    locator.registerSingleton<J1Router>(router);
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(_homeRoute);
  });

  setUp(() {
    reset(router);
  });

  group("Router Extensions", () {
    testWidgets("calls navigate, pop, and canPop", (tester) async {
      when(() => router.navigate(any(), any())).thenAnswer((_) => Future.value("test"));
      when(() => router.pop(any())).thenReturn(null);
      when(() => router.canPop(any())).thenReturn(true);

      await tester.pumpWidget(
        TestWrapper(
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  IconButton(
                    onPressed: () => context.navigate(_homeRoute.build(const EmptyRouteConfig())),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                  IconButton(
                    onPressed: () => context.canPop(),
                    icon: const Icon(Icons.arrow_upward),
                  ),
                ],
              );
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.tap(find.byIcon(Icons.arrow_upward));

      verify(() => router.navigate(any(), any())).called(1);
      verify(() => router.pop(any())).called(1);
      verify(() => router.canPop(any())).called(1);
    });
  });
}
