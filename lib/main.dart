// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/material.dart';
import 'package:recombox/src/rust/frb_generated.dart';

import 'package:recombox/src/rust/api/get_torrent_info.dart';

var logger = Logger();

Future<void> main() async {
	await RustLib.init();

	WidgetsFlutterBinding.ensureInitialized();

	MediaKit.ensureInitialized();

	runApp(const App());
}

class App extends StatelessWidget {
const App({super.key});

// This widget is the root of your application.
@override
Widget build(BuildContext context) {
	return MaterialApp(
		initialRoute: "/",
		title: 'Flutter Demo',
		theme: ThemeData(
			colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
			useMaterial3: true,
		),
		routes: {
			"/": (context) => const MyHomePage(),
			"/2": (context) => const MyHomePage(),
		},
		);
	}
}

class MyHomePage extends StatefulWidget {
const MyHomePage({super.key});

final String title = "RecomBox";

@override
State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	late final player = Player();
	// Create a [VideoController] to handle video output from [Player].
	late final controller = VideoController(player);

	@override
	void initState(){
		super.initState();
		// Play a [Media] or [Playlist].
		
		player.open(Media(
			'https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4'));

		player.pause();
	}

	@override
	void dispose() {
		player.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context)  {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				title: Text(widget.title),
			),
			// body: Center(
			//   child: SizedBox(
			//     width: MediaQuery.of(context).size.width,
			//     height: MediaQuery.of(context).size.width * 9.0 / 16.0,
			//     // Use [Video] widget to display video output.
			//     child: Video(controller: controller),
			//   ),
			// ),

			body: Center(
				child: ElevatedButton(
					onPressed: () async {
						try{
							getTorrentInfo(torrentFile: r"D:\Codes\RecomBox\rust\test4.torrent")
								.then((result){
									logger.i(result.name);
									logger.i(result.files);
								})
								.catchError((e){
									logger.e(e);
								});
						
							
						}catch(e){
							logger.e(e);
						}
						
					},
					child: const Text("Rust TEST"),
				)
			),
		);
	}
}
