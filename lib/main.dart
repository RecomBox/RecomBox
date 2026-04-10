import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recombox/src/routes/edit_category/edit_category.dart';
import 'package:recombox/src/routes/search/search.dart';
import 'package:recombox/src/routes/select_plugin/select_plugin.dart';
import 'package:recombox/src/routes/view/view.dart';
import 'package:recombox/src/rust/frb_generated.dart';
import 'package:recombox/src/rust/method/settings/init_settings.dart';
import 'package:recombox/src/rust/utils/settings.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

import 'package:recombox/src/global/app_color.dart';

import 'src/routes/home/home.dart';

import 'dart:ui';
import 'dart:io';

// Routes Imports

var logger = Logger();

Future<void> main() async {
	// -> Flutter Rust Bridge and Initialization
	await RustLib.init();
	WidgetsFlutterBinding.ensureInitialized();
  initSettings(settings: Settings(
    paths: Paths(
      appSupportDir: (await getApplicationSupportDirectory()).path,
      appCacheDir: (await getApplicationCacheDirectory()).path, 
      tempDir: (await getTemporaryDirectory()).path
    )
  ));
	// <-

	// -> Hive DB
	WidgetsFlutterBinding.ensureInitialized();
	await Hive.initFlutter();

	// <- 

	// -> Flutter Widgets
	WidgetsFlutterBinding.ensureInitialized();
	// <-

	// -> App Colors
	
	var loadAppColors = await AppColorsScheme.load();
	appColorsNotifier.value = loadAppColors;
	var appColors = appColorsNotifier.value;
	// <-
	
	// -> Window Manager
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: appColors.primary,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
	
	// <-

	runApp(const App());
}


class App extends StatelessWidget {
	const App({super.key});
	@override
	Widget build(BuildContext context) {
		return ValueListenableBuilder<AppColorsScheme>(
			valueListenable: appColorsNotifier,
			builder: (context, colors, _) {
				return  MaterialApp(
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
					initialRoute: "/select_plugin",
					title: 'RecomBox',
					routes: {
						"/": (context) => const HomeScreen(),
						"/search": (context) => const SearchScreen(),
						"/view": (context) => const ViewScreen(),
            "/edit_category": (context) => const EditCategoryScreen(),
            "/select_plugin": (context) => const SelectedPluginScreen(),
					},
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