import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final data = await DatabaseHelper.instance.fetchItems();
    setState(() {
      _items = data;
    });
  }

  Future<void> _addItem() async {
    if (_controller.text.isNotEmpty) {
      await DatabaseHelper.instance.insertItem(_controller.text);
      _controller.clear();
      _loadItems();
    }
  }

  Future<void> _updateItem(int id) async {
    if (_controller.text.isNotEmpty) {
      await DatabaseHelper.instance.updateItem(id, _controller.text);
      _controller.clear();
      _loadItems();
    }
  }

  Future<void> _deleteItem(int id) async {
    await DatabaseHelper.instance.deleteItem(id);
    _loadItems();
  }

  void _showEditDialog(int id, String currentName) {
    _controller.text = currentName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Item"),
        content: TextField(controller: _controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(onPressed: () { _updateItem(id); Navigator.pop(context); }, child: Text("Update")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutter SQLite Example")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Enter item"),
                  ),
                ),
                IconButton(icon: Icon(Icons.add), onPressed: _addItem),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text(item['name']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () => _showEditDialog(item['id'], item['name'])),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteItem(item['id'])),
                    ],
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

