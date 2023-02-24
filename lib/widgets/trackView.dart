import 'package:flutter/material.dart';
import 'package:runomusic/widgets/audioPlayer.dart';
import '../Models/track.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/constants.dart';

GlobalKey<_TrackViewState> globalKey = GlobalKey();

class TrackView extends StatefulWidget {
  final List<Track> trackList;

  TrackView(this.trackList);

  @override
  State<TrackView> createState() => _TrackViewState();
}

class _TrackViewState extends State<TrackView> {
  final scrollcontrollerT = ScrollController();
  bool isLoading = false;
  int curOffT = 0;
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTrackImage();
    scrollcontrollerT.addListener(_scrollListner);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount:
            isLoading ? widget.trackList.length + 1 : widget.trackList.length,
        controller: scrollcontrollerT,
        shrinkWrap: true,
        itemBuilder: (context, idx) {
          if (idx < widget.trackList.length) {
            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MusicPlayer(widget.trackList[idx])));
              },
              child: ListTile(
                leading: widget.trackList[idx].imageUrl == ""
                    ? CircleAvatar(
                        backgroundImage: AssetImage("assets/music.png"),
                        radius: 30,
                        backgroundColor: Colors.grey[800],
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(
                          widget.trackList[idx].imageUrl,
                        ),
                        backgroundColor: Colors.grey[800],
                        radius: 30,
                      ),
                title: Text(
                  widget.trackList[idx].trackName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  widget.trackList[idx].albumName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(color: widgetColor),
            );
          }
        });
  }

  Future<void> fetchTrackImage() async {
    widget.trackList.forEach((element) async {
      try {
        final response = await http.get(Uri.parse("${element.trackImg}/images"),
            headers: requestHeaders);
        final data = jsonDecode(response.body);
        if (data["images"].length != 0) {
          setState(() {
            element.imageUrl = data["images"][3]["url"];
          });
        }
      } catch (e) {
        element.imageUrl = "";
      }
    });
  }

  Future<void> fetchTracks() async {
    try {
      final response = await http.get(
          Uri.parse(
              "https://api.napster.com/v2.2/tracks/top?limit=8&offset=$curOffT"),
          headers: requestHeaders);
      final extractData = jsonDecode(response.body);
      setState(() {
        extractData["tracks"].forEach((item) async {
          widget.trackList.add(
            Track(
                albumId: item["albumId"],
                trackImg: item["links"]["artists"]["href"],
                albumName: item["albumName"],
                artistId: item["artistId"],
                artistName: item["artistName"],
                playbackSeconds: item["playbackSeconds"],
                trackName: item["name"],
                trackLink: item["previewURL"]),
          );
        });
      });
    } catch (e) {
      print("error");
    }
  }

  void _scrollListner() async {
    if (scrollcontrollerT.position.pixels ==
        scrollcontrollerT.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      curOffT += 9;
      await fetchTracks();
      await fetchTrackImage();
      setState(() {
        isLoading = false;
      });
    }
  }
}
