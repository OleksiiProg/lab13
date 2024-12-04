import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotesScreen(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noteController = TextEditingController();

  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Завантаження записів із бази даних
  Future<void> _loadNotes() async {
    try {
      final notes = await DBHelper().getNotes();
      setState(() {
        _notes = notes;
      });
    } catch (e) {
      print('Error loading notes: $e');
    }
  }

  // Додавання запису до бази даних
  Future<void> _addNote() async {
    if (_formKey.currentState!.validate()) {
      try {
        await DBHelper().insertNote(_noteController.text);
        _noteController.clear();
        _loadNotes();
      } catch (e) {
        print('Error adding note: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Enter a note',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Note cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addNote,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _notes.isEmpty
                ? const Center(child: Text('No notes yet!'))
                : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                final content = note['content'] ?? 'No content';
                final createdAt = note['created_at'] != null
                    ? DateTime.parse(note['created_at']).toLocal()
                    : DateTime.now();
                return ListTile(
                  title: Text(content),
                  subtitle: Text(
                    '${createdAt.day}-${createdAt.month}-${createdAt.year} ${createdAt.hour}:${createdAt.minute}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

