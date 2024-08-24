import "package:flutter/material.dart";
import "package:j1_router/router.dart";

/// A function that builds a widget from a [BuildContext] and a [RouteConfig].
typedef RouteBuilder<T extends RouteConfig> = Widget Function(BuildContext, T);

/// A graph that defines the navigation structure of the app. Rather than using this abstract class, consumers should
/// use a pre-built implementation.
///
/// Implementations:
/// - [GoRouter].
abstract class J1RouteGraph {
  final List<J1RouteNode> routes;

  const J1RouteGraph({required this.routes});

  RouterConfig<Object> buildConfig();
}

/// A node of a [J1RouteGraph]. A node consists of a [J1Route], a builder based on the [RouteConfig] for that route,
/// and an optional list of child [J1RouteNode]s.
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
      // This should be unreachable. If you see this error, please ensure that you are providing a generic paramter.
      throw ArgumentError("J1 Router: received an unexpected config: $config. Expecting a config of type: $T.");
      // coverage:ignore-end
    }

    return _builder(context, config);
  }
}
