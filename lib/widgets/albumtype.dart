import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import '../Models/album.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Albumtype extends StatefulWidget {
  static const path= "/albumtype";
  final List<dynamic> albumList;
  Albumtype(this.albumList);
  @override
  State<Albumtype> createState() => _AlbumtypeState();
}

class _AlbumtypeState extends State<Albumtype> {
  @override
  List<Album> albums = [];

  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAlbums();
  }

  int counter = 0;

  @override
  Widget build(BuildContext context) {
    print("albumtype");
    print(widget.albumList);
    // if (widget.albumList.isNotEmpty && counter == 1) {
    //   print("in build");
    //   fetchAlbums();
    // }
    // ;
    // print(widget.albumList);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("GO BACK!!!!!"),centerTitle: true,),
        body: albums.isEmpty?Center(child: Text("IN DEVELOPMENT")):Column(
          children: [
            SizedBox(
              height: 20,
            ),
            ListView.builder(
                itemCount: albums.length,
                shrinkWrap: true,
                itemBuilder: (context, idx) {
                  return InkWell(
                    onTap: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (context)=>MusicPlayer(widget.trackList[idx])));
                    },
                    child: ListTile(
                      leading: albums[idx].imageUrl == ""
                          ? SizedBox(
                        height: 60,
                        width: 60,
                      )
                          : CircleAvatar(
                        backgroundImage: NetworkImage(
                          albums[idx].imageUrl,
                        ),
                        radius: 30,
                      ),
                      title: Text(
                        albums[idx].name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      subtitle: Text(
                        albums[idx].albumArtistName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }

  // Future<void> fetchAlbumImage() async {
  //   //print(albums);
  //   albums.forEach((element) async {
  //     try {
  //       final response = await http.get(Uri.parse("${element.albumUrl}/images"),
  //           headers: requestHeaders);
  //       final data = jsonDecode(response.body);
  //       if (data["images"].length != 0) {
  //         setState(() {
  //           element.imageUrl = data["images"][2]["url"];
  //         });
  //       }
  //     } catch (e) {
  //       element.imageUrl = "";
  //     }
  //   });
  // }

   fetchAlbums() {
    // counter++;
    try {
         for(int i=0;i<widget.albumList.length;i++){
           var element = widget.albumList[i];
           func1(element);
      };
    } catch (e) {
      print("error");
    }
  }

  func1(dynamic element)async{
    final response = await http.get(
        Uri.parse("https://api.napster.com/v2.2/albums/${element}"),
        headers: requestHeaders);
    final extractData = jsonDecode(response.body);
    // setState(() {
    albums.add(Album(
        id: extractData["id"] ?? "",
        albumArtistName: extractData["artistName"] ?? "",
        artistUrl: extractData["links"]!=null?extractData["links"]["artists"]["href"] ?? "":"",
        albumTracksCount: extractData["trackCount"] ?? 0,
        albumUrl: extractData["href"] ?? "",
        name: extractData["name"] ?? "",
        releasedDate: extractData["released"] ?? ""));
    // });
  }
}
