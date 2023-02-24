
class Track {
  final String trackName;
  final String artistName;
  final String trackImg;
  final String albumName;
  final int playbackSeconds;
  final String artistId;
  final String albumId;
  final String trackLink;

   String imageUrl;

  Track(
      {this.imageUrl="",
        required this.trackImg,
      required this.albumId,
      required this.albumName,
      required this.artistId,
      required this.artistName,
      required this.playbackSeconds,
      required this.trackLink,
      required this.trackName});



}

