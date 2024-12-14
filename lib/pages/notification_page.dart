import 'package:dental_app/services/notification_service.dart';
import 'package:dental_app/services/save_notifications_servic.dart';
import 'package:dental_app/style/default_layouts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:firebase_auth/firebase_auth.dart';

DateTime scheduleTime = DateTime.now();

List<String> notificationBodies = [
  'Éves ellenőrzés',
  'Fogkőeltávolítás',
  'Gyulladt íny kezelése foganként',
  'Helyi röntgenfelvétel'
];

class NotificationPage extends StatefulWidget {
  @override
  State<NotificationPage> createState() => _MyNotificationPageState();
}

class _MyNotificationPageState extends State<NotificationPage> {
  late User? _user;
  bool _isLoading = false;
  String bodyText = notificationBodies[0];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Értesítések kezelése'),
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
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const DatePickerTxt(),
                  const SizedBox(height: 20),
                  DropdownButton<String>(
                    value: bodyText,
                    onChanged: (newValue) {
                      setState(() {
                        bodyText = newValue!;
                      });
                    },
                    items: notificationBodies
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ScheduleBtn(
                      user: _user,
                      isLoading: _isLoading,
                      onPressed: () async {
                        if (_user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Be kell jelentkezned.'),
                          ));
                          return;
                        }

                        if (scheduleTime == DateTime.now() ||
                            scheduleTime.isBefore(DateTime.now())) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Kérlek, válassz egy jövőbeli dátumot és időt!'),
                          ));
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        await NotificationService().saveNotificationToFirestore(
                          body: bodyText,
                          scheduledTime: scheduleTime,
                          userId: _user!.uid,
                        );

                        final localNotificationId =
                            DateTime.now().millisecondsSinceEpoch ~/ 1000;

                        await NotificationService().scheduleNotification(
                          id: localNotificationId,
                          title: '',
                          body: bodyText,
                          scheduledNotificationDateTime: scheduleTime,
                        );

                        setState(() {
                          _isLoading = false;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Értesítés sikeresen létrehozva.'),
                        ));
                      }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FirestoreNotificationsList(),
            ),
          ],
        ),
      ),
    );
  }
}

class DatePickerTxt extends StatefulWidget {
  const DatePickerTxt({Key? key}) : super(key: key);

  @override
  State<DatePickerTxt> createState() => _DatePickerTxtState();
}

class _DatePickerTxtState extends State<DatePickerTxt> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        DatePickerBdaya.showDateTimePicker(
          context,
          showTitleActions: true,
          minTime: DateTime(2018, 1, 1),
          maxTime: DateTime(2025, 12, 31),
          currentTime: DateTime.now(),
          locale: LocaleType.en,
          onChanged: (date) {
            print('change $date');
            setState(() {
              scheduleTime = date!;
            });
          },
          onConfirm: (date) {
            print('confirm $date');
            setState(() {
              scheduleTime = date!;
            });
          },
        );
      },
      child: const Text(
        'Dátum és idő kiválasztása',
      ),
    );
  }
}

class ScheduleBtn extends StatelessWidget {
  final User? user;
  final bool isLoading;
  final Function() onPressed;

  const ScheduleBtn({
    Key? key,
    required this.user,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? CircularProgressIndicator()
          : const Text('Értesítő mentése'),
    );
  }
}
