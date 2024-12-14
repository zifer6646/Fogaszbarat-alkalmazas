import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dental_app/models/doctors_model.dart';
import 'package:dental_app/style/default_layouts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateDoctorsPage extends StatefulWidget {
  @override
  _RateDoctorsPageState createState() => _RateDoctorsPageState();
}

class _RateDoctorsPageState extends State<RateDoctorsPage> {
  final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Doctor> doctors = [];
  List<String> userDoctorName = [];

  @override
  void initState() {
    super.initState();
    loadDoctors();
  }

  void loadDoctors() async {
    var doctorCollection = _firestore.collection('doctors');
    var docSnapshot = await doctorCollection.get();
    docSnapshot.docs.forEach((doc) {
      var data = doc.data() as Map<String, dynamic>;
      double rating = (data['averageRating'] is int)
          ? data['averageRating'].toDouble()
          : (data['averageRating'] ?? 0.0);
      setState(() {
        doctors.add(Doctor(
            id: doc.id,
            name: data['name'],
            rating: rating,
            examination: data['examination']));
      });
    });

    var bookingCollection = _firestore.collection('booking');
    var querySnapshot = await bookingCollection
        .where('userID', isEqualTo: currentUserUid)
        .get();
    querySnapshot.docs.forEach((doc) {
      var data = doc.data() as Map<String, dynamic>;
      if (data['doctor'] != null) {
        setState(() {
          userDoctorName.add(data['doctor']);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doktorok értékelése'),
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
        child: ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            Doctor doctor = doctors[index];
            bool canRate = userDoctorName.contains(doctor.name);
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 4,
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Specialitása: ${doctor.examination}',
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey[700])),
                    SizedBox(height: 10),
                    RatingBar.builder(
                      initialRating: doctor.rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4),
                      itemBuilder: (context, _) =>
                          Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: canRate
                          ? (rating) {
                              setState(() {
                                doctor.rating = rating;
                              });
                              updateDoctorRating(doctor.id, rating);
                            }
                          : (rating) {},
                      ignoreGestures: !canRate,
                      unratedColor: Colors.amber.withAlpha(50),
                      updateOnDrag: true,
                    ),
                    if (!canRate)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text("Értékelés csak foglalás esetén!",
                            style: TextStyle(color: Colors.red, fontSize: 14)),
                      )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void updateDoctorRating(String docId, double rating) async {
    if (!mounted) return;

    try {
      DocumentReference ratingRef = _firestore.collection('ratings').doc();
      await ratingRef.set({
        'doctorId': docId,
        'rating': rating,
        'userId': currentUserUid,
        'timestamp': FieldValue.serverTimestamp()
      });

      QuerySnapshot ratingsQuery = await _firestore
          .collection('ratings')
          .where('doctorId', isEqualTo: docId)
          .get();
      double totalRating = 0;
      ratingsQuery.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalRating += data['rating'];
      });

      double averageRating = totalRating / ratingsQuery.docs.length;
      await _firestore
          .collection('doctors')
          .doc(docId)
          .update({'averageRating': averageRating});
    } catch (error) {
      print('Error updating doctor rating: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Hiba az orvos értékelés frissítésekor: $error')));
      }
    }
  }
}
