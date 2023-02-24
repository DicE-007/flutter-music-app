import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/constants.dart';
import '../Models/artist.dart';
import '../widgets/ArtistView.dart';

class ArtistList extends StatefulWidget {
  List<Artist> artistlist;
  ArtistList(this.artistlist);

  @override
  State<ArtistList> createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
  final scrollcontrollerA = ScrollController();
  bool isLoading = false;
  int curOffA = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTrackImage();
    scrollcontrollerA.addListener(_scrollListner);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: isLoading
          ? widget.artistlist.length + 1
          : widget.artistlist.length + 1,
      scrollDirection: Axis.horizontal,
      controller: scrollcontrollerA,
      shrinkWrap: true,
      separatorBuilder: (context, index) {
        return SizedBox(
          width: 15,
        );
      },
      itemBuilder: ((context, index) {
        if (index < widget.artistlist.length) {
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ArtistView(
                          "https://api.napster.com/v2.2/artists/${widget.artistlist[index].artistId}")));
            },
            child: Column(
              children: [
                widget.artistlist[index].imageUrl != ""
                    ? CircleAvatar(
                        backgroundImage:
                            NetworkImage(widget.artistlist[index].imageUrl),
                        radius: 30,
                        backgroundColor: Colors.grey[800],
                      )
                    : CircleAvatar(
                        backgroundImage: AssetImage("assets/profile.png"),
                        backgroundColor: Colors.grey[800],
                        radius: 30,
                      ),
                SizedBox(
                  width: 60,
                  child: Text(
                    widget.artistlist[index].artistName,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(color: widgetColor),
          );
        }
      }),
    );
  }

  Future<void> fetchTrackImage() async {
    widget.artistlist.forEach((element) async {
      try {
        final response = await http.get(
            Uri.parse(
                "https://api.napster.com/v2.2/artists/${element.artistId}/images"),
            headers: requestHeaders);
        final data = jsonDecode(response.body);
        if (data["images"].length != 0) {
          setState(() {
            element.imageUrl = data["images"][3]["url"] ?? "";
          });
        }
      } catch (e) {
        element.imageUrl = "";
      }
    });
  }

  Future<void> fetchArtist() async {
    try {
      final response = await http.get(
          Uri.parse(
              "https://api.napster.com/v2.2/artists/top?limit=7&offset=$curOffA"),
          headers: requestHeaders);
      final extractedData = jsonDecode(response.body);
      setState(() {
        extractedData["artists"].forEach((item) {
          widget.artistlist.add(Artist(
              artistId: item["id"] ?? "",
              about: item["bios"] != null
                  ? item["bios"][0]["bio"]
                  : "NO DATA FOUND",
              albumsOthers: item["albumGroups"]["others"] ?? "",
              albumsMain: item["albumGroups"]["main"] ?? [],
              albumsSingles: item["albumGroups"]["singlesAndEPs"] ?? [],
              artistName: item["name"] ?? "",
              imageUrl: "",
              albumsCompilation: item["albumGroups"]["compilations"] ?? []));
        });
      });
    } catch (err) {
      print("err");
    }
  }

  void _scrollListner() async {
    if (scrollcontrollerA.position.pixels ==
        scrollcontrollerA.position.maxScrollExtent) {
      setState(() {
        isLoading = true;
      });
      curOffA += 8;
      await fetchArtist();
      await fetchTrackImage();
      setState(() {
        isLoading = false;
      });
    }
  }
}
