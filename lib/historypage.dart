import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Historypage extends StatefulWidget {
  const Historypage({super.key});

  @override
  State<Historypage> createState() => _HistorypageState();
}

class _HistorypageState extends State<Historypage> {
  User? user;
  List<Map<String, dynamic>> completedTasks = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCompletedTasks();
  }

  Future<void> fetchCompletedTasks() async {
    setState(() => isLoading = true);
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot taskSnapshot = await FirebaseFirestore.instance
            .collection('history')
            .where('userId', isEqualTo: user!.uid)
            .where('status', isEqualTo: 'complete')
            .get();
        setState(() {
          completedTasks = taskSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data: ${e.toString()}')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Tugas'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : completedTasks.isEmpty
              ? Center(child: Text("Tidak ada tugas yang telah diselesaikan"))
              : ListView.builder(
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(completedTasks[index]['title'] ?? 'Tidak ada judul'),
                      subtitle: Text(completedTasks[index]['description'] ?? 'Tidak ada deskripsi'),
                      trailing: Icon(Icons.check_circle, color: Colors.green),
                    );
                  },
                ),
    );
  }
}