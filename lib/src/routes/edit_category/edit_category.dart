import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/routes/edit_category/dialogs/add_category.dart';
import 'package:recombox/src/routes/edit_category/widgets/edit_category_tile.dart';
import 'package:recombox/src/rust/method/favorite.dart';
import 'package:recombox/src/rust/method/favorite/get_all_category.dart';
import 'package:recombox/src/rust/method/favorite/get_category_order.dart';
import 'package:recombox/src/rust/method/favorite/swap_category_order.dart';
import 'dart:io';

import 'package:recombox/src/global/widgets/title_bar.dart';

Map<int, String> availableSorts = {
  0: "Relevance",
  1: "Rank",
  2: "Release Date",
};

class EditCategoryScreen extends StatefulWidget {
  const EditCategoryScreen({super.key});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategoryScreen> {
  AppColorsScheme appColors = appColorsNotifier.value;

  List<BigInt> allCategoryKeyList = [];
  List<String> allCategoryValueList = [];

  @override
  void initState() {
    super.initState();
    initEditCategoryScreen();
  }

  Future<void> initEditCategoryScreen() async {
    // await addCategory(categoryName: "Anime");

    CategoryMap getAllCategoryResult = await getAllCategory();
    CategoryOrderMap getCategoryOrderResult = await getCategoryOrder();

    final entriesAllCategoryResult = getAllCategoryResult.field0.entries.toList();

    // -> Sort entries by order map
    entriesAllCategoryResult.sort((a, b) {
      final posA = getCategoryOrderResult.field0[a.key]!;
      final posB = getCategoryOrderResult.field0[b.key]!;
      return posA.compareTo(posB);
    });
    // <-

    setState(() {
      allCategoryKeyList = entriesAllCategoryResult.map((e) => e.key).toList();
      allCategoryValueList = entriesAllCategoryResult.map((e) => e.value).toList();
    });

    debugPrint(getAllCategoryResult.toString());
    debugPrint(getCategoryOrderResult.toString());

  }

  @override
  void dispose() {

    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    

    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Row(
            children: [
              Expanded(
                child: Column(
                  spacing: 0,
                  children: [
                    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                      TitleBar(),
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        spacing: 10,
                        children: [
                          IconButton(
                            mouseCursor: SystemMouseCursors.click,
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: appColors.secondary,
                            ),
                          ),
                          Text(
                            'Edit categories',
                            style: GoogleFonts.nunito(
                              color: appColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight(600),
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ),


                    Expanded(
                      child: ReorderableListView(
                        shrinkWrap: true,
                        buildDefaultDragHandles: false,
                        onReorder: (oldIndex, newIndex) async {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final id1 = allCategoryKeyList[oldIndex];
                          final id2 = allCategoryKeyList[newIndex];

                          setState(() {
                            final movedKey = allCategoryKeyList.removeAt(oldIndex);
                            final movedValue = allCategoryValueList.removeAt(oldIndex);
                            allCategoryKeyList.insert(newIndex, movedKey);
                            allCategoryValueList.insert(newIndex, movedValue);
                          });

                          try {
                            await swapCategoryOrder(
                              categoryId1: id1,
                              categoryId2: id2,
                            );
                          } catch (e) {
                            debugPrint(e.toString());
                          }
                        },
                        proxyDecorator: (Widget child, int index, Animation<double> animation) {
                          return Material(
                            color: appColors.tertiary,
                            child: child,
                          );
                        },
                        children: [
                          for (int index = 0; index < allCategoryKeyList.length; index++)
                            ReorderableDragStartListener(
                              key: ValueKey(allCategoryKeyList[index]),
                              index: index,
                              child: EditCategoryTile(
                                categoryID: allCategoryKeyList[index],
                                categoryName: allCategoryValueList[index],
                                initEditCategory: initEditCategoryScreen,
                              ),
                            ),
                        ],
                      )

                    )
                  ],
                ),
              )
            ],
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end, 
            children: [
              FloatingActionButton.extended(
                mouseCursor: SystemMouseCursors.click,
                heroTag: "Add", 
                onPressed: () {
                  showDialog(
                    context: context, 
                    builder: (_) => AddCategoryDialog(
                      onAdd: initEditCategoryScreen
                    )
                  );
                },
                backgroundColor: appColors.accentSecondary,
                icon: Icon(
                  Icons.add,
                  color: appColors.textPrimary,
                ),
                label: Text(
                  "Add",
                  style: GoogleFonts.nunito(
                    color: appColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight(700),
                  ),
                ),
              ),
            ],
          ),
        )
      )
    );
  }
}