import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveBooking(
    String doctor, String examination, DateTime time) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user signed in');
    }

    if (doctor.isEmpty || examination.isEmpty || time == null) {
      throw Exception('Missing required parameters');
    }

    QuerySnapshot userBookingsSnapshot = await FirebaseFirestore.instance
        .collection('booking')
        .where('time', isEqualTo: time)
        .where('userID', isEqualTo: user.uid)
        .get();

    if (userBookingsSnapshot.docs.isNotEmpty) {
      throw 'Már van foglalásod erre az időpontra.';
    }

    QuerySnapshot doctorBookingsSnapshot = await FirebaseFirestore.instance
        .collection('booking')
        .where('doctor', isEqualTo: doctor)
        .where('time', isEqualTo: time)
        .get();

    if (doctorBookingsSnapshot.docs.isNotEmpty) {
      throw 'A választott doktor már foglalt ebben az időpontban.';
    }

    Map<String, dynamic> bookingData = {
      'doctor': doctor,
      'examination': examination,
      'time': time,
      'userID': user.uid,
    };

    await FirebaseFirestore.instance
        .collection('booking')
        .doc()
        .set(bookingData);
  } catch (error) {
    print('Error saving booking: $error');
    throw error;
  }
}
