import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:runomusic/Models/track.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:runomusic/widgets/ArtistView.dart';
import '../constants/constants.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/album.dart';
import '../pages/albumLayout.dart';

class MusicPlayer extends StatefulWidget {
  final Track currentSong;
  MusicPlayer(this.currentSong);
  int x = 0;
  Duration newDuration = Duration.zero;
  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  void converter(x) {
    x = widget.currentSong.playbackSeconds;
    widget.newDuration = Duration(seconds: x);
  }

  Album albuminstance = Album(
      id: "",
      albumArtistName: "",
      artistUrl: "",
      albumTracksCount: 0,
      albumUrl: "",
      name: "",
      releasedDate: "",
      imageUrl: "");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAlbum();
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (this.mounted)
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
    });

    audioPlayer.onDurationChanged.listen((x) {
      if (this.mounted)
        setState(() {
          duration = x;
        });
    });
    audioPlayer.onPositionChanged.listen((newPos) {
      if (this.mounted)
        setState(() {
          position = newPos;
        });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    audioPlayer.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigets(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigets(duration.inHours);
    final minutes = twoDigets(duration.inMinutes.remainder(60));
    final seconds = twoDigets(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(":");
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              InkWell(
                  onTap: () async {
                    await audioPlayer.pause();
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AlbumLayout(albuminstance)));
                },
                child: Center(
                  child: Text(
                    widget.currentSong.albumName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                  child: widget.currentSong.imageUrl != ""
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(widget.currentSong.imageUrl,
                              fit: BoxFit.fitHeight, width: 350, height: 390),
                        )
                      : Container(
                          height: 250,
                          width: 250,
                          child: SpinKitRing(
                            color: widgetColor,
                            size: 50,
                          ),
                        )),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    widget.currentSong.trackName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ArtistView(
                                "https://api.napster.com/v2.2/artists/${widget.currentSong.artistId}")));
                  },
                  child: Center(
                    child: Text(
                      widget.currentSong.artistName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Icon(
                    Icons.first_page_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: Icon(
                      Icons.forward_10_rounded,
                      color: Colors.grey[700],
                      size: 35,
                    ),
                  ),
                  Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 35,
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        iconSize: 40,
                        color: Colors.black,
                        onPressed: () async {
                          if (isPlaying) {
                            await audioPlayer.pause();
                          } else {
                            String url = widget.currentSong.trackLink;
                            await audioPlayer.play(UrlSource(url));
                          }
                        },
                      ),
                    ),
                  ),
                  Icon(
                    Icons.forward_10_rounded,
                    color: Colors.grey[700],
                    size: 35,
                  ),
                  Icon(
                    Icons.last_page_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
              Slider(
                  activeColor: widgetColor,
                  inactiveColor: Colors.grey[800],
                  thumbColor: Colors.deepPurpleAccent,
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (val) async {
                    final position = Duration(seconds: val.toInt());
                    await audioPlayer.seek(position);
                    await audioPlayer.resume();
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTime(position),
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      formatTime(duration - position),
                      style: TextStyle(fontSize: 15, color: Colors.grey[400]),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchAlbum() async {
    try {
      setState(() async {
        var responses = await Future.wait([
          http.get(
              Uri.parse(
                  "https://api.napster.com/v2.2/albums/${widget.currentSong.albumId}/images"),
              headers: requestHeaders),
          http.get(
              Uri.parse(
                  "https://api.napster.com/v2.2/albums/${widget.currentSong.albumId}"),
              headers: requestHeaders)
        ]);

        final extractData = jsonDecode(responses[1].body)["albums"][0];
        final image = jsonDecode(responses[0].body);
        albuminstance.imageUrl = image["images"][3]["url"] ?? "";
        albuminstance.id = extractData["id"] ?? "";
        albuminstance.albumArtistName = extractData["artistName"] ?? "";
        albuminstance.albumTracksCount = extractData["trackCount"] ?? 0;
        albuminstance.artistUrl = extractData["links"]["artists"]["href"] ?? "";
        albuminstance.albumUrl = extractData["href"] ?? "";
        albuminstance.name = extractData["name"] ?? "";
        albuminstance.releasedDate = extractData["released"] ?? "";
      });
    } catch (e) {
      print("error");
      print("audioplayer");
    }
  }
}
