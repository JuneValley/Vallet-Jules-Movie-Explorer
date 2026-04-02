import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

@JsonSerializable()
class Movie {
  String title;
  String posterRaw;
  num rating;
  num id;

  Movie(this.title, this.posterRaw, this.rating, this.id);

  // Constructs a movie object from JSON data
  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  // Return the full URL to access movie poster image
  String getPosterUrl() {
    return "https://image.tmdb.org/t/p/w500$posterRaw";
  }
}