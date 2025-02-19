import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  _KategoriPageState createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController kategoriController = TextEditingController();

  void _tambahKategori() async {
    String namaKategori = kategoriController.text.trim();
    if (namaKategori.isNotEmpty) {
      await _firestore.collection('kategori').add({'nama': namaKategori});
      kategoriController.clear();
    }
  }

  void _editKategori(String id, String namaLama) {
    TextEditingController editController =
        TextEditingController(text: namaLama);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Kategori"),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(labelText: "Nama Kategori"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              String namaBaru = editController.text.trim();
              if (namaBaru.isNotEmpty) {
                await _firestore
                    .collection('kategori')
                    .doc(id)
                    .update({'nama': namaBaru});
                Navigator.pop(context);
              }
            },
            child: Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _hapusKategori(String id) async {
    await _firestore.collection('kategori').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kategori Tugas")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: kategoriController,
              decoration: InputDecoration(
                labelText: "Tambah Kategori",
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _tambahKategori,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('kategori').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  var kategoriList = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: kategoriList.length,
                    itemBuilder: (context, index) {
                      var kategori = kategoriList[index];
                      String id = kategori.id;
                      String nama = kategori['nama'];

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(nama),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editKategori(id, nama),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _hapusKategori(id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
