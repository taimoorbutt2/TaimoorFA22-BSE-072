import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:shared_preferences/shared_preferences.dart'; // For storing theme preference
import 'package:sqflite/sqflite.dart'; // SQLite database for local storage
import 'package:path/path.dart'; // Helps in handling file paths

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures all bindings are initialized before running the app
  runApp(MyApp()); // Runs the main app
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false; // Boolean flag to track theme mode
  @override
  void initState() {
    super.initState();
    _loadThemePreference(); // Load the saved theme preference when app starts
  }
  // Load theme preference using SharedPreferences
  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false; // Fetch saved preference or default to false
    });
  }
  // Toggle theme and save preference
  void _toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode; // Switch between light and dark mode
      prefs.setBool('isDarkMode', _isDarkMode); // Save the new preference
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(), // Apply theme based on preference
      home: NotesScreen(toggleTheme: _toggleTheme), // Home screen with theme toggle functionality
    );
  }
}

class NotesScreen extends StatefulWidget {
  final Function toggleTheme;
  NotesScreen({required this.toggleTheme});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late Database _database; // SQLite database instance
  List<Map<String, dynamic>> _notes = []; // List to store fetched notes
  TextEditingController _noteController = TextEditingController(); // Controller for note input field
  TextEditingController _searchController = TextEditingController(); // Controller for search input field
  int? _editingId; // Stores ID of note being edited

  @override
  void initState() {
    super.initState();
    _initDatabase(); // Initialize SQLite database on startup
  }

  // Initialize SQLite database
  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'notes.db'), // Set database path
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT)", // Create notes table
        );
      },
      version: 1,
    );
    _fetchNotes(); // Fetch existing notes
  }

  // Fetch notes from database (with optional search query)
  Future<void> _fetchNotes({String query = ''}) async {
    final List<Map<String, dynamic>> notes = query.isEmpty
        ? await _database.query('notes') // Fetch all notes
        : await _database.query(
      'notes',
      where: 'content LIKE ?',
      whereArgs: ['%$query%'], // Search for notes containing query
    );
    setState(() {
      _notes = notes; // Update notes list
    });
  }

  // Add or update note
  Future<void> _addOrUpdateNote() async {
    if (_noteController.text.isNotEmpty) {
      if (_editingId == null) {
        await _database.insert('notes', {'content': _noteController.text}); // Insert new note
      } else {
        await _database.update(
          'notes',
          {'content': _noteController.text}, // Update existing note
          where: 'id = ?',
          whereArgs: [_editingId],
        );
        _editingId = null; // Reset editing ID after update
      }
      _noteController.clear(); // Clear input field
      _fetchNotes(); // Refresh notes list
    }
  }

  // Delete note from database
  Future<void> _deleteNote(int id) async {
    await _database.delete('notes', where: 'id = ?', whereArgs: [id]); // Delete note by ID
    _fetchNotes(); // Refresh notes list
  }

  // Load selected note for editing
  void _editNote(Map<String, dynamic> note) {
    setState(() {
      _editingId = note['id']; // Store note ID for editing
      _noteController.text = note['content']; // Load note content into text field
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6), // Theme toggle button
            onPressed: () => widget.toggleTheme(),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent], // Gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search notes',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => _fetchNotes(query: _searchController.text), // Trigger search
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'Enter a note',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: _addOrUpdateNote, // Save or update note
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_notes[index]['content']), // Display note content
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editNote(_notes[index]), // Edit note
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteNote(_notes[index]['id']), // Delete note
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}