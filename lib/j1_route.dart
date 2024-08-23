import "package:equatable/equatable.dart";

typedef ConfigParser<T extends RouteConfig> = T Function({
  required Map<String, String> pathParams,
  required Map<String, String> queryParams,
});

/// A route for a page accessible via a router.
class J1Route<T extends RouteConfig> {
  /// The ordered elements of the route's path.
  final List<PathComponent> parts;

  /// The possible query params for the route.
  final List<QueryParam> queryParams;

  /// A function that can parse a set of path and query params into a [RouteConfig].
  final ConfigParser<T> configParser;

  /// The number of path parts that make up the relative path of this route. Defaults to 1.
  final int relativePathParts;

  /// The relative path of this route to its parent route.
  String get relativePath => _buildPath(components: parts.sublist(parts.length - relativePathParts));

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

abstract class RouteConfig {
  Map<String, Object> get pathParams;
  Map<String, Object?> get queryParams;

  const RouteConfig();
}

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

final class PathSegment extends PathComponent {
  final String path;

  const PathSegment(this.path);

  @override
  List<Object?> get props => [path];
}

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

final class QueryParam<T> extends Equatable {
  final String key;
  final T? defaultValue;

  const QueryParam(this.key, this.defaultValue);

  String? getValue(Map<String, Object?> pathParams) {
    final keyedValue = pathParams[key];
    return (keyedValue is T ? keyedValue : defaultValue)?.toString();
  }

  @override
  List<Object?> get props => [key, defaultValue];
}
