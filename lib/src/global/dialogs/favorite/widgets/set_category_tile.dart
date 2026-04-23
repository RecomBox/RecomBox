import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/rust/method/favorite.dart';
import 'package:recombox/src/rust/method/favorite/set_category.dart';
import 'package:recombox/src/rust/method/favorite/unset_category.dart';

class SetCategoryTile extends StatefulWidget {
  const SetCategoryTile({
    super.key,
    required this.selected,
    required this.source,
    required this.itemId,
    required this.categoryID,
    required this.categoryName,
  });

  final bool selected;
  final Source source;
  final String itemId;
  final BigInt categoryID;
  final String categoryName;

  @override
  State<SetCategoryTile> createState() => _SetCategoryTileState();
}

class _SetCategoryTileState extends State<SetCategoryTile> {

  AppColorsScheme appColors = appColorsNotifier.value;

  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    isSelected = widget.selected;
  }

  Future<void> onChange(bool value) async {
    try{
      debugPrint(widget.itemId);
      if (value) {
        await setCategory(
          categoryId: widget.categoryID, 
          itemInfo: ItemInfo(
            source: widget.source.name, 
            id: widget.itemId
          )

        );
      }else{
        await unsetCategory(
          categoryId: widget.categoryID, 
          itemInfo: ItemInfo(
            source: widget.source.name, 
            id: widget.itemId
          )
        );
      }
    }catch(e){
      debugPrint(e.toString());
      return;
    }
    
    
    setState(() {
      isSelected = value;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onChange(!isSelected);
        },
        child: Container(
          padding: EdgeInsets.only(left: 15),
          child: Row(
            children: [
              Checkbox(
                mouseCursor: SystemMouseCursors.click,
                fillColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return appColors.secondary;
                    }
                    return Colors.transparent;
                  },
                ),
                side: BorderSide(
                  color: appColors.secondary,
                  width: 2,
                ),
                
                checkColor: appColors.primary,
                value: isSelected,
                onChanged: (value) {
                  onChange(value!);
                },
              ),
              Text(
                widget.categoryName,
                style: GoogleFonts.nunito(
                  color: appColors.textPrimary,
                  fontSize: 16
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        )
      ),
    );
  
  }
}