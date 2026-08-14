import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:oktoast/oktoast.dart';
import 'package:recombox/src/global/init_app.dart';
import 'package:recombox/src/routes/download/download.dart';
import 'package:recombox/src/routes/edit_category/edit_category.dart';
import 'package:recombox/src/routes/favorite/favorite.dart';
import 'package:recombox/src/routes/search/search.dart';
import 'package:recombox/src/routes/select_file/select_file.dart';
import 'package:recombox/src/routes/select_plugin/select_plugin.dart';
import 'package:recombox/src/routes/select_source/select_source.dart';
import 'package:recombox/src/routes/select_torrent/select_torrent.dart';
import 'package:recombox/src/routes/settings/settings.dart';
import 'package:recombox/src/routes/view/view.dart';
import 'package:recombox/src/routes/watch/watch.dart';
import 'dart:async';
import 'package:recombox/src/global/app_color.dart';
import 'src/routes/home/home.dart';
import 'dart:ui';

// Routes Imports

var logger = Logger();


Future<void> main() async {
  await initApp();
	runApp(const App());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}


class _AppState extends State<App> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      
    });
  }

	@override
	Widget build(BuildContext context) {

		return ValueListenableBuilder<AppColorsScheme>(
			valueListenable: appColorsNotifier,
			builder: (context, colors, _) {
				return  OKToast(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            theme: ThemeData(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: TransitionsBuilder(),
                  TargetPlatform.iOS: TransitionsBuilder(),
                  TargetPlatform.macOS: TransitionsBuilder(),
                  TargetPlatform.windows: TransitionsBuilder(),
                  TargetPlatform.linux: TransitionsBuilder(),
                },
              ),
            ),
            scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.stylus,
              PointerDeviceKind.invertedStylus,
              PointerDeviceKind.unknown, // covers TV remotes / other inputs
            },
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: "/",
          title: 'RecomBox',
          routes: {
              "/": (context) => const HomeScreen(),
              "/search": (context) => const SearchScreen(),
              "/view": (context) => const ViewScreen(),
              "/edit_category": (context) => const EditCategoryScreen(),
              "/select_plugin": (context) => const SelectPluginScreen(),
              "/select_source": (context) => const SelectSourceScreen(),
              "/select_torrent": (context) => const SelectTorrentScreen(),
              "/select_file": (context) => const SelectFileScreen(),
              "/watch": (context) => const WatchScreen(),
              "/favorite": (context) => const FavoriteScreen(),
              "/download": (context) => const DownloadScreen(),
              "/settings": (context) => const SettingsScreen(),
            },
          )
        );
      }
		);
	}
}

class TransitionsBuilder extends PageTransitionsBuilder {
	const TransitionsBuilder();
	
	AppColorsScheme get appColors => appColorsNotifier.value;

	@override
	Widget buildTransitions<T>(
		PageRoute<T> route,
		BuildContext context,
		Animation<double> animation,
		Animation<double> secondaryAnimation,
		Widget child,
	) {
		
		return ColoredBox(
			color: appColors.primary,
			child: child,
		);
	}
}
