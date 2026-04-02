import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/search/widgets/search_card.dart';
import 'package:recombox/src/rust/method/metadata_provider/search_content.dart';
import 'package:recombox/src/widgets/navigation_bar/navigation_bar_horizontal.dart';
import 'package:recombox/src/widgets/navigation_bar/navigation_bar_vertical.dart';
import 'dart:io';

import 'package:recombox/src/widgets/title_bar.dart';

Map<int, String> availableSorts = {
  0: "Relevance",
  1: "Rank",
  2: "Release Date",
};

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchState();
}

class _SearchState extends State<SearchScreen> {
  AppColorsScheme appColors = appColorsNotifier.value;

  List<SearchContentInfo> searchContentResult = [];

  FocusNode searchFocus = FocusNode();

  bool isLoading = false;
  bool noMore = false;

  Source currentSource = Source.anime;
  int currentSortIndex = 0;
  int currentPage = 1;
  String currentSearch = "";

  late TextEditingController _textEditingController;
  final _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: currentSearch);
    _scrollController.addListener(_onScroll);
    setState(() {
      noMore = false;
      searchContentResult = [];
      currentSource = Source.anime;
      currentSortIndex = 0;
      currentPage = 1;
    });
    initSearch();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (isLoading || noMore || currentSearch.isEmpty) return;
    // Check if we've reached (or nearly reached) the bottom
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      currentPage++;
      setState(() {
        isLoading = true;
      });
      initSearch();
    }
  }

  void changeSource(Source source) {
    setState(() {
      noMore = false;
      currentSource = source;
      searchContentResult = [];
      currentPage = 1;
    });
    initSearch();
  }

  void changeSortIndex(int index) {
    setState(() {
      noMore = false;
      currentSortIndex = index;
      searchContentResult = [];
      currentPage = 1;
    });
    debugPrint(currentSortIndex.toString());
    initSearch();
  }

  void onSubmit() {
    setState(() {
      isLoading = true;
      currentSearch = currentSearch.trim();
      noMore = false;
      searchContentResult = [];
      currentPage = 1;
    });
    initSearch();
  }

  Future<void> initSearch() async {
    debugPrint(currentPage.toString());
    if (currentSearch.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      try{
        final result = await searchContent(
            source: currentSource.name.trim(),
            search: currentSearch,
            sort: BigInt.from(currentSortIndex),
            page: BigInt.from(currentPage),
        );
        setState(() {
          noMore = result.isEmpty;
          searchContentResult.addAll(result);
        });
      }catch(e){
        noMore = true;
        debugPrint(e.toString());
      }
    }
    

    setState(() {
      isLoading = false;
    });
    debugPrint(searchContent.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 600)
            NavigationBarVertical(
              currentIndex: 1,
            ),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                spacing: 0,
                children: [
                  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                    TitleBar(),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: appColors.strokePrimary
                        )
                      )
                    ),
                    child:Row(
                      children: [
                        for (final source in Source.values)
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              mouseCursor: SystemMouseCursors.click,
                              onTap: (){
                                changeSource(source);
                              },
                              child: Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  border: currentSource == source
                                    ? Border(
                                      bottom: BorderSide(
                                        color: appColors.accentPrimary,
                                        width: 2,
                                      )
                                    )
                                    : null,
                                ),
                                child: Text(
                                  source.label,
                                  style: TextStyle(
                                    color: appColors.textPrimary,
                                  
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              )
                              
                            ),
                          )
                      ],
                    )
                  ),
                  // -> SearchScreen TextField Widgets
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(right: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: appColors.strokePrimary
                        )
                      )
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: (){
                              searchFocus.requestFocus();
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              height: 60,
                              child: Row(
                                spacing: 8,
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: appColors.textPrimary,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _textEditingController,
                                      onChanged: (value)=>{
                                        currentSearch = value,
                                        if (searchContentResult.isNotEmpty){
                                          setState(() {
                                            searchContentResult = [];
                                            currentPage = 1;
                                            noMore = false;
                                          })
                                        }
                                        
                                      },
                                      onSubmitted: (_) => onSubmit(),
                                      cursorColor: appColors.textPrimary,
                                      focusNode: searchFocus,
                                      style: GoogleFonts.nunito(
                                        fontSize: 24,
                                        color: appColors.textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Search",
                                        hintStyle: TextStyle(
                                          color: appColors.textPrimary,
                                        )
                                      ),
                                    )
                                  )
                                ],
                              )
                            )
                          )
                        ),
                        IconButton(
                          mouseCursor: SystemMouseCursors.click,
                          onPressed: (){

                          },
                          icon: Icon(
                            Icons.refresh,
                            color: appColors.textPrimary,
                          ),
                        )
                      ]
                    )
                  ),
                  // <-
                  Container(
                    padding: EdgeInsets.all(15),
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Row(
                        spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "SORT BY: ",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight(900),
                              fontSize: 15,
                              color: appColors.textSecondary,
                            ),
                          ),
                          for (final entry in availableSorts.entries)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                enabledMouseCursor: SystemMouseCursors.click,
                                disabledMouseCursor: SystemMouseCursors.forbidden,
                                backgroundColor: currentSortIndex == entry.key ? appColors.accentPrimary : Colors.transparent,
                                foregroundColor: appColors.textPrimary,
                                textStyle: GoogleFonts.nunito(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  color: appColors.textPrimary,
                                ),
                                
                              ),
                              onPressed: (){
                                changeSortIndex(entry.key);
                              },
                              child: Text(entry.value),
                            ),
                        ],
                      )
                    )
                    
                  ),
                
                  
                  Expanded(
                    child: (searchContentResult.isEmpty)
                      ? (isLoading)
                          ? Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              color: appColors.secondary,
                            )
                          )
                          : Container(
                            alignment: Alignment.center,
                            child: Text(
                              "Try searching for something.",
                              style: GoogleFonts.nunito(
                                color: appColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight(800)
                              ),
                            ),
                          )
                      : SizedBox(
                        width: double.infinity,
                        child: Scrollbar(
                          controller: _scrollController,
                          thickness: (Platform.isWindows ||
                                  Platform.isLinux ||
                                  Platform.isMacOS)
                              ? null
                              : 0,
                          child: ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: searchContentResult.length,
                            itemBuilder: (context, index) {
                              return SearchCard(searchContentInfo: searchContentResult[index]);
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(width: 18);
                            },
                          )
                        )
                      )
                      
                  )
                  
                ],
              ),
              bottomNavigationBar: ((Platform.isWindows || Platform.isLinux || Platform.isMacOS) && (MediaQuery.of(context).size.width < 600)) 
                ? NavigationBarHorizontal(
                  currentIndex: 1,
                )
                : null
            )
          )
        ],
      )
    );
  }
}