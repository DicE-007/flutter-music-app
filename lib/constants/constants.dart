import 'package:flutter/material.dart';
final widgetBackground = Color(0xFF2de37);
final widgetColor = Color(0xFF3c3abe);
final apiArtists = Uri.parse("https://api.napster.com/v2.2/artists/top");
final apiTracks = Uri.parse("https://api.napster.com/v2.2/tracks/top?limit=8&offset=0");
final apiAlbums = Uri.parse("https://api.napster.com/v2.2/albums/top?limit=6&offset=0");
const Map<String, String> requestHeaders = {
  "apikey" : "OTYxNDY3NTItZmM1Zi00MTMzLTllN2UtMDk2ZTBlMzIyYTZm"
};
const morning = "Good Morning\nHave a nice day!";

