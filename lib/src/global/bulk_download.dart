import 'package:flutter/cupertino.dart';
import 'package:recombox/src/global/types.dart';
import 'package:recombox/src/rust/method/download_provider.dart';
import 'package:recombox/src/rust/method/download_provider/set_download.dart';



class BulkDownloadValue {
  String? linkedTorrentUrl;
  String? linkedFileName;
  BigInt? linkedFileID;
  String? linkedMimeType;

  BulkDownloadValue({this.linkedTorrentUrl, this.linkedFileName, this.linkedFileID, this.linkedMimeType});
}


class BulkDownload {
  Source? source;
  String? id;
  BigInt? seasonIndex;
  Map<BigInt, BulkDownloadValue> _bulkDownloadMap = {};

  BulkDownload({
    this.source, 
    this.id, 
    this.seasonIndex,
    // <EpisodeIndex, BulkDownloadValue>
    Map<BigInt, BulkDownloadValue>? bulkDownloadMap,
  }) {
    if (bulkDownloadMap != null) {
      _bulkDownloadMap = bulkDownloadMap;
    }
  }

  Map<BigInt, BulkDownloadValue> get(){
    return _bulkDownloadMap;
  }

  bool contains(BigInt episodeIndex){
    return _bulkDownloadMap.containsKey(episodeIndex);
  }

  void add(BigInt episodeIndex, BulkDownloadValue value){
    _bulkDownloadMap[episodeIndex] = value;
  }

  void remove(BigInt episodeIndex){
    _bulkDownloadMap.remove(episodeIndex);
  }

  void removeAll(){
    _bulkDownloadMap.clear();
  }

  void display(){
    debugPrint(_bulkDownloadMap.toString());
  }

  int len(){
    return _bulkDownloadMap.length;
  }

  Future<void> submit() async {
    bool unlinkFound = false;

    _bulkDownloadMap.forEach((episodeIndex, value) {
      if ((value.linkedFileID == null) || (value.linkedFileName == null) || (value.linkedTorrentUrl == null) || (value.linkedMimeType == null)){
        unlinkFound = true;
      }
    });

    if (!unlinkFound){
      for (var entry in _bulkDownloadMap.entries){
        await setDownload(
          downloadItemKey: DownloadItemKey(
            source: source!.name, 
            id: id!, 
            seasonIndex: seasonIndex!, 
            episodeIndex: entry.key
          ), 
          downloadItemValue: DownloadItemValue(
            torrentSource: entry.value.linkedTorrentUrl!, 
            fileId: entry.value.linkedFileID!, 
            filePath: entry.value.linkedFileName!, 
            mimeType: entry.value.linkedMimeType!
          )
        );
      }
    }else{
      debugPrint("unlink found!");
    }
  }
}


BulkDownload bulkDownload = BulkDownload();