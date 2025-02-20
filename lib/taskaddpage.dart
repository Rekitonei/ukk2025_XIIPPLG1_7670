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
  final User? user = FirebaseAuth.instance.currentUser;

  TextEditingController taskController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();

  List<String> categories = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  
  void _loadCategories() async {
    if (user == null) return;

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('kategori')
          .where('userId', isEqualTo: user!.uid) 
          .get();

      setState(() {
        categories = querySnapshot.docs
            .map((doc) => doc['nama'] as String) 
            .toList();
        if (categories.isNotEmpty) {
          selectedCategory =
              categories.first; 
        }
      });
    } catch (e) {
      print("❌ Gagal mengambil kategori: $e");
    }
  }

  void _addTask() async {
    String taskText = taskController.text.trim();
    deskripsiController.text.trim();

    if (taskText.isEmpty) {
      _showSnackBar("Tugas tidak boleh kosong");
      return;
    }

    if (selectedCategory == null) {
      _showSnackBar("Pilih kategori tugas terlebih dahulu");
      return;
    }

    try {
      await _firestore.collection('tasks').add({
        'task': taskController.text,
        'userId': user!.uid,
        'deskripsi':deskripsiController.text,
        'status': 'ToDo',
        'category': selectedCategory,
        'createdAt': FieldValue.serverTimestamp(), 
      });

      taskController.clear();
      deskripsiController.clear();

      Navigator.pop(context);
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
            const Text("Tambah Tugas",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: 'Nama Tugas',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            const Text("Deskripsi Tugas",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: deskripsiController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Kategori",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),


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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),

            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _addTask,
                icon: Icon(Icons.add, color: Colors.grey),
                label: Text("Tambah", style: TextStyle(color: Colors.black)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  side: BorderSide(color: Colors.blueGrey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
