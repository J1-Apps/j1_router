import "package:flutter/material.dart";
import "package:go_router/go_router.dart" as go;
import "package:j1_router/router.dart";

class GoRouteGraph extends J1RouteGraph {
  const GoRouteGraph({required super.routes});

  @override
  RouterConfig<Object> buildConfig() {
    return go.GoRouter(routes: routes.map(_buildRoute).toList());
  }
}

go.GoRoute _buildRoute(J1RouteNode node) {
  return go.GoRoute(
    path: node.route.relativePath,
    builder: (context, state) => node.builder(
      context,
      node.route.configParser(
        pathParams: state.pathParameters,
        queryParams: state.uri.queryParameters,
      ),
    ),
    routes: node.routes.map(_buildRoute).toList(),
  );
}
