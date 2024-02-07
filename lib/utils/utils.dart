import 'package:flutter/foundation.dart';

printLog(log) {
  if (kDebugMode) print("$log");
}

const String kSAMPLE_MASTER = '''
#EXTM3U

#EXT-X-STREAM-INF:BANDWIDTH=1280000,CODECS="mp4a.40.2,avc1.66.30",RESOLUTION=304x128
http://example.com/low.m3u8

#EXT-X-STREAM-INF:BANDWIDTH=1280000,CODECS="mp4a.40.2 , avc1.66.30 "
http://example.com/spaces_in_codecs.m3u8

#EXT-X-STREAM-INF:BANDWIDTH=2560000,FRAME-RATE=25,RESOLUTION=384x160
http://example.com/mid.m3u8

#EXT-X-STREAM-INF:BANDWIDTH=7680000,FRAME-RATE=29.997
http://example.com/hi.m3u8

#EXT-X-STREAM-INF:BANDWIDTH=65000,CODECS="mp4a.40.5"
http://example.com/audio-only.m3u8
''';
