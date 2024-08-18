import "package:flutter/material.dart";
import "package:j1_router/router.dart";

/// A class that handles routing for an app.
abstract class J1Router {
  /// Navigates to the given [route].
  Future<T?> navigate<T extends Object?>(BuildContext context, J1Route route);

  /// Pops the top level off the current route, if there is one to pop.
  void pop<T extends Object?>(BuildContext context, [T? result]);

  /// Pops the top level off the current route, if there is one to pop.
  bool canPop(BuildContext context);
}
