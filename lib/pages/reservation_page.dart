import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dental_app/services/booking_servic.dart';
import 'package:dental_app/style/default_layouts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime? selectedDate;
  String? selectedDoctor;
  TimeOfDay? selectedTime;

  List<String> availableHours = List.generate(
    9,
    (index) => '${(index + 8).toString().padLeft(2, '0')}:00',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Szolgáltatásaink'),
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
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(height: 10.0),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  _buildTile(context, 'Éves ellenőrzés'),
                  _buildTile(context, 'Fogkőeltávolítás'),
                  _buildTile(context, 'Gyulladt íny kezelése foganként'),
                  _buildTile(context, 'Helyi röntgenfelvétel'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = null;
          selectedDoctor = null;
          selectedTime = null;
        });
        showDialog(
          context: context,
          builder: (context) => _buildAppointmentForm(context, title),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(
              colors: [titleColor, buttonColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: gridTexts,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentForm(BuildContext context, String title) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dátum:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  DateTime? data = await _showDateSelection(context);
                  if (data != null) {
                    setState(() {
                      selectedDate = data;
                    });
                  }
                },
                child: Text(
                  selectedDate == null
                      ? 'Válassz dátumot'
                      : DateFormat.yMd().format(selectedDate!),
                  style: TextStyle(fontSize: 16, color: buttonColor),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Doktor:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  String? doctor = await _showDoctorSelection(context);
                  if (doctor != null) {
                    setState(() {
                      selectedDoctor = doctor;
                    });
                  }
                },
                child: Text(
                  selectedDoctor ?? 'Válassz doktort',
                  style: TextStyle(fontSize: 16, color: buttonColor),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Időpont:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  selectedTime = await _showTimeSelection(context);
                  setState(() {});
                },
                child: Text(
                  selectedTime == null
                      ? 'Válassz időpontot'
                      : '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 16, color: buttonColor),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Kilépés'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (selectedDate == null ||
                      selectedDoctor == null ||
                      selectedTime == null) {
                    throw 'Minden adatot ki kell választani!';
                  }

                  await saveBooking(
                      selectedDoctor!,
                      title,
                      DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute));

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Foglalás sikeres'),
                      content: Text('A foglalás sikeresen mentésre került!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Rendben'),
                        ),
                      ],
                    ),
                  ).then((_) {
                    Navigator.of(context).pop();
                  });
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Hiba történt'),
                      content: Text('Hiba: ${e.toString()}'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Rendben'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Foglalás'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showDoctorSelection(BuildContext context) async {
    List<String> doctors = [];

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('doctors').get();
      doctors = snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      print('Error loading doctors: $e');
      doctors = [];
    }
    return await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        String initialDoctor = selectedDoctor ?? doctors[0];

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Válassz doktort",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                CupertinoPicker(
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                    initialItem: doctors.indexOf(initialDoctor),
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedDoctor = doctors[index];
                    });
                  },
                  children: doctors.map((e) => Center(child: Text(e))).toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    selectedDoctor ??= doctors[0];
                    Navigator.of(context).pop(selectedDoctor);
                  },
                  child: Text("Kész"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<TimeOfDay?> _showTimeSelection(BuildContext context) async {
    return await showDialog<TimeOfDay>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Válassz időpontot",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                CupertinoPicker(
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                    initialItem:
                        availableHours.indexOf('${selectedTime?.hour ?? 8}:00'),
                  ),
                  onSelectedItemChanged: (int index) {
                    final selectedTimeString = availableHours[index];
                    setState(() {
                      selectedTime = TimeOfDay(
                          hour: int.parse(selectedTimeString.split(":")[0]),
                          minute: 0);
                    });
                  },
                  children: availableHours
                      .map((e) => Center(child: Text(e)))
                      .toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(selectedTime);
                  },
                  child: Text("Kész"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<DateTime?> _showDateSelection(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
  }
}
