import "package:flutter/material.dart";
import "package:get_it/get_it.dart";
import "package:j1_router/router.dart";

final locator = GetIt.instance;

/// A set of extension functions to make routing more convenient.
extension RouterExtensions on BuildContext {
  /// Navigates to the given [route].
  Future<T?> navigate<T extends Object?>(J1Route route) => locator<J1Router>().navigate(this, route);

  /// Pops the top level off the current route, if there is one to pop.
  void pop<T extends Object?>([T? result]) => locator<J1Router>().pop(this, result);

  /// Pops the top level off the current route, if there is one to pop.
  bool canPop() => locator<J1Router>().canPop(this);
}
