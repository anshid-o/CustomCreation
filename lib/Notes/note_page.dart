import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_creations/Notes/add_note_page.dart';
import 'package:custom_creations/Notes/note_details_page.dart';
import 'package:custom_creations/constants.dart';
import 'package:flutter/material.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  void _addNewNote() async {
    final newNote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNotePage()),
    );

    if (newNote != null) {
      // You might want to add this note to a Firestore collection or similar.
      // This is just for demo purposes.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cngreen,
      appBar: AppBar(
        backgroundColor: cngreen,
        title: Text(
          'Client Notes',
          style: TextStyle(color: col30, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
                color: col30, borderRadius: BorderRadius.circular(12)),
            child: IconButton(
              icon: Icon(
                Icons.add,
                size: 30,
              ),
              onPressed: _addNewNote,
            ),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
              'No notes found.',
              style: TextStyle(color: Colors.white),
            ));
          }
          final note_ids = snapshot.data!.docs
              .map(
                (e) => e.id,
              )
              .toList();
          final notes = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final note_id = note_ids[index];
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Card(
                  child: ListTile(
                    title: Text(
                      '${note['category']} for ${note['client']}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${note['location']} - ${note['summary']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailsPage(
                            note: note,
                            note_id: note_id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
