// main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/posts_page.dart';
import '/fav_posts_page.dart';
import '/post_model.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  List<Post> favPosts = [];



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Daily Goals App',
      theme: ThemeData(
        primaryColor: Color(0xFF8D6E63),
        scaffoldBackgroundColor: Color(0xFFF5F5DC),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF8D6E63),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF8D6E63),
          secondary: Color(0xFFA1887F),
        ),
        cardColor: Color(0xFFFFFBF0),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF4E342E)),
          titleMedium: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E342E)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6D4C41),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Color(0xFFFFFBF0),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: Color(0xFFD7CCC8),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF6D4C41),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: SplashScreen(),
    );
  }
}



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AccountPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeIn,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 220,
                margin: EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1506784983877-45594efa4cbe?auto=format&fit=crop&w=800&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Organize Your Day and Achieve Your Goals',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto',
                  color: Color(0xFF4E342E),
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountPage()),
                  );
                },
                child: Text('Create an Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String firstName = '', lastName = '', email = '', job = '', address = '', gender = 'Male';

  Future<void> saveAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('email', email);
    await prefs.setString('job', job);
    await prefs.setString('address', address);
    await prefs.setString('gender', gender);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Account')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(decoration: InputDecoration(labelText: 'First Name'), onChanged: (val) => firstName = val),
            SizedBox(height: 10),
            TextField(decoration: InputDecoration(labelText: 'Last Name'), onChanged: (val) => lastName = val),
            SizedBox(height: 10),
            TextField(decoration: InputDecoration(labelText: 'Email'), onChanged: (val) => email = val),
            SizedBox(height: 10),
            TextField(decoration: InputDecoration(labelText: 'Job Title'), onChanged: (val) => job = val),
            SizedBox(height: 10),
            TextField(decoration: InputDecoration(labelText: 'Address'), onChanged: (val) => address = val),
            SizedBox(height: 10),
            DropdownButtonFormField(
              value: gender,
              items: ['Male', 'Female'].map((g) => DropdownMenuItem(child: Text(g), value: g)).toList(),
              onChanged: (val) => setState(() => gender = val!),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: saveAccount, child: Text('Save Account')),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> tasks = [];
  List<String> completedTasks = [];
  List<Post> favPosts = [];

void toggleFav(Post post) {
  setState(() {
    if (favPosts.any((p) => p.id == post.id)) {
      favPosts.removeWhere((p) => p.id == post.id);
    } else {
      favPosts.add(post);
    }
  });
}
  String fullName = '';

  List<Widget> get _pages => [_homeTab(), _tasksTab(), _profileTab()];

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fn = prefs.getString('firstName') ?? '';
    String ln = prefs.getString('lastName') ?? '';
    setState(() => fullName = '$fn $ln');
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Widget _homeTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hello, $fullName!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://images.stockcake.com/public/3/e/a/3ea5e35a-d542-44ea-9e82-d52b30495156_large/cozy-workspace-setup-stockcake.jpg',
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Start organizing your tasks and make progress every day!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tasksTab() {
    TextEditingController controller = TextEditingController();
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(child: TextField(controller: controller, decoration: InputDecoration(labelText: 'New Task'))),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    tasks.add({'name': controller.text, 'completed': false});
                    controller.clear();
                  });
                },
                child: Text('Add'),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(
                  task['name'],
                  style: TextStyle(
                    decoration: task['completed'] ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text('Created by: $fullName'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        setState(() {
                          task['completed'] = true;
                          completedTasks.add(task['name']);
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => setState(() => tasks.removeAt(index)),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _profileTab() {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        SharedPreferences prefs = snapshot.data as SharedPreferences;
        return Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              Text('First Name: ${prefs.getString('firstName') ?? ''}'),
              Text('Last Name: ${prefs.getString('lastName') ?? ''}'),
              Text('Email: ${prefs.getString('email') ?? ''}'),
              Text('Job: ${prefs.getString('job') ?? ''}'),
              Text('Address: ${prefs.getString('address') ?? ''}'),
              Text('Gender: ${prefs.getString('gender') ?? ''}'),
              SizedBox(height: 20),
              Text('Completed Tasks:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...completedTasks.map((e) => Text('- $e')).toList(),
      SizedBox(height: 20),
       Text('Favourite Posts: ${favPosts.length}', style: TextStyle(fontWeight: FontWeight.bold)),
       TextButton(
        onPressed: () {
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavPostsPage(
          favPosts: favPosts,
          onToggleFav: toggleFav,
        ),
      ),
    );
  },
  child: Text('Show Favourite Posts'),
),
            ],
          ),
        );
      },
    );
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Menu')),
            ListTile(title: Text('Tasks'), onTap: () => _onItemTapped(1)),
            ListTile(title: Text('Profile'), onTap: () => _onItemTapped(2)),
            ListTile(title: Text('Logout'), onTap: logout),
            ListTile(
  leading: Icon(Icons.post_add),
  title: Text('Posts'),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostsPage(
          favPosts: favPosts,
          onToggleFav: toggleFav,
        ),
      ),
    );
  },
),
ListTile(
  leading: Icon(Icons.favorite),
  title: Text('Favorite Posts'),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FavPostsPage(
          favPosts: favPosts,
          onToggleFav: toggleFav,
        ),
      ),
    );
  },
),

          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
