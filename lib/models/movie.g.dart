part of 'movie.dart';

// Parse JSON data to a movie object
Movie _$MovieFromJson(Map<String, dynamic> json) => Movie(
  json['title'] as String,
  json['poster_path'] as String,
  (json['vote_average'] as num).toDouble()
);
