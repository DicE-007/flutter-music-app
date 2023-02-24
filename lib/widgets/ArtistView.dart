import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:runomusic/constants/constants.dart';
import 'package:runomusic/pages/albumLayout.dart';
import 'package:runomusic/tops/categories.dart';
import 'package:runomusic/widgets/albumtype.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../Models/artist.dart';
import 'package:http/http.dart' as http;
import '../Models/album.dart';

class ArtistView extends StatefulWidget {
  static const path = "/artistview";
  final String artistUrl;

  ArtistView(this.artistUrl);

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  Artist artistBio = Artist(
      artistId: "",
      about: "Loading...",
      albumsSingles: [],
      artistName: "",
      imageUrl: "",
      albumsMain: [],
      albumsOthers: [],
      albumsCompilation: []);
  int returnedIndex = 0;
  Map<int, dynamic> mp = {};
  Map<int, List<Album>> mp2 = {};
  List<Album> main = [];
  List<Album> single = [];
  List<Album> compilation = [];
  List<Album> others = [];
  @override
  void initState() {
    // TODO: implement initState  Map<int, dynamic> mp = {};

    super.initState();
    waiting();
  }

  void _returndeValFromchild(int x) {
    setState(() {
      returnedIndex = x;
    });
  }

  bool show = true;
  @override
  Widget build(BuildContext context) {
    print(returnedIndex);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                Center(
                  child: artistBio.imageUrl != ""
                      ? Image.network(artistBio.imageUrl,
                          width: 250, height: 250)
                      : Container(
                          height: 250,
                          width: 250,
                          child: SpinKitRing(
                            color: widgetColor,
                            size: 50,
                          ),
                        ),
                ),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white))
              ]),
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                        child: Text(
                      artistBio.artistName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "About",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: artistBio.about != "NO DATA FOUND"
                              ? show
                                  ? Column(
                                      children: [
                                        Text(
                                          artistBio.about,
                                          maxLines: 3,
                                          textAlign: TextAlign.justify,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        InkWell(
                                            onTap: () {
                                              setState(() {
                                                show = !show;
                                              });
                                            },
                                            child: Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.white,
                                            ))
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Text(
                                          artistBio.about,
                                          textAlign: TextAlign.justify,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              show = !show;
                                            });
                                          },
                                          child: Icon(
                                            Icons.keyboard_arrow_up,
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    )
                              : Text(
                                  "NO DATA FOUND",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                        ),
                      ),
                    ),
                    // InkWell(
                    //     onTap: () {
                    //       Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => Albumtype(main)));
                    //     },
                    //     child: Text("ALBUMS")),
                    SizedBox(
                      height: 20,
                    ),
                    Category(
                        ["Main", "Singles & Eps", "Compilations", "Others"],
                        _returndeValFromchild),
                    SizedBox(
                      height: 10,
                    ),
                    main.length > 0
                        ? SizedBox(
                            width: 500,
                            height: 500,
                            child: ListView.separated(
                                separatorBuilder: (ctx, i) {
                                  return SizedBox(
                                    height: 5,
                                  );
                                },
                                shrinkWrap: true,
                                itemCount: mp2[returnedIndex]!.length,
                                itemBuilder: (ctx, i) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => AlbumLayout(
                                                  mp2[returnedIndex]![i])));
                                    },
                                    child: ListTile(
                                      leading: mp2[returnedIndex]![i]
                                                  .imageUrl !=
                                              ""
                                          ? CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  mp2[returnedIndex]![i]
                                                      .imageUrl),
                                              backgroundColor: Colors.grey[800],
                                              radius: 30,
                                            )
                                          : CircleAvatar(
                                              backgroundImage: AssetImage(
                                                  "assets/profile.png"),
                                              backgroundColor: Colors.grey[800],
                                              radius: 30,
                                            ),
                                      title: Text(
                                        mp2[returnedIndex]![i].name,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }),
                          )
                        : Center(
                            child: SpinKitRing(
                              color: widgetColor,
                              size: 50.0,
                            ),
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

  Future<void> fetchData() async {
    try {
      var responses = await Future.wait([
        http.get(Uri.parse(widget.artistUrl), headers: requestHeaders),
        http.get(Uri.parse("${widget.artistUrl}/images"),
            headers: requestHeaders),
      ]);

      final data = jsonDecode(responses[0].body);
      final data2 = jsonDecode(responses[1].body);
      final artist = data["artists"][0] ?? {};
      setState(() {
        artistBio.artistName = artist["name"] ?? "";

        artist["bios"] != null
            ? artistBio.about = artist["bios"][0]["bio"]
            : artistBio.about = "NO DATA FOUND";

        artistBio.imageUrl = data2["images"][3]["url"] ?? "";

        artistBio.albumsOthers = artist["albumGroups"]["others"] ?? "";

        artistBio.albumsCompilation =
            artist["albumGroups"]["compilations"] ?? "";

        artistBio.albumsSingles = artist["albumGroups"]["singlesAndEPs"] ?? "";

        artistBio.albumsMain = artist["albumGroups"]["main"] ?? "";

        mp = {
          0: artistBio.albumsMain,
          1: artistBio.albumsSingles,
          2: artistBio.albumsCompilation,
          3: artistBio.albumsOthers,
        };
        _getAlbumMainData();
        _getAlbumSinglesData();
        _getAlbumcompilationsData();
        _getAlbumOtherData();
        mp2 = {0: main, 1: single, 2: compilation, 3: others};
      });
    } catch (e) {
      print("err");
    }
  }

  void _getAlbumMainData() async {
    List<dynamic> albumIds = mp[0];
    for (dynamic id in albumIds) {
      if (main.length > 6) break;
      final response = await http.get(
          Uri.parse("https://api.napster.com/v2.2/albums/${id}"),
          headers: requestHeaders);
      final extractData = jsonDecode(response.body)['albums'][0];
      // print(extractData);
      main.add(Album(
          id: extractData["id"] ?? "",
          albumArtistName: extractData["artistName"] ?? "",
          artistUrl: extractData["links"] != null
              ? extractData["links"]["artists"]["href"] ?? ""
              : "",
          albumTracksCount: extractData["trackCount"] ?? 0,
          albumUrl: extractData["href"] ?? "",
          name: extractData["name"] ?? "",
          releasedDate: extractData["released"] ?? ""));

      setState(() {});
      _getAlbumMainDataImage(main[main.length - 1]);
      //setState(() {});
    }
  }

  void _getAlbumMainDataImage(Album instance) async {
    try {
      final response = await http.get(Uri.parse("${instance.albumUrl}/images"),
          headers: requestHeaders);
      final extractedImage = jsonDecode(response.body)["images"][1]["url"];
      instance.imageUrl = extractedImage;
    } catch (err) {
      instance.imageUrl = "";
    }
  }

  void _getAlbumSinglesData() async {
    List<dynamic> albumIds = mp[1];
    for (dynamic id in albumIds) {
      if (single.length > 6) break;
      final response = await http.get(
          Uri.parse("https://api.napster.com/v2.2/albums/${id}"),
          headers: requestHeaders);
      final extractData = jsonDecode(response.body)['albums'][0];
      // print(extractData);
      single.add(Album(
          id: extractData["id"] ?? "",
          albumArtistName: extractData["artistName"] ?? "",
          artistUrl: extractData["links"] != null
              ? extractData["links"]["artists"]["href"] ?? ""
              : "",
          albumTracksCount: extractData["trackCount"] ?? 0,
          albumUrl: extractData["href"] ?? "",
          name: extractData["name"] ?? "",
          releasedDate: extractData["released"] ?? ""));

      setState(() {});
      _getAlbumSinglesDataImage(single[single.length - 1]);
      //setState(() {});
    }
  }

  void _getAlbumSinglesDataImage(Album instance) async {
    try {
      final response = await http.get(Uri.parse("${instance.albumUrl}/images"),
          headers: requestHeaders);
      final extractedImage = jsonDecode(response.body)["images"][1]["url"];
      instance.imageUrl = extractedImage;
    } catch (err) {
      instance.imageUrl = "";
    }
  }

  void _getAlbumcompilationsData() async {
    List<dynamic> albumIds = mp[2];
    for (dynamic id in albumIds) {
      if (compilation.length > 6) break;
      final response = await http.get(
          Uri.parse("https://api.napster.com/v2.2/albums/${id}"),
          headers: requestHeaders);
      final extractData = jsonDecode(response.body)['albums'][0];
      // print(extractData);
      compilation.add(Album(
          id: extractData["id"] ?? "",
          albumArtistName: extractData["artistName"] ?? "",
          artistUrl: extractData["links"] != null
              ? extractData["links"]["artists"]["href"] ?? ""
              : "",
          albumTracksCount: extractData["trackCount"] ?? 0,
          albumUrl: extractData["href"] ?? "",
          name: extractData["name"] ?? "",
          releasedDate: extractData["released"] ?? ""));

      setState(() {});
      _getAlbumcompilationsDataImage(compilation[compilation.length - 1]);
      //setState(() {});
    }
  }

  void _getAlbumcompilationsDataImage(Album instance) async {
    try {
      final response = await http.get(Uri.parse("${instance.albumUrl}/images"),
          headers: requestHeaders);
      final extractedImage = jsonDecode(response.body)["images"][1]["url"];
      instance.imageUrl = extractedImage;
    } catch (err) {
      instance.imageUrl = "";
    }
  }

  void _getAlbumOtherData() async {
    List<dynamic> albumIds = mp[3];
    for (dynamic id in albumIds) {
      if (others.length > 6) break;
      final response = await http.get(
          Uri.parse("https://api.napster.com/v2.2/albums/${id}"),
          headers: requestHeaders);
      final extractData = jsonDecode(response.body)['albums'][0];
      // print(extractData);
      others.add(Album(
          id: extractData["id"] ?? "",
          albumArtistName: extractData["artistName"] ?? "",
          artistUrl: extractData["links"] != null
              ? extractData["links"]["artists"]["href"] ?? ""
              : "",
          albumTracksCount: extractData["trackCount"] ?? 0,
          albumUrl: extractData["href"] ?? "",
          name: extractData["name"] ?? "",
          releasedDate: extractData["released"] ?? ""));

      setState(() {});
      _getAlbumOtherDataImage(others[others.length - 1]);
      //setState(() {});
    }
  }

  void _getAlbumOtherDataImage(Album instance) async {
    try {
      final response = await http.get(Uri.parse("${instance.albumUrl}/images"),
          headers: requestHeaders);
      final extractedImage = jsonDecode(response.body)["images"][1]["url"];
      instance.imageUrl = extractedImage;
    } catch (err) {
      instance.imageUrl = "";
    }
  }

  void waiting() async {
    await fetchData();

    //await fetchAlbums();
  }
}
