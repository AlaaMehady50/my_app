import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../post_model.dart';
import 'fav_posts_page.dart';

class PostsPage extends StatefulWidget {
  final List<Post> favPosts;
  final Function(Post) onToggleFav;

  PostsPage({required this.favPosts, required this.onToggleFav});

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  List<Post> posts = [];

  Future<void> fetchPosts() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        posts = data.map((e) => Post.fromJson(e)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  void _startSearch() {
    showSearch(
      context: context,
      delegate: PostSearchDelegate(posts, widget.favPosts, widget.onToggleFav),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
        actions: [IconButton(icon: Icon(Icons.search), onPressed: _startSearch)],
      ),
      body: posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final isFav = widget.favPosts.any((p) => p.id == post.id);
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(post.title),
                    subtitle: Text(post.body),
                    trailing: IconButton(
                      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? const Color.fromARGB(255, 173, 163, 162) : null),
                      onPressed: () => widget.onToggleFav(post),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class PostSearchDelegate extends SearchDelegate {
  final List<Post> allPosts;
  final List<Post> favPosts;
  final Function(Post) onToggleFav;

  PostSearchDelegate(this.allPosts, this.favPosts, this.onToggleFav);

  @override
  List<Widget> buildActions(BuildContext context) => [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => BackButton();

  @override
  Widget buildResults(BuildContext context) => _buildResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults();

  Widget _buildResults() {
    final results = allPosts.where((p) => p.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final post = results[index];
        final isFav = favPosts.any((p) => p.id == post.id);
        return Card(
          margin: EdgeInsets.all(10),
          child: ListTile(
            title: Text(post.title),
            subtitle: Text(post.body),
            trailing: IconButton(
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? const Color.fromARGB(255, 121, 118, 126) : null),
              onPressed: () => onToggleFav(post),
            ),
          ),
        );
      },
    );
  }
}
