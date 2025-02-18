import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskAddPage extends StatefulWidget {
  const TaskAddPage({super.key});

  @override
  _TaskAddPageState createState() => _TaskAddPageState();
}

class _TaskAddPageState extends State<TaskAddPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController taskController = TextEditingController(),
      catagoryController = TextEditingController(),
      deskripsionController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  void _addTask() async {
    String taskText = taskController.text.trim();
    String catagoryText = catagoryController.text.trim();
    String deskripsion = deskripsionController.text.trim();
    if (taskText.isEmpty) {
      _showSnackBar("Tugas tidak boleh kosong");
      return;
    }
    try {
      await _firestore.collection('tasks').add({
        'task': taskText,
        'catagory': catagoryText,
        'deskripsion': deskripsion,
        'assignedBy': user?.uid ?? '',
        'status': 'ToDo',
        'createdAt': FieldValue.serverTimestamp(),
      });
      taskController.clear();
      Navigator.pop(context); // Go back after adding task
    } catch (e) {
      _showSnackBar("Gagal menambahkan tugas: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Tugas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tambah Tugas",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: 'Tugas Baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            Text("Katagori",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: catagoryController,
              decoration: InputDecoration(
                
                labelText: 'Katagori',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            Text("Deskripsi Tugas",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              
              controller: deskripsionController,
              decoration: InputDecoration(
                
                labelText: 'Deskripsi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _addTask,
                icon: Icon(Icons.add, color: Colors.blue),
                label: Text("Tambah", style: TextStyle(color: Colors.blue)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  side: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
