import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vallet_jules_movie_explorer/models/movie.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vallet Jules - Movie Explorer',
      home: MovieList(title: 'Movie list'),
    );
  }
}

// Stateful widget for the movie list
class MovieList extends StatefulWidget {
  MovieList({super.key, required this.title});

  final String title;

  @override
  State<MovieList> createState() => _MovieListState();
}

class MovieDetails extends StatefulWidget {
  MovieDetails({super.key, required this.title, required this.movieId});

  final String title;
  final num movieId;

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieListState extends State<MovieList> {
  @override
  void initState() {
    // Init widget and fetch movie list
    super.initState();
    _fetchMovies();
  }

  List<Movie> movies = [];
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    // If movies have been fetched, the list is displayed, else a loader is displayed
    if (movies.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final curMovie = movies[index];
              return Container(
                height: 250,
                width: 100,
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Row(
                  spacing: 50,
                  children: [
                    Image.network(
                      curMovie.getPosterUrl(),
                      height: 200,
                      width: 100,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(curMovie.title, textScaler: TextScaler.linear(2)),
                        Text(
                          "Rating : ${((curMovie.rating * 10).round() / 10).toString()}",
                          textScaler: TextScaler.linear(1),
                        ),
                      ],
                    ),
                    TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetails(movieId: curMovie.id, title: 'Movie details',),
                        ),
                      );
                    },
                    child: Text('Details +'),
                  )
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: () {
            _fetchMovies();
          },
        )
      );
    } else {
      if (hasError) {
        return Scaffold(
          body: Text("Error : Unable to get movies")
        );
      } else {
        return Scaffold(
          body: LoadingAnimationWidget.inkDrop(color: Colors.blue, size: 100)
        );
      }
    }
  }

  // Fetch movies for TMBD API
  Future _fetchMovies() async {
    // Clear the list, the loader is shown until data is fetched
    setState(() {
      hasError = false;
      movies.clear();
    });

    // API call of popular movies
    final uri = Uri.parse("https://api.themoviedb.org/3/movie/popular");
    final response = await http.get(
      uri,
      headers: {'User-Agent': 'Mozilla/5.0', 'Accept': 'application/json', HttpHeaders.authorizationHeader: 'bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0YjQwYjhmMzczMTc4ZmJhNTRiNjA1MWQ3ZjY3ZDM2YSIsIm5iZiI6MTc3MzkzMzgyOS4yNDcsInN1YiI6IjY5YmMxNTA1MmVjMzU3ZmY1YjAwZjRjOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.skj-oa9AJOeS_0iuhWlyAiGcIgACtfB3xIS__kqu3Q4'},  //TODO: enter your API token here
    );

    // If there was no error, data is parsed into a list of movies
    if (response.statusCode == 200) {
      final body = (jsonDecode(response.body));

      setState(() {
        final results = body['results'] as List;
        movies = results.map((item) => Movie.fromJson(item)).toList();
      });
    } else {
      setState(() {
        hasError = true;
      });
      final body = (jsonDecode(response.body));
      throw Exception(body);
    }
  }
}

class _MovieDetailsState extends State<MovieDetails> {
  @override
  void initState() {
    super.initState();
    _fetchMovie();
  }

  dynamic movie;
  bool hasError = false;
  
  @override
  Widget build(BuildContext context) {
    if (movie != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Column(
          children: [
            Image.network(movie.getPosterUrl(), height: 400, width: 200),
            Text(movie.title),
            Text(((movie.rating * 10).round() / 10).toString()),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back'),
            ),
          ],
        ),
      );
    } else {
      if (hasError) {
        return Scaffold(
          body: Column(
            children: [
              Text("Error : Unable to get movie"),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Back'),
              ),
            ],
          )
        );
      } else {
        return Scaffold(
          body: LoadingAnimationWidget.inkDrop(color: Colors.blue, size: 100)
        );
      }
    }
  }

    // Fetch movie for TMBD API by its id
  Future _fetchMovie() async {
    setState(() {
      hasError = false;
    });

    // API call of movie by id
    final uri = Uri.parse("https://api.themoviedb.org/3/movie/${widget.movieId.toString()}");
    final response = await http.get(
      uri,
      headers: {'User-Agent': 'Mozilla/5.0', 'Accept': 'application/json', HttpHeaders.authorizationHeader: 'bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0YjQwYjhmMzczMTc4ZmJhNTRiNjA1MWQ3ZjY3ZDM2YSIsIm5iZiI6MTc3MzkzMzgyOS4yNDcsInN1YiI6IjY5YmMxNTA1MmVjMzU3ZmY1YjAwZjRjOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.skj-oa9AJOeS_0iuhWlyAiGcIgACtfB3xIS__kqu3Q4'},  //TODO: enter your API token here
    );

    // If there was no error, data is parsed into a movie object
    if (response.statusCode == 200) {
      final body = (jsonDecode(response.body));

      setState(() {
        movie = Movie.fromJson(body);
      });
    } else {
      setState(() {
        hasError = true;
      });
      final body = (jsonDecode(response.body));
      throw Exception(body);
    }
  }
}
