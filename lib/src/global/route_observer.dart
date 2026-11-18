import 'package:flutter/material.dart';

/// Global route observer so screens (via `RouteAware`) can react when a
/// route above them is popped, e.g. refresh data on `didPopNext`.
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
