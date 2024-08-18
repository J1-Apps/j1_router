import "package:equatable/equatable.dart";

/// A route for a page accessible via a router.
class J1Route<T extends RouteConfig> extends Equatable {
  /// The ordered elements of the route's path.
  final List<PathComponent> _parts;

  /// The possible query params for the route.
  final List<QueryParam> _queryParams;

  const J1Route({
    required List<PathComponent> parts,
    List<QueryParam> queryParams = const [],
  })  : _parts = parts,
        _queryParams = queryParams;

  /// Builds a [Uri] for this route from a provided [RouteConfig].
  Uri build({T? config}) => _build(
        pathParams: config?.pathParams ?? const {},
        queryParams: config?.queryParams ?? const {},
      );

  Uri _build({
    Map<String, Object> pathParams = const {},
    Map<String, Object?> queryParams = const {},
  }) {
    final pathBuilder = StringBuffer();
    for (final (index, part) in _parts.indexed) {
      final value = switch (part) {
        PathParam() => part.getValue(pathParams),
        PathSegment() => part.path,
      };

      if (value.endsWith("/") || index >= _parts.length - 1) {
        pathBuilder.write(value);
      } else {
        pathBuilder.write("$value/");
      }
    }

    final queryMap = <String, dynamic>{};
    for (final param in _queryParams) {
      final providedValue = param.getValue(queryParams);
      if (providedValue != null) {
        queryMap[param.key] = providedValue;
      }
    }

    return Uri(path: pathBuilder.toString(), queryParameters: queryMap);
  }

  @override
  List<Object?> get props => [..._parts, ..._queryParams];
}

abstract class RouteConfig extends Equatable {
  const RouteConfig();

  Map<String, Object> get pathParams;
  Map<String, Object?> get queryParams;
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
