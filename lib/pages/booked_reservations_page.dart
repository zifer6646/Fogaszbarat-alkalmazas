import 'package:dental_app/style/default_layouts.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookedReservationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foglalások'),
        backgroundColor: titleColor,
        titleTextStyle: titleText,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDAE2F8), Color(0xFF9D50BB)],
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('booking')
              .where('userID', isEqualTo: currentUserUid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red)),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            var documents = snapshot.data!.docs;
            if (documents.isEmpty) {
              return Center(child: Text('Nincsenek foglalásaid.'));
            }

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = documents[index];
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                Timestamp timestamp = data['time'];
                DateTime dateTime = timestamp.toDate();
                String formattedTime =
                    DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

                return Card(
                  child: ListTile(
                    title: Text('Szolgáltatás: ${data['examination']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Doktor: ${data['doctor']}'),
                        Text('Időpont: $formattedTime'),
                      ],
                    ),
                    onTap: () =>
                        _showDeleteConfirmationDialog(context, document.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String documentId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Foglalás törlése'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Biztosan törölni szeretné ezt a foglalást?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Mégse'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Lemondás'),
              onPressed: () {
                _deleteBooking(documentId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteBooking(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('booking')
          .doc(documentId)
          .delete();
    } catch (error) {
      print('Error deleting booking: $error');
    }
  }
}
