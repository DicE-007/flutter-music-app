class Artist {
   String artistName;
   String artistId;
   String about;
   List<dynamic> albumsOthers;
   List<dynamic>albumsSingles;
   List<dynamic>albumsMain;
   List<dynamic>albumsCompilation;
   String imageUrl;

  Artist({
    required this.artistId,
    required this.about,
    required this.albumsOthers,
    required this.albumsMain,
    required this.albumsSingles,
    required this.artistName,
    required this.imageUrl,
    required this.albumsCompilation
});
}
