import 'package:flutter/material.dart';

final List<Map<String, dynamic>> navigationItems = [
  {'label': 'Home', 'name': 'home', 'route': '/home', 'icon': Icons.home_outlined, 'selectedIcon': Icons.home},
  {'label': 'Favorite', 'name': 'favorite', 'route': '/favorite', 'icon': Icons.favorite_outline_rounded, 'selectedIcon': Icons.favorite_rounded},
  {'label': 'Search', 'name': 'search', 'route': '/search', 'icon': Icons.search, 'selectedIcon': Icons.search},
  {'label': 'Download', 'name': 'download', 'route': '/download', 'icon': Icons.download_outlined, 'selectedIcon': Icons.download_rounded},
  {'label': 'Settings', 'name': 'settings', 'route': '/settings', 'icon': Icons.settings_outlined, 'selectedIcon': Icons.settings_rounded},
];