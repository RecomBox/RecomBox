import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:animated_tree_view/tree_view/tree_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';
import 'package:recombox/src/global/app_color.dart';
import 'package:recombox/src/global/bulk_download.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/routes/view/view.dart';
import 'dart:math';




class SubmitBulkDownload extends StatefulWidget {
  const SubmitBulkDownload({
    super.key,
  });


  @override
  State<SubmitBulkDownload> createState() => _SubmitBulkDownloadState();
}

class _SubmitBulkDownloadState extends State<SubmitBulkDownload> {

  AppColorsScheme appColors = appColorsNotifier.value;
  
  TreeNode treeRoot = TreeNode<BulkDownloadValue>.root(data: BulkDownloadValue());
    

  // final TextEditingController _textEditingController = TextEditingController(text: '');
  // FocusNode searchFocus = FocusNode();


  bool isLoading = false;
  bool isInstalling = false;

  @override
  void initState() {
    super.initState();
    
    initDialog();
  }

  Future<void> initDialog({bool forceReload=true}) async {
    if (forceReload){
      setState(() {
        isLoading = true;
      });
    }

    try{

      var newTreeNode = TreeNode<BulkDownloadValue>.root(data: BulkDownloadValue());

      var result = bulkDownload.get();
      result = Map.fromEntries(result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

      result.forEach((episodeIndex, value) {
        final episodeKey = "${bulkDownload.source == Source.anime ? "" : "S${(bulkDownload.seasonIndex!+BigInt.from(1)).toString().padLeft(2,'0')}"}E${(episodeIndex+BigInt.from(1)).toString().padLeft(2,'0')}";

        newTreeNode.addAll([
          TreeNode<BulkDownloadValue>(key: episodeKey, data: value)..expansionNotifier.value = true,
        ]);
      });
      
      if (context.mounted){
        setState(() {
          treeRoot = newTreeNode;
        });
      }
      

    
    }catch(e){
      debugPrint(e.toString());
    }

    
    setState(() {
      isLoading = false;
    });
  }

  Future<void> onSubmitBulkDownload() async {
    final ctx = context;
    setState(() {
      isLoading = true;
    });
    try{
      bool unlinkFound = false;
      BigInt unlinkEpisodeIndex = BigInt.from(0);
      var result = bulkDownload.get();
      result = Map.fromEntries(result.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
      result.forEach((episodeIndex, value) {
        if ((value.linkedFileID == null) || (value.linkedFileName == null) || (value.linkedTorrentUrl == null) || (value.linkedMimeType == null)){
          unlinkFound = true;
          unlinkEpisodeIndex = episodeIndex;
          return;
        }
      });
      if (!unlinkFound){
        try{
          await bulkDownload.submit();
          ViewScreenArguments viewScreenArguments = ViewScreenArguments(
            source: bulkDownload.source!, 
            id: bulkDownload.id!,
          );

          if (ctx.mounted){
            Navigator.pushNamedAndRemoveUntil(
              ctx,
              '/view',
              (route) => false,
              arguments: viewScreenArguments,
            );
          }
        }catch(e){
          debugPrint(e.toString());
        }
        
      }else{
        showToastWidget(
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: appColors.tertiary,
              borderRadius: BorderRadius.circular(25)
            ),
            child: Text(
              'Missing link for ${bulkDownload.source == Source.anime ? "" : "S${(bulkDownload.seasonIndex!+BigInt.from(1)).toString().padLeft(2,'0')}"}E${(unlinkEpisodeIndex+BigInt.from(1)).toString().padLeft(2,'0')}',
              style: GoogleFonts.nunito(
                color: appColors.textPrimary,
                fontSize: 16
              ),
            ),
          ),
          position: ToastPosition.bottom,
          dismissOtherToast: true,
        );
      }

      
    }catch(e){
      debugPrint(e.toString());
    }
    setState(() {
      isLoading = false;
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
        width: min(500, MediaQuery.of(context).size.width * 0.9),
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
                  'Preview Bulk Download',
                  style: GoogleFonts.nunito(
                    color: appColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight(600),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              
              if (isLoading) 
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: appColors.secondary,
                      
                      ),
                    ),
                ),

              if (!isLoading) ...[
                if (treeRoot.children.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "No item to preview",
                      style: GoogleFonts.nunito(
                        color: appColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

                if (treeRoot.children.isNotEmpty) ...[
                  
                  Flexible(
                    child: CustomScrollView(
                      shrinkWrap: true, // Helps inside a Dialog
                      slivers: [
                        SliverTreeView.simple(
                          tree: treeRoot,
                          showRootNode: false,
                          builder: (context, node) {
                            // Note: node.isExpanded is often safer for the UI check
                            return ListTile(
                              title: Text(
                                node.key,
                                style: GoogleFonts.nunito(
                                  color: appColors.textPrimary,
                                  fontSize: 18
                                ),
                              ),
                              
                              subtitle: node.expansionNotifier.value 
                                ? Container(
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('- File ID: ${(node.data as BulkDownloadValue).linkedFileID??"not selected"}',
                                        style: GoogleFonts.nunito(
                                          color: appColors.textSecondary,
                                          fontSize: 16
                                        ),
                                      ),
                                      Text('- Filename: ${(node.data as BulkDownloadValue).linkedFileName??"not selected"}',
                                        style: GoogleFonts.nunito(
                                          color: appColors.textSecondary,
                                          fontSize: 16
                                        ),
                                      ),
                                      Text('- MimeType: ${(node.data as BulkDownloadValue).linkedMimeType??"not selected"}',
                                        style: GoogleFonts.nunito(
                                          color: appColors.textSecondary,
                                          fontSize: 16
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )
                                )
                                : null,
                              contentPadding: EdgeInsets.only(left: node.level * 16.0),
                              leading: Icon(
                                (node.expansionNotifier.value ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                                color: appColors.textPrimary,
                              ),
                              onTap: () {
                                setState(() {
                                  node.expansionNotifier.value = !node.expansionNotifier.value;
                                });
                              },
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              
                
              ],

              Container(
                padding: EdgeInsets.all(25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 15,
                  children: [
                    TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        enabledMouseCursor: SystemMouseCursors.click,
                      ),
                      child: Text(
                        "Close",
                        style: GoogleFonts.nunito(
                          color: appColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight(600),
                        ),
                      ),
                    ),
                    
                    TextButton(
                      onPressed: onSubmitBulkDownload,
                      style: TextButton.styleFrom(
                        enabledMouseCursor: SystemMouseCursors.click,
                      ),
                      child: Text(
                        "Submit",
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
