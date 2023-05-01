import 'package:flutter/material.dart';
import 'package:untitled/sqlite/SqlHelper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQLite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter SQLite'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;
  final TextEditingController _titleController = TextEditingController(),
                        _descriptionController = TextEditingController();

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    print("data: $data");

    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshJournals();
    print("..number of items ${_journals.length}");
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(_titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  void _showForm(int? id) async {
    print("add item");
    print("..number of items ${_journals.length}");

    if (id != null) {
      final existingJournal = _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true  ,
      builder: (_) => Container(
        padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: MediaQuery.of(context).viewInsets.bottom + 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () async {
                if(id == null) {
                  await _addItem();
                }
                if(id != null) {
                  await _updateItem(id);
                }

                // Clear the text fields
                _titleController.text = "";
                _descriptionController.text = "";

                // Close the bottom sheet
                Navigator.pop(context);
              },
              child: Text(id == null ? "Create New" : "Update Item"),
            )
          ],
        ),
      ),
    );
  }

  // Update an existing item
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading ? const Center(
        child: CircularProgressIndicator(),
      ) : ListView.builder(
        itemCount: _journals.length,
        itemBuilder: (context, index) => Card(
          color: Colors.blue[200],
          margin: const EdgeInsets.all(15),
          child: ListTile(
              title: Text(_journals[index]['title']),
              subtitle: Text(_journals[index]['description']),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit,),
                      onPressed: () => _showForm(_journals[index]['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete,),
                      onPressed: () =>
                          _deleteItem(_journals[index]['id']),
                    ),
                  ],
                ),
              )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
