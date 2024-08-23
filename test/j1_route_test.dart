import "package:flutter_test/flutter_test.dart";
import "package:j1_router/router.dart";

final class TestRouteConfig extends RouteConfig {
  final String path0;
  final bool path1;
  final String? query0;
  final int? query1;

  @override
  Map<String, Object> get pathParams => {
        "path0": path0,
        "path1": path1,
      };

  @override
  Map<String, Object?> get queryParams => {
        if (query0 != null) "query0": query0,
        if (query1 != null) "query1": query1,
      };

  const TestRouteConfig({
    required this.path0,
    required this.path1,
    this.query0,
    this.query1,
  });

  static TestRouteConfig parser({
    required pathParams,
    required queryParams,
  }) {
    return TestRouteConfig(
      path0: pathParams["path0"] ?? "default",
      path1: bool.tryParse(pathParams["path1"] ?? "") ?? false,
      query0: queryParams["query0"],
      query1: int.tryParse(queryParams["query1"] ?? ""),
    );
  }
}

const testRoute = J1Route<TestRouteConfig>(
  parts: [
    PathSegment("/"),
    PathSegment("test0"),
    PathParam<String>("path0", "default0"),
    PathSegment("test1"),
    PathParam<bool>("path1", false),
    PathSegment("test2"),
  ],
  queryParams: [
    QueryParam<String>("query0", "default2"),
    QueryParam<int>("query1", null),
  ],
  configParser: TestRouteConfig.parser,
  relativePathParts: 5,
);

const homeRoute = J1Route<EmptyRouteConfig>(
  parts: [PathSegment("/")],
  configParser: EmptyRouteConfig.parser,
);

void main() {
  group("J1 Route", () {
    test("builds a home route", () {
      final path = homeRoute.build(const EmptyRouteConfig());
      expect(path, "/");
    });

    test("builds a route from a config", () {
      final path = testRoute.build(
        const TestRouteConfig(
          path0: "testPath0Value",
          path1: true,
          query0: "testQuery0Value",
          query1: 10,
        ),
      );

      expect(path, "/test0/testPath0Value/test1/true/test2?query0=testQuery0Value&query1=10");
    });

    test("compares route classes", () {
      const otherRoute = J1Route<EmptyRouteConfig>(parts: [PathSegment("/")], configParser: EmptyRouteConfig.parser);
      expect(homeRoute == otherRoute, true);
      expect(testRoute == homeRoute, false);

      expect(const PathSegment("/") == const PathSegment("/"), true);
      expect(const PathSegment("/") == const PathSegment("/home"), false);

      expect(const PathParam("param", "default") == const PathParam("param", "default"), true);
      expect(const PathParam("param", "default") == const PathParam("param", "default0"), false);

      expect(const QueryParam("param", "default") == const QueryParam("param", "default"), true);
      expect(const QueryParam("param", "default") == const QueryParam("param", "default0"), false);
    });
  });
}
