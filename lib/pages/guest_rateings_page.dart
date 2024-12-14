import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dental_app/models/doctors_model.dart';
import 'package:dental_app/style/default_layouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';

class RateGuest extends StatefulWidget {
  @override
  _RateGuestState createState() => _RateGuestState();
}

class _RateGuestState extends State<RateGuest> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Doctor> doctors = [];

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orvosaink értékelései'),
        backgroundColor: titleColor,
        titleTextStyle: titleText,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(FontAwesomeIcons.arrowLeft),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
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
            var doctor = doctors[index];
            return Card(
              elevation: 4.0,
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6.0),
                    Text('Specialitása: ${doctor.examination}',
                        style:
                            TextStyle(fontSize: 16.0, color: Colors.grey[700])),
                    SizedBox(height: 6.0),
                    RatingBar.builder(
                      initialRating: doctor.rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) =>
                          Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {},
                      ignoreGestures: true,
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
}
