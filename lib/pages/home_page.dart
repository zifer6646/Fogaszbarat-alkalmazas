import 'package:dental_app/pages/account_page.dart';
import 'package:dental_app/pages/reservation_page.dart';
import 'package:dental_app/pages/chatbot_page.dart';
import 'package:dental_app/pages/notification_page.dart';
import 'package:dental_app/pages/rateings_page.dart';
import 'package:dental_app/pages/booked_reservations_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final user = FirebaseAuth.instance.currentUser!;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    ReservationPage(),
    ChatBotPage(),
    BookedReservationsPage(),
    NotificationPage(),
    RateDoctorsPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
          child: GNav(
            selectedIndex: _selectedIndex,
            onTabChange: _navigateBottomBar,
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            padding: EdgeInsets.all(10),
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Főoldal',
              ),
              GButton(
                icon: Icons.message,
                text: 'AI asszisztens',
              ),
              GButton(
                icon: Icons.book,
                text: 'Foglalások',
              ),
              GButton(
                icon: Icons.notifications,
                text: 'Értesitések',
              ),
              GButton(
                icon: Icons.star_rate,
                text: 'Értékelések',
              ),
              GButton(
                icon: Icons.person,
                text: 'Fiók',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
