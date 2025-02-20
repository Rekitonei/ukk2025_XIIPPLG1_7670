import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ukk_isnaini_2025/historypage.dart';
import 'package:ukk_isnaini_2025/kategoripage.dart';
import 'package:ukk_isnaini_2025/profilepage.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveToHistory(Map<String, dynamic> taskData) async {
    try {
      await _firestore.collection('history').add(taskData);
    } catch (e) {
      _showSnackBar("Gagal menyimpan ke history: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('HomePage To Do')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profilepage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah tugas'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskAddPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.category_sharp),
              title: const Text('Kategori'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => KategoriPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Historypage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Log Out'),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('tasks')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text("Terjadi kesalahan saat memuat tugas."));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tidak ada tugas."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var task = snapshot.data!.docs[index];
              var taskData = task.data() as Map<String, dynamic>;
              String taskStatus = taskData['status'] ?? 'ToDo';
              String taskCategory = taskData['category'] ?? 'Tanpa Kategori';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(taskData['task'] ?? "Tugas tanpa nama",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kategori: $taskCategory',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700])),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text('Status: $taskStatus'),
                          const Spacer(),
                          DropdownButton<String>(
                            value: taskStatus,
                            onChanged: (newStatus) async {
                              if (newStatus != null &&
                                  newStatus != taskStatus) {
                                try {
                                  await _firestore
                                      .collection('tasks')
                                      .doc(task.id)
                                      .update({
                                    'status': newStatus,
                                  });
                                  _showSnackBar(
                                      "Status diperbarui menjadi $newStatus");

                                  if (newStatus == 'Complete') {
                                    await _saveToHistory(taskData);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Historypage(),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  _showSnackBar("Gagal memperbarui status.");
                                }
                              }
                            },
                            items: <String>['ToDo', 'In Progress', 'Complete']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
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
    );
  }
}
