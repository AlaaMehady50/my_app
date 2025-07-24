import 'package:flutter/material.dart';
import '../post_model.dart';
import 'posts_page.dart';

class FavPostsPage extends StatelessWidget {
  final List<Post> favPosts;
  final Function(Post) onToggleFav;

  FavPostsPage({required this.favPosts, required this.onToggleFav});

  void _startSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: PostSearchDelegate(favPosts, favPosts, onToggleFav),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourite Posts'),
        actions: [IconButton(icon: Icon(Icons.search), onPressed: () => _startSearch(context))],
      ),
      body: favPosts.isEmpty
          ? Center(child: Text('No favourite posts yet.'))
          : ListView.builder(
              itemCount: favPosts.length,
              itemBuilder: (context, index) {
                final post = favPosts[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(post.title),
                    subtitle: Text(post.body),
                    trailing: IconButton(
                      icon: Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => onToggleFav(post),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
