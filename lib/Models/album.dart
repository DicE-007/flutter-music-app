class Album{
   String id;
   String albumUrl;
   String name;
   String releasedDate;
   String albumArtistName;
   String artistUrl;
   int albumTracksCount;
  String imageUrl;
  Album({
  required this.id,
  required this.albumArtistName,
    required this.artistUrl,
  required this.albumTracksCount,
  required this.albumUrl,
  required this.name,
  required this.releasedDate,
    this.imageUrl=""
});
}