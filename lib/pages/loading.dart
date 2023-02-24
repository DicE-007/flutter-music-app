import 'package:flutter/material.dart';
import 'package:runomusic/pages/getStarted.dart';
import 'package:runomusic/pages/home_page.dart';
import '../Models/track.dart';
import '../Models/album.dart';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import 'dart:convert';
import '../Models/artist.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  List<Track> tracks = [];
  List<Album> albums = [];
  List<Artist> artists = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sendData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinKitRing(
          color: widgetColor,
          size: 50.0,
        ),
      ),
    );
  }

  Future<void> fetchTracks() async {
    try {
      final response = await http.get(apiTracks, headers: requestHeaders);
      final extractData = jsonDecode(response.body);
      setState(() {
        extractData["tracks"].forEach((item) async {
          tracks.add(
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
      tracks = [];
      print("error");
    }
  }

  Future<void> fetchAlbums() async {
    try {
      final response = await http.get(apiAlbums, headers: requestHeaders);
      final extractData = jsonDecode(response.body);
      if (mounted)
        setState(() {
          extractData["albums"].forEach((item) {
            albums.add(
                Album(
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
      albums = [];
      print("error");
    }
  }

  Future<void> fetchArtist() async {
    try {
      final response = await http.get(
          Uri.parse(
              "https://api.napster.com/v2.2/artists/top?limit=7&offset=0"),
          headers: requestHeaders);
      final extractedData = jsonDecode(response.body);
      setState(() {
        extractedData["artists"].forEach((item) {
          artists.add(
              Artist(
              artistId: item["id"]??"",
               about: item["bios"]!=null? item["bios"][0]["bio"]:"NO DATA FOUND",
              albumsOthers: item["albumGroups"]["others"]??"",
              albumsMain: item["albumGroups"]["main"]??[],
              albumsSingles: item["albumGroups"]["singlesAndEPs"]??[],
              artistName: item["name"]??"",
              imageUrl: "",
              albumsCompilation: item["albumGroups"]["compilations"]??[]));
        });
        print(artists);
      });
    } catch (err) {
      print("err");
    }
  }

  void sendData() async {
    await fetchTracks();
    await fetchAlbums();
    await fetchArtist();
    Navigator.pushReplacementNamed(context, GetStarted.path, arguments: {
      "tracklist": tracks,
      "albumlist": albums,
      "artistlist":artists
    });
  }
}
