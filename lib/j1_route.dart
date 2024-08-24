import "package:equatable/equatable.dart";

/// A function that creates a [RouteConfig] from a set of raw path and query params.
///
/// Generally a [RouteConfig] should have a function with a [ConfigParser] signature.
typedef ConfigParser<T extends RouteConfig> = T Function({
  required Map<String, String> pathParams,
  required Map<String, String> queryParams,
});

/// A route for a page accessible via a router. A route is parameterized by a [RouteConfig], which supplies the path
/// and query paramters to the widget builders.
///
/// A default [EmptyRouteConfig] is provided for routes that don't require any paramters.
class J1Route<T extends RouteConfig> {
  final List<PathComponent> parts;
  final List<QueryParam> queryParams;
  final ConfigParser<T> configParser;
  final int relativePathParts;

  /// The relative path of this route to its parent route.
  String get relativePath => _buildPath(components: parts.sublist(parts.length - relativePathParts));

  /// Creates a new page route.
  ///
  /// - [parts] : The ordered elements of the route's path.
  /// - [queryParams] : The possible query params for the route.
  /// - [configParser] : A function that can parse a set of path and query params into a [RouteConfig]. This is usually
  /// defined on the [RouteConfig] itself for convenience.
  /// - [relativePathParts] : The number of path elements that make up the relative path of this route to its parent.
  /// For example, if the parent route is /home then /home/route would have a [relativePathParts] of 1 while
  /// /home/route/test/part would have a [relativePathParts] of 3.
  const J1Route({
    required this.parts,
    this.queryParams = const [],
    required this.configParser,
    this.relativePathParts = 1,
  });

  /// Builds a [String] path for this route from a provided [RouteConfig].
  String build(T config) => _build(
        pathParamMap: config.pathParams,
        queryParamMap: config.queryParams,
      );

  String _build({
    Map<String, Object> pathParamMap = const {},
    Map<String, Object?> queryParamMap = const {},
  }) {
    final pathBuilder = StringBuffer();
    for (final (index, part) in parts.indexed) {
      final value = switch (part) {
        PathParam() => part.getValue(pathParamMap),
        PathSegment() => part.path,
      };

      if (value.endsWith("/") || index >= parts.length - 1) {
        pathBuilder.write(value);
      } else {
        pathBuilder.write("$value/");
      }
    }

    final queryMap = <String, dynamic>{};
    for (final param in queryParams) {
      final providedValue = param.getValue(queryParamMap);
      if (providedValue != null) {
        queryMap[param.key] = providedValue;
      }
    }

    return Uri(
      path: pathBuilder.toString(),
      queryParameters: queryMap.isNotEmpty ? queryMap : null,
    ).toString();
  }
}

String _buildPath({
  required List<PathComponent> components,
  bool useParams = false,
  Map<String, Object>? params,
}) {
  final pathBuilder = StringBuffer();

  for (final (index, part) in components.indexed) {
    final value = switch (part) {
      PathParam() => useParams ? part.getValue(params ?? {}) : ":${part.key}",
      PathSegment() => part.path,
    };

    if (value.endsWith("/") || index >= components.length - 1) {
      pathBuilder.write(value);
    } else {
      pathBuilder.write("$value/");
    }
  }

  return pathBuilder.toString();
}

/// A configuration for a given route. This contains the path and query params in a more human-readable form.
abstract class RouteConfig {
  Map<String, Object> get pathParams;
  Map<String, Object?> get queryParams;

  const RouteConfig();
}

/// A default implementation of an empty [RouteConfig]. This is useful for [J1Route]s that don't have any path or query
/// parameters.
final class EmptyRouteConfig extends RouteConfig {
  @override
  Map<String, Object> get pathParams => const {};

  @override
  Map<String, Object?> get queryParams => const {};

  const EmptyRouteConfig();

  static EmptyRouteConfig parser({
    required pathParams,
    required queryParams,
  }) {
    return const EmptyRouteConfig();
  }
}

sealed class PathComponent extends Equatable {
  const PathComponent();
}

/// A normal segment of a route's path.
final class PathSegment extends PathComponent {
  final String path;

  const PathSegment(this.path);

  @override
  List<Object?> get props => [path];
}

/// A parameterized segment of a route's path.
final class PathParam<T> extends PathComponent {
  final String key;
  final T defaultValue;

  const PathParam(this.key, this.defaultValue);

  String getValue(Map<String, Object?> pathParams) {
    final keyedValue = pathParams[key];
    return (keyedValue is T ? keyedValue : defaultValue).toString();
  }

  @override
  List<Object?> get props => [key, defaultValue];
}

/// A query param that provides optional configuration to a route.
final class QueryParam<T> extends Equatable {
  final String key;
  final T? defaultValue;

  const QueryParam(this.key, this.defaultValue);

  String? getValue(Map<String, Object?> queryParams) {
    final keyedValue = queryParams[key];
    return (keyedValue is T ? keyedValue : defaultValue)?.toString();
  }

  @override
  List<Object?> get props => [key, defaultValue];
}
