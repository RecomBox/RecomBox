import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'package:media_kit/media_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/rust/frb_generated.dart';
import 'package:recombox/src/rust/method/init/init_rest_server.dart';
import 'package:recombox/src/rust/method/init/init_settings.dart';
import 'package:recombox/src/rust/method/init/init_torrent_session.dart';
import 'package:recombox/src/rust/method/init/init_worker.dart';
import 'package:recombox/src/rust/utils/settings.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;



Future<int> getFreePort() async {
  // Bind to port 0 → OS picks an available free port
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = server.port;

  // Close immediately so the port can be reused
  await server.close();

  return port;
}



Future<void> initApp() async {
	WidgetsFlutterBinding.ensureInitialized();
  
  final packageInfo = await PackageInfo.fromPlatform();
  // -> Single Instance
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    if (!(await FlutterSingleInstance().isFirstInstance())) {
      final err = await FlutterSingleInstance().focus();

      if (err != null) {
        debugPrint("Error focusing running instance: $err");
      }
      exit(0);
    }
  }
  // <-

  // -> Hive DB
	WidgetsFlutterBinding.ensureInitialized();
	await Hive.initFlutter();
  
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

  // -> Flutter Rust Bridge Initialization & Settings (Required before starting any other initialization)
	await RustLib.init();
	await initSettings(settings: Settings(
    port: await getFreePort(),
		paths: Paths(
      appSupportDir: (await getApplicationSupportDirectory()).path,
      appCacheDir: (await getApplicationCacheDirectory()).path, 
      tempDir: path.join((await getTemporaryDirectory()).path, packageInfo.packageName),
		)
	));
	// <-

  // -> Torrent Session and Rest Server
  await initTorrentSession();
  initRestServer();
  // <-

  // -> Rust Worker
  await initWorker();
  // <-


	

	// -> Flutter Widgets
	WidgetsFlutterBinding.ensureInitialized();
	// <-

	

  // -> Media Kit
  MediaKit.ensureInitialized();
  // <-
}