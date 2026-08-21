import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/view/dialogs/select_direct_stream_provider_dialog.dart';
import 'dart:math';

import 'package:recombox/src/rust/method/metadata_provider/view_content.dart';

class SelectProviderDialog extends StatefulWidget {
  const SelectProviderDialog({
    super.key,
    required this.source,
    required this.viewID,
    this.onApply,
  });

  final Source source;
  final String viewID;
  final Function(SelectedProvider)? onApply;

  @override
  State<SelectProviderDialog> createState() => _SelectProviderDialogState();
}

class _SelectProviderDialogState extends State<SelectProviderDialog> {

  AppColorsScheme appColors = appColorsNotifier.value;
  bool _ready = false;
  List<String> providerList = ["Torrent", "Direct Stream"];
  SelectedProvider selectedProvider = SelectedProvider(type: 0);

  @override
  void initState() {
    super.initState();
    
    initDialog();
  }


  Future<void> initDialog() async {
    ViewContentInfo viewContentInfoResult = await ViewContentInfo.get_(
      source: widget.source.name,
      id: widget.viewID, 
      fromCache: true,
      checkExpire: false,

    );
    setState(() {
      selectedProvider = viewContentInfoResult.selectedProvider??SelectedProvider(type: 0);
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
                  'Set Provider',
                  style: GoogleFonts.nunito(
                    color: appColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight(600),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),

              if (_ready) ...[
                if (providerList.isNotEmpty)
                  RadioGroup<int>(
                    groupValue: selectedProvider.type,
                    
                    onChanged: (value) {
                      setState(() {
                        selectedProvider = SelectedProvider(type: value!);
                      });
                    },
                    // children radios
                    child: Column(
                      children: [
                        for (int i = 0; i < providerList.length; i++)
                          RadioListTile<int>(
                            title: Text(
                              providerList[i],
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                color: appColors.textPrimary,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            value: i,
                            fillColor: WidgetStateProperty.all(appColors.secondary),
                          ),
                        
                      ],
                    ),
                  ),

                if (providerList.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "No provider found",
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
                          if (selectedProvider.type == 0){
                            var ctx = context;
                            await ViewContentInfo.updateSelectedProvider(
                              source: widget.source.name, 
                              id: widget.viewID, 
                              selectedProvider: selectedProvider
                            );
                            widget.onApply?.call(selectedProvider);
                            if (ctx.mounted){
                              Navigator.pop(ctx);
                            }
                          }else{
                            Navigator.pop(context);
                            showDialog(
                              barrierDismissible: false,
                              context: context, 
                              builder: (context){
                                return SelectDirectStreamProviderDialog(
                                  source: widget.source,
                                  viewID: widget.viewID,
                                  onApply: widget.onApply,
                                );
                              }
                            );
                          }
                          
                        },
                        style: ElevatedButton.styleFrom(
                          enabledMouseCursor: SystemMouseCursors.click,
                          backgroundColor: appColors.secondary,
                          foregroundColor: appColors.primary,
                        ),
                        child: Text(
                          selectedProvider.type == 0 ? "Apply" : "Next",
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
