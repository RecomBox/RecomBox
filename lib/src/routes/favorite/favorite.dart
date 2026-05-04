import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/favorite/widgets/favorite_content_card.dart';
import 'package:recombox/src/rust/method/favorite.dart';
import 'package:recombox/src/rust/method/favorite/get_all_category.dart';
import 'package:recombox/src/rust/method/favorite/get_all_item_by_category_id.dart';
import 'package:recombox/src/rust/method/favorite/get_category_order.dart';
import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_horizontal.dart';
import 'dart:async';
import 'dart:io';

// -> Local Widgets
import 'package:recombox/src/global/widgets/navigation_bar/navigation_bar_vertical.dart';
import 'package:recombox/src/global/widgets/title_bar.dart';
// <-

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteState();
}

class _FavoriteState extends State<FavoriteScreen> {

  bool isLoading = false;

	int currentCategoryIndex = 0;

  AppColorsScheme appColors = appColorsNotifier.value;
  final TextEditingController _textEditingController = TextEditingController(text: "");
  FocusNode searchFocus = FocusNode();

  CategoryMap categoryMap = CategoryMap(field0: {});
  List<FavoriteItemInfo> favoriteItemInfoList = [];

  Map<int, String> itemTitleMap = {};

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }




  @override
  void initState() {
    super.initState();

    initFavorite();
  }
  

  Future<void> initFavorite({bool fromCache=true}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });
    
    try{
      CategoryOrderMap categoryOrderMapResult = await getCategoryOrder();
      
      CategoryMap categoryMapResult = CategoryMap(
        field0: Map.fromEntries((await getAllCategory()).field0.entries.toList()
          ..sort((a, b) => categoryOrderMapResult.field0[a.key]!.compareTo(categoryOrderMapResult.field0[b.key]!)))
      );


      List<FavoriteItemInfo> favoriteItemInfoListResult = await getAllItemByCategoryId(
        categoryId: categoryMapResult.field0.keys.toList()[currentCategoryIndex],
      );

      debugPrint(favoriteItemInfoListResult.toString());


      setState(() {
        categoryMap = categoryMapResult;
        favoriteItemInfoList = favoriteItemInfoListResult;
      });
    }catch(e){
      debugPrint(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  void onCategoryChange(int index) {
    setState(() {
      currentCategoryIndex = index;
    });

    initFavorite();
  }

  void addTitle( int index, String title) {
    setState(() {
      itemTitleMap[index] = title;
    });
  }

  List<FavoriteItemInfo> onFilterSearch() {
    String query = _textEditingController.text.toLowerCase();
    
    if (query.isEmpty || itemTitleMap.isEmpty) return favoriteItemInfoList;

    List<int> sortedFavoriteItemInfoIndexList = Map.fromEntries(
      itemTitleMap.entries.where((entry) => entry.value.toLowerCase().contains(query))
    ).keys.toList();


    return sortedFavoriteItemInfoIndexList.map((i) => favoriteItemInfoList[i]).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<FavoriteItemInfo> filteredfavoriteItemInfoList = onFilterSearch();

    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 600)
              NavigationBarVertical(
                currentIndex: 2,
              ),
            
            
            Expanded(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                      TitleBar(),
                    // -> Category Bar
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: appColors.strokePrimary
                          )
                        )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [ 
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categoryMap.field0.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  key: ValueKey(categoryMap.field0.values.toList()[index]),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: currentCategoryIndex == index 
                                        ? BorderSide(
                                          width: 1,
                                          color: appColors.accentPrimary
                                        )
                                        : BorderSide.none
                                    )
                                  ),
                                  child: TextButton(
                                    onPressed: () => onCategoryChange(index), 
                                    style: TextButton.styleFrom(
                                      enabledMouseCursor: SystemMouseCursors.click,
                                      backgroundColor: appColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      
                                    ),
                                    child: Text(
                                      categoryMap.field0.values.toList()[index],
                                      style: GoogleFonts.nunito(
                                        color: appColors.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight(500)
                                        
                                      ),
                                      maxLines: 1,
                                    ),
                                  )
                                );
                              },
                            ),
                          ),
                          IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            onPressed: (){
                              Navigator.pushNamed(
                                context, 
                                "/edit_category"
                              );
                            }, 
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 24,
                              color: appColors.secondary,
                            ),
                          )
                        ]
                      )

                    ),

                    // <-
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
                                        onChanged: (_) {
                                          setState(() {
                                            filteredfavoriteItemInfoList = onFilterSearch();
                                          });
                                        },
                                        onSubmitted: (_){
                                          setState(() {
                                            filteredfavoriteItemInfoList = onFilterSearch();
                                          });
                                        },
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
                            onPressed: initFavorite,
                            icon: Icon(
                              Icons.refresh,
                              color: appColors.textPrimary,
                            ),
                          )
                        ]
                      )
                    ),

                    if (favoriteItemInfoList.isEmpty)
                    Expanded(
                      child: Container(
                        height: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "No favorite found inside category",
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),

                    if (favoriteItemInfoList.isNotEmpty)
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(15),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = (constraints.maxWidth / 155).floor();

                              return GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
                                  mainAxisExtent: 320,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1, 
                                ),
                                itemCount: filteredfavoriteItemInfoList.length,
                                itemBuilder: (context, index) {
                                  return FavoriteContentCard(
                                    key: ValueKey(filteredfavoriteItemInfoList[index].id),
                                    addTitle: (String title) {
                                      addTitle(index, title);
                                    },
                                    source: SourceExtension.fromString(filteredfavoriteItemInfoList[index].source), 
                                    id: filteredfavoriteItemInfoList[index].id,
                                  );
                                },
                              );
                            }
                          )
                        ),
                      )
                    
                  ],
                ),
                bottomNavigationBar: (MediaQuery.of(context).size.width < 600)
                  ?  NavigationBarHorizontal(
                      currentIndex: 2,
                    )
                  : null,
              ),
            )
          
          ],
        )
      )
    );
  }
}
