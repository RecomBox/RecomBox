import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/rust/method/metadata_provider/featured_content.dart';
import 'package:recombox/src/rust/method/metadata_provider/trending_content.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:recombox/src/rust/method/settings/get_settings.dart';
import 'package:recombox/src/rust/method/settings/set_settings.dart';
import 'package:recombox/src/rust/utils/settings.dart';
import 'package:url_launcher/url_launcher.dart';



class EntryScreen extends StatefulWidget {
  const EntryScreen({
    super.key,
    this.verifySavedToken
  });

  final bool? verifySavedToken;

  @override
  State<EntryScreen> createState() => _EntryState();
}

class _EntryState extends State<EntryScreen> {

  bool isLoading = true;

	List<FeaturedContentInfo> featuredContentList = [];
	Map<Source, List<TrendingContentInfo>> trendingContentMap = {};

  TextEditingController _textEditingController = TextEditingController();

  AppColorsScheme appColors = appColorsNotifier.value;

  String tmdbToken = "";
  bool isVerifyingToken = false;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init({bool fromCache=true}) async {
    var ctx = context;
    setState(() {
      isLoading = true;
    });
    Settings settings = await getSettings();

    String? savedToken = settings.tmdbRatToken;

    if (savedToken != null && savedToken.isNotEmpty && ctx.mounted) {
      if (widget.verifySavedToken??false){
        setState(() {
          isLoading = false;
        });
        _textEditingController.text = savedToken;
        onVerifyToken(savedToken);
      }else{
        Navigator.pushReplacementNamed(ctx, '/home');
      }
    }else{
      setState(() {
        isLoading = false;
      });
    }

    
  }

  void onVerifyToken(String token) async {
    var ctx = context;
    setState(() {
      isVerifyingToken = true;
    });
    final url = Uri.parse("https://api.themoviedb.org/3/authentication");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json;charset=utf-8",
      },
    );
    Settings settings = await getSettings();

    if (response.statusCode == 200) {
      showToastWidget(
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: appColors.tertiary,
            borderRadius: BorderRadius.circular(25)
          ),
          child: Text(
            "Token verified successfully",
            style: GoogleFonts.nunito(
              color: appColors.textPrimary,
              fontSize: 16
            ),
          ),
        ),
        position: ToastPosition.bottom,
        dismissOtherToast: true,
      );
      
      
      if (settings.tmdbRatToken != token) {
        Settings newSettings = settings.copyWith(tmdbRatToken: token);
        await setSettings(settings: newSettings);
      }
      
      if (context.mounted) {
        Navigator.pushReplacementNamed(ctx, '/home');
      }
    } else {
      showToastWidget(
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: appColors.tertiary,
            borderRadius: BorderRadius.circular(25)
          ),
          child: Text(
            "Invalid token. Please try again",
            style: GoogleFonts.nunito(
              color: appColors.textPrimary,
              fontSize: 16
            ),
          ),
        ),
        position: ToastPosition.bottom,
        dismissOtherToast: true,
      );
      Settings newSettings = settings.copyWith(tmdbRatToken: null);
      await setSettings(settings: newSettings);
      
      setState(() {
        isVerifyingToken = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SafeArea(
        child: Material(
          color: appColors.primary,
          child: Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              color: appColors.secondary,
            )
          )
        )
      );
    }else{
      return SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            
            child: Column(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    'assets/tmdb_logo.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.fill
                  ),
                ),
                
                Text(
                  "TMDB Read Access Token is required",
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    color: appColors.textPrimary,
                    fontWeight: FontWeight(700)
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  width: min(600, double.infinity),
                  child: TextField(
                    controller: _textEditingController,
                    enabled: !isVerifyingToken,
                    obscureText: true, // hides the input
                    decoration: InputDecoration(
                      hintText: "Enter your token",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: appColors.secondary,
                    ),
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    onChanged: (value) {
                      tmdbToken = value;
                    },
                    onSubmitted: (value) {
                      if (isVerifyingToken || tmdbToken.isEmpty) return;
                      onVerifyToken(tmdbToken);
                    },
                  ),
                ),

                
                SizedBox(
                  width: min(500, double.infinity),
                  child: ElevatedButton(
                    
                    onPressed: (){
                      if (isVerifyingToken || tmdbToken.isEmpty) return;
                      onVerifyToken(tmdbToken);
                    }, 
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      backgroundColor: Colors.purple,
                      enabledMouseCursor: SystemMouseCursors.click
                    ),
                    
                    child: Text(
                      isVerifyingToken ? "Verifying..." : "Verify Token",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        color: appColors.textPrimary,
                        fontWeight: FontWeight(700),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ),

                TextButton(
                  onPressed: (){
                    String url = "https://www.themoviedb.org/settings/api";
                    Clipboard.setData(ClipboardData(text: url));
                    showToastWidget(
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: appColors.tertiary,
                          borderRadius: BorderRadius.circular(25)
                        ),
                        child: Text(
                          "URL copied to clipboard",
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 16
                          ),
                        ),
                      ),
                      position: ToastPosition.bottom,
                      dismissOtherToast: true,
                    );
                    launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.platformDefault,
                    )
                      .then((value) => debugPrint(value.toString()))
                      .catchError((error) => debugPrint(error.toString()));
                  }, 
                  style: ButtonStyle(
                    mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
                  ),
                    child: Text(
                    "Get Token Here",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: appColors.textSecondary,
                      fontWeight: FontWeight(700),
                      decoration: TextDecoration.underline,
                      decorationColor: appColors.textSecondary,
                      decorationThickness: 2.5,
                    ),
                  
                    textAlign: TextAlign.center,
                  ),
                ),

              ],
            )
          )
        )
      );
    }
  }
}
