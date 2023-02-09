import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying(
      {Key? key, required this.songModel, required this.audioPlayer})
      : super(key: key);
  final SongModel songModel;
  final AudioPlayer audioPlayer;

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  Duration _duration = const Duration();
  Duration _position = const Duration();

  bool _isPlaying = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playSong();
  }

  void playSong() {
    try {
      widget.audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(widget.songModel.uri!)));
      widget.audioPlayer.play();
      _isPlaying = true;
    } on Exception {
      log("Cannot parse song");
    }
    widget.audioPlayer.durationStream.listen((d) {
      setState(() {
        _duration = d!;
      });
    });
    widget.audioPlayer.positionStream.listen((p) {
      setState(() {
        _position = p;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              const SizedBox(
                height: 100.0,
              ),
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      radius: 100.0,
                      child: Icon(
                        Icons.music_note,
                        color: Colors.black,
                        size: 80.0,
                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      widget.songModel.displayNameWOExt,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 30.0),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      widget.songModel.artist.toString() == "<unknown>"
                          ? "Unknown"
                          : widget.songModel.artist.toString(),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    Row(
                      children: [
                        Text(_position.toString().split(".")[0]),
                        Expanded(
                          child: Slider(
                            min:const Duration(microseconds: 0).inSeconds.toDouble(),
                            value: _position.inSeconds.toDouble(),
                            max: _duration.inSeconds.toDouble(),
                            onChanged: (value) {
                              if((value - _position.inSeconds.toDouble()).abs() > 1) {
                                setState(() {
                                  changeToSeconds(value.toInt());
                                  _position = Duration(seconds: value.toInt());
                                });
                              }
                            },
                          ),

                        ),
                        Text(_duration.toString().split(".")[0]),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.skip_previous,
                              size: 40.0,
                            )),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                if (_isPlaying) {
                                  widget.audioPlayer.pause();
                                } else {
                                  widget.audioPlayer.play();
                                }
                                _isPlaying = !_isPlaying;
                              });
                            },
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 40.0,
                            )),
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.skip_next,
                              size: 40.0,
                            ))
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void changeToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }

}