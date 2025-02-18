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
  String category = "";
  String description = "";
  String taskStatus = "ToDo";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

  void _loadTaskDetails() async {
    try {
      DocumentSnapshot taskSnapshot =
          await _firestore.collection('tasks').doc(widget.taskId).get();
      if (taskSnapshot.exists) {
        setState(() {
          taskName = taskSnapshot['task'];
          category = taskSnapshot['catagory'];
          description = taskSnapshot['deskripsion'];
          taskStatus = taskSnapshot['status'];
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
    TextEditingController taskController = TextEditingController(text: taskName);
    TextEditingController categoryController = TextEditingController(text: category);
    TextEditingController descriptionController = TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Tugas"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(labelText: "Judul Tugas"),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(labelText: "Kategori"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Deskripsi"),
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
                  'catagory': categoryController.text.trim(),
                  'deskripsion': descriptionController.text.trim(),
                });
                setState(() {
                  taskName = taskController.text.trim();
                  category = categoryController.text.trim();
                  description = descriptionController.text.trim();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Tugas berhasil diperbarui")));
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
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(taskName, style: TextStyle(fontSize: 20)),

                  SizedBox(height: 20),

                  Text("Kategori:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(category, style: TextStyle(fontSize: 18, color: Colors.grey[700])),

                  SizedBox(height: 20),

                  Text("Deskripsi Tugas:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(description, style: TextStyle(fontSize: 16, color: Colors.black87)),

                  SizedBox(height: 20),

                  Text("Status Tugas:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
