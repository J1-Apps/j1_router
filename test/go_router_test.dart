import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:get_it/get_it.dart";
import "package:j1_router/go_router/go_route_graph.dart";
import "package:j1_router/router.dart";

import "j1_route_test.dart";

final _testRouteGraph = GoRouteGraph(
  routes: [
    J1RouteNode<EmptyRouteConfig>(
      route: homeRoute,
      builder: (context, homeConfig) {
        return Center(
          child: IconButton(
            onPressed: () => context.navigate(
              testRoute.build(
                const TestRouteConfig(
                  path0: "test",
                  path1: true,
                  query0: "testQuery",
                  query1: 42,
                ),
              ),
            ),
            icon: const Icon(Icons.arrow_forward),
          ),
        );
      },
      routes: [
        J1RouteNode<TestRouteConfig>(
          route: testRoute,
          builder: (context, testConfig) {
            return Column(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(context.canPop() ? Icons.arrow_back : Icons.arrow_forward),
                ),
                IconButton(
                  onPressed: () => context.navigate(homeRoute.build(const EmptyRouteConfig())),
                  icon: const Icon(Icons.arrow_downward),
                ),
                Text("path0: ${testConfig.path0}"),
                Text("path1: ${testConfig.path1}"),
                Text("query0: ${testConfig.query0}"),
                Text("query1: ${testConfig.query1}"),
              ],
            );
          },
        ),
      ],
    ),
  ],
);

void main() {
  setUpAll(() {
    GetIt.instance.registerSingleton<J1Router>(GoRouter());
  });

  group("Go Router", () {
    testWidgets("navigates to a route, pops off a route, and handles canPop", (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: _testRouteGraph.buildConfig()));

      final homeNavFinder = find.byIcon(Icons.arrow_forward);
      final testNavFinder0 = find.byIcon(Icons.arrow_back);
      final testNavFinder1 = find.byIcon(Icons.arrow_downward);

      expect(homeNavFinder, findsOneWidget);
      expect(testNavFinder0, findsNothing);

      await tester.tap(homeNavFinder);
      await tester.pumpAndSettle();

      expect(find.text("path0: test"), findsOneWidget);
      expect(find.text("path1: true"), findsOneWidget);
      expect(find.text("query0: testQuery"), findsOneWidget);
      expect(find.text("query1: 42"), findsOneWidget);

      expect(homeNavFinder, findsNothing);
      expect(testNavFinder0, findsOneWidget);

      await tester.tap(testNavFinder0);
      await tester.pumpAndSettle();

      expect(homeNavFinder, findsOneWidget);
      expect(testNavFinder0, findsNothing);

      await tester.tap(homeNavFinder);
      await tester.pumpAndSettle();

      expect(homeNavFinder, findsNothing);
      expect(testNavFinder1, findsOneWidget);

      await tester.tap(testNavFinder1);
      await tester.pumpAndSettle();

      expect(homeNavFinder, findsOneWidget);
      expect(testNavFinder0, findsNothing);
    });
  });
}
