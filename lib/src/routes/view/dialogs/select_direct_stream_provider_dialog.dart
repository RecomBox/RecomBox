import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/rust/method/direct_stream_provider.dart';
import 'dart:math';

import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';

class SelectDirectStreamProviderDialog extends StatefulWidget {
  const SelectDirectStreamProviderDialog({
    super.key,
    required this.source,
    required this.viewID,
    this.onApply,
  });

  final Source source;
  final String viewID;
  final Function(SelectedProvider)? onApply;

  @override
  State<SelectDirectStreamProviderDialog> createState() => _SelectDirectStreamProviderDialogState();
}

class _SelectDirectStreamProviderDialogState extends State<SelectDirectStreamProviderDialog> {
  bool _ready = false;

  AppColorsScheme appColors = appColorsNotifier.value;
  Map<String, DirectStreamProvider> directStreamProviderMap = {};
  String selectedID = '';
  

  @override
  void initState() {
    super.initState();
    
    initDialog();
  }


  Future<void> initDialog({bool fromCache=true}) async {
    setState(() {
      _ready = false;
    });

    ViewContentInfo viewContentInfoResult = await ViewContentInfo.get_(
      source: widget.source.name,
      id: widget.viewID, 
      fromCache: true,
      checkExpire: false,

    );
    Map<String, DirectStreamProvider> result = await DirectStreamProvider.getAll(
      fromCache: fromCache
    );
    

    setState(() {
      selectedID = viewContentInfoResult.selectedProvider?.id??"";
      directStreamProviderMap = result;
      _ready = true;
    });

  }



  @override
  Widget build(BuildContext context) {
    
    
    return Dialog(
      
      backgroundColor: appColors.tertiary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: 500.0.clamp(
          300.0,
          max(300.0, MediaQuery.of(context).size.width * 0.9),
        ),

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        'Direct Stream',
                        style: GoogleFonts.nunito(
                          color: appColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight(600),
                        ),
                        textAlign: TextAlign.start,
                      ),
                    
                    IconButton(
                      mouseCursor: SystemMouseCursors.click,
                      onPressed: (){
                        initDialog(fromCache: false);
                      },
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: appColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_ready) ...[
                RadioGroup<String>(
                  groupValue: selectedID,
                  onChanged: (value) {
                    setState(() {
                      selectedID = value!;
                    });
                  },
                  child: ListView.builder(
                    shrinkWrap: true, // let it size to content until maxHeight
                    itemCount: directStreamProviderMap.length,
                    itemBuilder: (context, i) {
                      return RadioListTile<String>(
                        title: Row(
                          spacing: 8,
                          children: [
                            Image.network(
                              directStreamProviderMap.values.toList()[i].icon,
                              width: 32,
                              height: 32,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Image failed: $error for ${directStreamProviderMap.values.toList()[i].icon}');
                                return Icon(Icons.broken_image_rounded);
                              },
                            ),

                            Text(
                              directStreamProviderMap.values.toList()[i].title,
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                color: appColors.textPrimary,
                              ),
                              textAlign: TextAlign.start,
                            )
                          ],
                        ),
                        value: directStreamProviderMap.keys.toList()[i],
                        fillColor: WidgetStateProperty.all(appColors.secondary),
                      );
                    },
                  ),
                ),
              
                Container(
                  padding: EdgeInsets.all(25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      

                      TextButton(
                        
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          enabledMouseCursor: SystemMouseCursors.click,
                        ),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.nunito(
                            color: appColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight(600),
                          ),
                        
                        ),
                      ),

                      ElevatedButton(
                        
                        onPressed: ()async{
                          var ctx = context;

                          await ViewContentInfo.updateSelectedProvider(
                            source: widget.source.name, 
                            id: widget.viewID, 
                            selectedProvider: SelectedProvider(type: 1, id: selectedID),
                          );

                          if (ctx.mounted){
                            Navigator.pop(ctx);
                          }

                          widget.onApply?.call(
                            SelectedProvider(type: 1, id: selectedID),
                          );
                          
                        },
                        style: ElevatedButton.styleFrom(
                          enabledMouseCursor: SystemMouseCursors.click,
                          backgroundColor: appColors.secondary,
                          foregroundColor: appColors.primary,
                        ),
                        child: Text(
                          "Apply",
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight(600),
                          ),
                        ),
                        
                      ),
                      
                    ],
                  ),
                )

              ],
              if (!_ready) 
                Container(
                  padding: const EdgeInsets.all(15),
                  child: CircularProgressIndicator(
                    color: appColors.secondary,
                  ),
                ),
            ],
          ),
        )
      ),
    );
  }
}
