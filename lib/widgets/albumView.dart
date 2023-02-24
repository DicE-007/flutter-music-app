import 'package:flutter/material.dart';
import 'package:runomusic/pages/albumLayout.dart';
import '../Models/album.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/constants.dart';

class AlbumView extends StatefulWidget {
  final List<Album> albumList;
  AlbumView(this.albumList);

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  int currOffA = 0;
  final scrollcontrollerA = ScrollController();
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAlbumImage();
    scrollcontrollerA.addListener(_scrollListner);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount:
            isLoading ? widget.albumList.length + 1 : widget.albumList.length,
        scrollDirection: Axis.horizontal,
        controller: scrollcontrollerA,
        shrinkWrap: true,
        separatorBuilder: (ctx, index) {
          return SizedBox(
            width: 10,
          );
        },
        itemBuilder: (ctx, idx) {
          if (idx < widget.albumList.length) {
            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AlbumLayout(widget.albumList[idx])));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: widget.albumList[idx].imageUrl == ""
                          ? SizedBox(
                              height: 150,
                              width: 150,
                              child: Image.asset("assets/profile.png"),
                            )
                          : Image.network(
                              widget.albumList[idx].imageUrl,
                              height: 150,
                              width: 150,
                            ),
                    ),
                    Text(
                      widget.albumList[idx].name.length > 16
                          ? widget.albumList[idx].name.substring(0, 13) + "..."
                          : widget.albumList[idx].name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.albumList[idx].albumArtistName.length > 16
                          ? widget.albumList[idx].albumArtistName
                                  .substring(0, 12) +
                              "..."
                          : widget.albumList[idx].albumArtistName,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  ],
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

  Future<void> fetchAlbumImage() async {
    widget.albumList.forEach((element) async {
      try {
        final response = await http.get(Uri.parse("${element.albumUrl}/images"),
            headers: requestHeaders);
        final data = jsonDecode(response.body);
        if (data["images"].length != 0) {
          setState(() {
            element.imageUrl = data["images"][2]["url"];
          });
        }
      } catch (e) {
        element.imageUrl = "";
      }
    });
  }

  Future<void> fetchAlbums() async {
    try {
      final response = await http.get(
          Uri.parse(
              "https://api.napster.com/v2.2/albums/top?limit=6&offset=$currOffA"),
          headers: requestHeaders);
      final extractData = jsonDecode(response.body);
      if (mounted)
        setState(() {
          extractData["albums"].forEach((item) {
            widget.albumList.add(Album(
                id: item["id"],
                albumArtistName: item["artistName"],
                albumTracksCount: item["trackCount"],
                artistUrl: item["links"]["artists"]["href"],
                albumUrl: item["href"],
                name: item["name"],
                releasedDate: item["released"]));
          });
        });
    } catch (e) {
      print("error");
    }
  }

  void _scrollListner() async {
    if (scrollcontrollerA.position.pixels ==
        scrollcontrollerA.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      currOffA += 7;
      await fetchAlbums();
      await fetchAlbumImage();
      setState(() {
        isLoading = false;
      });
    }
  }
}
