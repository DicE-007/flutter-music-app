import 'package:flutter/material.dart';
import 'package:runomusic/Models/artist.dart';
import 'package:runomusic/tops/categories.dart';
import 'package:runomusic/widgets/albumView.dart';
import 'package:runomusic/widgets/artistHorizontalList.dart';
import 'package:runomusic/widgets/trackView.dart';
import '../constants/constants.dart';
import '../Models/track.dart';
import '../Models/album.dart';

class Home_Page extends StatefulWidget {
  static const path = "/home_page";
  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  Map data = {};
  List<Track> tracklist = [];
  List<Album> albumlist = [];
  List<Artist> artistlist = [];

  int returnedIndex = 0;
  void _returndeValFromchild(int x) {
    setState(() {
      returnedIndex = x;
      print(returnedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty
        ? data
        : ModalRoute.of(context)?.settings.arguments as Map;

    List<Track> tracklist = data["tracklist"];
    List<Album> albumlist = data["albumlist"];
    List<Artist> artistlist = data["artistlist"];
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                morning,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Category(["Home", "Podcast"], _returndeValFromchild),
            SizedBox(
              height: 6,
            ),
            returnedIndex == 0
                ? Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "ALBUMS",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Container(height: 200, child: AlbumView(albumlist)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "ARTISTS",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Container(
                            height: 80,
                            padding: const EdgeInsets.only(left: 8),
                            child: ArtistList(artistlist)),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "SONGS",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Expanded(child: TrackView(tracklist)),
                      ],
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Center(child: Text("IN DEVELOPMENT")),
                  )
          ],
        ),
      ),
    );
  }
}
