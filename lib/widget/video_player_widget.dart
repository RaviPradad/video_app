import 'dart:math';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:video_player/video_player.dart';

import '../utils/utils.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoController;
  bool _videoPlay = false;
  bool _disposed = false;
  int isPlayingIndex = -1;
  Duration? _duration;
  Duration? _position;
  var _progress = 0.0;

  bool intilizing = false;

  bool _initialized = false;
  List<String> _resolutions = [];
  int _selectedResolutionIndex = 0;

  // late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();

    // _videoController = VideoPlayerController.networkUrl(
    //   Uri.parse(
    //       "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
    // )
    //   ..addListener(_onCotrollerUpdate)
    //   ..setLooping(true)
    //   ..initialize().then((_) => _videoController?.play());

    // _chewieController = ChewieController(
    //   VideoPlayerWidgetController: _videoController,
    //   autoPlay: false,
    //   looping: false,
    //   allowFullScreen: false,
    //   materialProgressColors: ChewieProgressColors(
    //     playedColor: Colors.lightGreen, // Customize played color
    //     handleColor: Colors.black, // Customize handle color
    //     backgroundColor: const Color.fromARGB(
    //         255, 193, 188, 188), // Customize background color
    //     bufferedColor: Colors.grey,
    //   ),
    // );
  }

  @override
  void dispose() {
    _videoController?.pause();
    _videoController?.dispose();
    _disposed = true;
    // _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _videoSection(),
            _videoControlSection(),
            const SizedBox(
              height: 10,
            ),
          ],
        ),

        // Chewie(
        //   controller: _chewieController,
        // ),
        // if (widget.enablePlayPause &&
        //     !_isVideoPlaying) // Check if play/pause is enabled
        //   Center(
        //     child: IconButton(
        //       icon: Icon(Icons.play_arrow),
        //       onPressed: () {
        //         setState(() {
        //           _isVideoPlaying = true;
        //         });
        //         _chewieController.play();
        //       },
        //     ),
        //   ),
      ],
    );
  }

  String convertedTwo(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  Widget _videoControlSection() {
    final nowMute = (_videoController?.value.volume ?? 0) > 0;
    final duration = _duration?.inSeconds;
    final head = _position?.inSeconds ?? 0;
    final remained = max(0, duration ?? 0 - head);
    final mins = convertedTwo(remained ~/ 60.0);

    final sec = convertedTwo((remained % 60.0).toInt());
    return Column(
      children: [
        SliderTheme(
            data: SliderTheme.of(context).copyWith(),
            child: Slider(
              value: max(
                0,
                min(_progress * 100, 100),
              ),
              min: 0,
              max: 100,
              divisions: 100,
              label: _position?.toString().split(".")[0],
              onChanged: (value) {
                setState(() {
                  _progress = value * 0.01;
                });
              },
              onChangeStart: (value) {
                _videoController?.pause();
              },
              onChangeEnd: (value) {
                final duration = _videoController?.value.duration;
                if (duration != null) {
                  var newValue = max(0, min(value, 99)) * 0.01;
                  var millis = (duration.inMilliseconds * newValue).toInt();
                  _videoController?.seekTo(Duration(milliseconds: millis));
                  _videoController?.play();
                }
              },
            )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  if (nowMute) {
                    _videoController?.setVolume(0);
                  } else {
                    _videoController?.setVolume(1.0);
                  }
                  setState(() {});
                },
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    child: Icon(nowMute ? Icons.volume_up : Icons.volume_off),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.fast_rewind),
              ),
              IconButton(
                onPressed: () {
                  if (_videoPlay) {
                    _videoController?.pause();
                    setState(() {
                      _videoPlay = false;
                    });
                  } else {
                    _videoController?.pause();
                    setState(() {
                      _videoPlay = true;
                    });
                  }
                },
                icon: Icon(_videoPlay ? Icons.pause : Icons.play_arrow),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.fast_forward),
              ),
              Text("$mins:$sec"),
            ],
          ),
        ),
        const Text("Resolution"),
        DropdownButton<int>(
          value: _selectedResolutionIndex,
          onChanged: (value) {
            if (value != null) _onResolutionChanged(value);
          },
          items: _resolutions
              .asMap()
              .entries
              .map(
                (entry) => DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Future<void> _initializeVideoPlayer() async {
    // Fetch HLS URL from mock API endpoint
    try {
      String hlsUrl = await _fetchHLSUrl();
      final manifest = await HlsPlaylistParser.create()
          .parseString(Uri.parse(hlsUrl), kSAMPLE_MASTER);
      // Parse HLS manifest

      final variants = (manifest as HlsMasterPlaylist).variants;

      _resolutions = variants.map((variant) {
        final videoTrack = variant.format;
        printLog('==>>${videoTrack.width}x${videoTrack.height}<<==');

        return '${videoTrack.width}x${videoTrack.height}';
      }).toList();
      printLog("===>>${variants.first.url}<<==");
      // variants.first.url
      // replace with this url variants.first.url in  VideoPlayerController.networkUrl
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(
            "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
      )
        ..addListener(_onCotrollerUpdate)
        ..setLooping(true)
        ..initialize().then((_) => _videoController?.play());

      // _videoController = VideoPlayerController.networkUrl(Uri.parse(
      //     'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'))
      //   ..initialize().then((_) {
      //     _videoController!
      //       ..addListener(_onCotrollerUpdate)
      //       ..setLooping(true)
      //       ..initialize().then((_) => _videoController?.play());
      //     setState(() {
      //       _initialized = true;
      //     });
      //   });
    } catch (e) {
      printLog("_initializeVideoPlayer||$e");
    }
  }

  Future<String> _fetchHLSUrl() async {
    // please replace url
    return 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
  }

  void _onResolutionChanged(int index) {
    setState(() {
      _selectedResolutionIndex = index;
      _videoController = VideoPlayerController.networkUrl(
          Uri.parse(_videoController!.dataSource))
        ..initialize().then((_) {
          _videoController?.play();
        });
    });
  }

  var _onUpdateControllerTimer;

  void _onCotrollerUpdate() async {
    final controller = _videoController;
    if (_disposed) {
      return;
    }
    if (controller == null) {
      return;
    }
    _onUpdateControllerTimer = 0;
    final now = DateTime.now().microsecondsSinceEpoch;
    if (_onUpdateControllerTimer > now) {
      return;
    }
    _onUpdateControllerTimer = now + 500;

    if (!controller.value.isInitialized) {
      printLog("Not intilized");
      return;
    }
    if (_duration == null) {
      _duration = _videoController!.value.duration;
    }
    var duration = _duration;
    if (duration == null) return;
    var position = await _videoController?.position;
    _position = position;

    _videoPlay = controller.value.isPlaying;
    if (_videoPlay) {
      if (_disposed) return;
      setState(() {
        _progress = position!.inMilliseconds.ceilToDouble();
      });
    }
  }

  Widget _videoSection() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9, //_videoController.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    }
    return const AspectRatio(
        aspectRatio: 16 / 9, child: Center(child: CircularProgressIndicator()));
  }
}
