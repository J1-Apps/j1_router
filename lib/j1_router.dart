import "package:flutter/material.dart";

/// A class that handles routing for an app.
abstract class J1Router {
  /// Navigates to the given [route].
  void navigate(BuildContext context, String route);

  /// Pops the top level off the current route, if there is one to pop.
  void pop<T extends Object?>(BuildContext context, [T? result]);

  /// Pops the top level off the current route, if there is one to pop.
  bool canPop(BuildContext context);
}
