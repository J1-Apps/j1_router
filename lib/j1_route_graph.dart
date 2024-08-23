import "package:flutter/material.dart";
import "package:j1_router/router.dart";

typedef RouteBuilder<T> = Widget Function(BuildContext, T);

abstract class J1RouteGraph {
  final List<J1RouteNode> routes;

  const J1RouteGraph({required this.routes});

  RouterConfig<Object> buildConfig();
}

final class J1RouteNode<T extends RouteConfig> {
  final J1Route<T> route;
  final RouteBuilder<T> _builder;
  final List<J1RouteNode> routes;

  const J1RouteNode({
    required this.route,
    required RouteBuilder<T> builder,
    this.routes = const [],
  }) : _builder = builder;

  Widget builder(BuildContext context, RouteConfig config) {
    if (config is! T) {
      // coverage:ignore-start
      // This should be unreachable.
      throw ArgumentError("J1 Router: received an unexpected config: $config. Expecting a config of type: $T.");
      // coverage:ignore-end
    }

    return _builder(context, config);
  }
}
