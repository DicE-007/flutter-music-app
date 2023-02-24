import 'package:flutter/material.dart';
import 'package:runomusic/constants/constants.dart';
import 'package:runomusic/widgets/ArtistView.dart';
import '../Models/album.dart';
import '../Models/track.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/audioPlayer.dart';

class AlbumLayout extends StatefulWidget {
  static const path = "/albumlayout";
  final Album albumInstance;

  AlbumLayout(this.albumInstance);
  @override
  State<AlbumLayout> createState() => _AlbumLayoutState();
}

class _AlbumLayoutState extends State<AlbumLayout> {
  List<Track> albumSongs = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTracks();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                Center(
                  child: widget.albumInstance.imageUrl != ""
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(widget.albumInstance.imageUrl,
                              width: 250,
                              height: 350,
                              alignment: Alignment.topRight),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            "assets/profile.png",
                            height: 250,
                            width: 250,
                          ),
                        ),
                ),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white))
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Center(
                  child: Text("${widget.albumInstance.name} Songs",
                      style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ArtistView(
                                      widget.albumInstance.artistUrl)));
                        },
                        child: Text(
                          "# ${widget.albumInstance.albumArtistName}",
                          style: Theme.of(context).textTheme.bodySmall,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Album Track Count : ${widget.albumInstance.albumTracksCount}",
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  "Songs",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: albumSongs.length,
                    shrinkWrap: true,
                    itemBuilder: (ctx, idx) {
                      return albumSongs.length != 0
                          ? InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MusicPlayer(albumSongs[idx])));
                              },
                              child: Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: ListTile(
                                    leading: widget.albumInstance.imageUrl == ""
                                        ? SizedBox(
                                            height: 60,
                                            width: 60,
                                          )
                                        : Container(
                                            child: Image.network(
                                                widget.albumInstance.imageUrl),
                                          ),
                                    title: Text(
                                      albumSongs[idx].trackName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    trailing: Text(
                                      "${(albumSongs[idx].playbackSeconds / 60).toStringAsFixed(2)} mins",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  )),
                            )
                          : ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    AssetImage("assets/profile.png"),
                              ),
                            );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchTracks() async {
    print(widget.albumInstance);
    try {
      final response = await http.get(
          Uri.parse("${widget.albumInstance.albumUrl}/tracks"),
          headers: requestHeaders);
      final extractData = jsonDecode(response.body);
      setState(() {
        extractData["tracks"].forEach((item) async {
          albumSongs.add(
            Track(
                albumId: item["albumId"],
                trackImg: item["links"]["artists"]["href"],
                albumName: item["albumName"],
                artistId: item["artistId"],
                artistName: item["artistName"],
                playbackSeconds: item["playbackSeconds"],
                trackName: item["name"],
                imageUrl: widget.albumInstance.imageUrl,
                trackLink: item["previewURL"]),
          );
        });
      });
      //print(widget.albumSongs);
    } catch (e) {
      albumSongs = [];
      print("error");
    }
  }
}
