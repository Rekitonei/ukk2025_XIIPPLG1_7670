import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;
  const TaskDetailPage({super.key, required this.taskId});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String taskName = "";
  String description = "";
  String taskStatus = "ToDo";
  String createdAt = "";
  String? taskCategory;
  List<String> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
    _loadCategories();
  }

  void _loadTaskDetails() async {
    try {
      DocumentSnapshot taskSnapshot =
          await _firestore.collection('tasks').doc(widget.taskId).get();
      if (taskSnapshot.exists) {
        setState(() {
          taskName = taskSnapshot['task'];
          description = taskSnapshot['deskripsion'];
          taskStatus = taskSnapshot['status'];
          taskCategory = taskSnapshot['category'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading task details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('kategori').get();
      setState(() {
        categories =
            querySnapshot.docs.map((doc) => doc['nama'] as String).toList();
      });
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  void _updateStatus(String newStatus) async {
    await _firestore.collection('tasks').doc(widget.taskId).update({
      'status': newStatus,
    });
    setState(() {
      taskStatus = newStatus;
    });
  }

  void _deleteTask() async {
    await _firestore.collection('tasks').doc(widget.taskId).delete();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Tugas berhasil dihapus")));
    Navigator.pop(context);
  }

  void _editTask() {
    TextEditingController taskController =
        TextEditingController(text: taskName);
    TextEditingController descriptionController =
        TextEditingController(text: description);
    String? selectedCategory = taskCategory;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Tugas"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 5,),
              TextField(
                controller: taskController,
                decoration: InputDecoration(labelText: "Judul Tugas"),
              ),
              SizedBox(height: 10,),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Deskripsi"),
              ),
              SizedBox(height: 15,),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                hint: Text("Pilih Kategori"),
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                items: categories.map<DropdownMenuItem<String>>((String cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: "Pilih Kategori",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('tasks').doc(widget.taskId).update({
                  'task': taskController.text.trim(),
                  'deskripsion': descriptionController.text.trim(),
                  'category': selectedCategory,
                });
                setState(() {
                  taskName = taskController.text.trim();
                  description = descriptionController.text.trim();
                  taskCategory = selectedCategory;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Tugas berhasil diperbarui")));
              },
              child: Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Tugas"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editTask,
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Hapus Tugas"),
                  content: Text("Apakah Anda yakin ingin menghapus tugas ini?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteTask();
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("Hapus"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Judul Tugas:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(taskName, style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  Text("Kategori Tugas:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(taskCategory ?? "Tidak ada kategori",
                      style: TextStyle(fontSize: 16, color: Colors.black87)),
                  SizedBox(height: 20),
                  Text("Deskripsi Tugas:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(description,
                      style: TextStyle(fontSize: 16, color: Colors.black87)),
                  SizedBox(height: 20),
                  Text("Status Tugas:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  DropdownButton<String>(
                    value: taskStatus,
                    onChanged: (newStatus) {
                      if (newStatus != null) _updateStatus(newStatus);
                    },
                    items: ['ToDo', 'In Progress', 'Complete']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}
