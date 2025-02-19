import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ukk_isnaini_2025/kategoripage.dart';
import 'package:ukk_isnaini_2025/taskaddpage.dart';
import 'package:ukk_isnaini_2025/taskdetailpage.dart';

class Homepage extends StatefulWidget {
  final String role;
  const Homepage({super.key, required this.role});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController taskController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  bool? _isAdminCache;

  Future<bool> _isAdmin() async {
    if (_isAdminCache != null) return _isAdminCache!;
    if (user == null) return false;
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user!.uid).get();
      bool isAdmin = userDoc.exists && (userDoc['role'] == 'admin');
      setState(() {
        _isAdminCache = isAdmin;
      });
      return isAdmin;
    } catch (_) {
      return false;
    }
  }

  void _addTask() async {
    String taskText = taskController.text.trim();
    if (taskText.isEmpty) {
      _showSnackBar("Tugas tidak boleh kosong");
      return;
    }
    try {
      await _firestore.collection('tasks').add({
        'task': taskText,
        'assignedBy': user?.uid ?? '',
        'assignedTo': "",
        'status': 'ToDo',
        'createdAt': FieldValue.serverTimestamp(),
      });
      taskController.clear();
      setState(() {});
    } catch (e) {
      _showSnackBar("Gagal menambahkan tugas: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _takeTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'assignedTo': user?.uid ?? '',
        'status': 'In Progress',
      });
      _showSnackBar("Tugas berhasil diambil");
    } catch (e) {
      _showSnackBar("Gagal mengambil tugas: $e");
    }
  }

  void _submitTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': 'Complete',
      });
      _showSnackBar("Tugas berhasil diselesaikan");
    } catch (e) {
      _showSnackBar("Gagal menyelesaikan tugas: $e");
    }
  }

  void _openTaskDetail(String taskId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(taskId: taskId),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Log Out'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HomePage To Do ${widget.role}')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Tambah tugas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskAddPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.category_sharp),
              title: Text('Katagori'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KategoriPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log Out'),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('tasks')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Terjadi kesalahan saat memuat tugas."));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Tidak ada tugas."));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var task = snapshot.data!.docs[index];
                    var taskData = task.data() as Map<String, dynamic>;
                    String taskStatus = taskData['status'] ?? 'Tidak diketahui';

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Text(taskData['task'] ?? "Tugas tanpa nama",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Row(
                          children: [
                            Text('Status: $taskStatus'),
                            Spacer(),
                            DropdownButton<String>(
                              value: taskStatus,
                              onChanged: (newStatus) {
                                _firestore
                                    .collection('tasks')
                                    .doc(task.id)
                                    .update({
                                  'status': newStatus,
                                });
                              },
                              items: <String>[
                                'ToDo',
                                'In Progress',
                                'Complete'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        onTap: () => _openTaskDetail(task.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
