export "go_route_graph.dart";

import "package:flutter/material.dart";
import "package:go_router/go_router.dart" as go;
import "package:j1_router/j1_router.dart";

class GoRouter extends J1Router {
  @override
  void navigate(BuildContext context, String route) => go.GoRouter.of(context).go(route);

  @override
  void pop<T extends Object?>(BuildContext context, [T? result]) => go.GoRouter.of(context).pop(result);

  @override
  bool canPop(BuildContext context) => go.GoRouter.of(context).canPop();
}
