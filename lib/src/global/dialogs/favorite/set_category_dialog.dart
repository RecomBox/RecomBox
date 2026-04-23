import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/dialogs/favorite/widgets/set_category_tile.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/rust/method/favorite.dart';
import 'dart:math';

import 'package:recombox/src/rust/method/favorite/get_all_category.dart';
import 'package:recombox/src/rust/method/favorite/get_all_category_by_item_id.dart';
import 'package:recombox/src/rust/method/favorite/get_category_order.dart';

class SetCategoryDialog extends StatefulWidget {
  const SetCategoryDialog({
    super.key,
    required this.source,
    required this.itemId,
    this.onDone
  });

  final Source source;
  final String itemId;
  final Function? onDone;

  @override
  State<SetCategoryDialog> createState() => _SetCategoryDialogState();
}

class _SetCategoryDialogState extends State<SetCategoryDialog> {

  AppColorsScheme appColors = appColorsNotifier.value;
  
  CategoryMap allCategoryMap = CategoryMap(field0: {});
  CategoryMap itemCategoryMap = CategoryMap(field0: {});

  @override
  void initState() {
    super.initState();
    
    initDialog();
  }

  Future<void> initDialog() async {
    // await addCategory(categoryName: "Movies");
    debugPrint(widget.itemId);
    CategoryMap getAllCategoryResult = await getAllCategory();
    CategoryOrderMap getCategoryOrderResult = await getCategoryOrder();
    CategoryMap itemCategoryResult = await getAllCategoryByItemId(
      itemInfo: ItemInfo(
        source: widget.source.name, 
        id: widget.itemId,
      )
    );

    final entriesAllCategoryResult = getAllCategoryResult.field0.entries.toList();

    // -> Sort entries by order map
    entriesAllCategoryResult.sort((a, b) {
      final posA = getCategoryOrderResult.field0[a.key]!;
      final posB = getCategoryOrderResult.field0[b.key]!;
      return posA.compareTo(posB);
    });
    // <-

    setState(() {
      allCategoryMap = CategoryMap(field0: Map.fromEntries(entriesAllCategoryResult));
      itemCategoryMap = itemCategoryResult;
    });

    debugPrint(getAllCategoryResult.toString());
    debugPrint(itemCategoryResult.toString());

  }

  Future<void> onDone() async {
    try{
      CategoryMap itemCategoryResult = await getAllCategoryByItemId(
        itemInfo: ItemInfo(
          source: widget.source.name, 
          id: widget.itemId,
        )
      );
      if (itemCategoryResult.field0.length == itemCategoryMap.field0.length) return;

      if (widget.onDone != null) widget.onDone!();
    }catch(e){
      debugPrint(e.toString());
    }
    
  }

  @override
  Widget build(BuildContext context) {
    
    final allCategoryKeyList = allCategoryMap.field0.keys.toList();
    final allCategoryValueList = allCategoryMap.field0.values.toList();

    return Dialog(
      backgroundColor: appColors.tertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: min(300, MediaQuery.of(context).size.width * 0.9),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                child: Text(
                  'Set categories',
                  style: GoogleFonts.nunito(
                    color: appColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight(600),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),

              if (allCategoryKeyList.isNotEmpty)
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allCategoryKeyList.length,
                    itemBuilder: (context, index) {
                      return SetCategoryTile(
                        key: ValueKey(allCategoryKeyList[index]),
                        selected: itemCategoryMap.field0.containsKey(allCategoryKeyList[index]),
                        source: widget.source,
                        itemId: widget.itemId,
                        categoryID: allCategoryKeyList[index],
                        categoryName: allCategoryValueList[index],
                      );
                    },
                  ),
                ),
              
              if (allCategoryKeyList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "No categories found",
                    style: GoogleFonts.nunito(
                      color: appColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                

              Container(
                padding: EdgeInsets.all(25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.pushNamed(context, "/edit_category");
                      },
                      style: ElevatedButton.styleFrom(
                        enabledMouseCursor: SystemMouseCursors.click,
                        backgroundColor: appColors.secondary,
                        foregroundColor: appColors.primary,
                      ),
                      icon: Icon(Icons.edit),
                      label: Text(
                        "Edit",
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight(600),
                        ),
                      ),
                      
                    ),

                    TextButton(
                      
                      onPressed: (){
                        onDone();
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        enabledMouseCursor: SystemMouseCursors.click,
                      ),
                      child: Text(
                        "Done",
                        style: GoogleFonts.nunito(
                          color: appColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight(600),
                        ),
                      
                      ),
                    ),
                    
                  ],
                ),
              )

              
            
            ],
          ),
        )
      ),
    );
  }
}
