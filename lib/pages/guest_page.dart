import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dental_app/models/guest_services_modell.dart';
import 'package:dental_app/pages/guest_rateings_page.dart';
import 'package:dental_app/style/default_layouts.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({Key? key}) : super(key: key);

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  int _selectedIndex = 0;
  List<String> uniqueExaminations = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUniqueExaminations();
  }

  void loadUniqueExaminations() async {
    Set<String> examinationSet = Set<String>();
    try {
      var querySnapshot = await _firestore.collection('doctors').get();
      for (var doc in querySnapshot.docs) {
        var examination = doc.data()['examination'] as String? ?? '';
        examinationSet.add(examination);
      }
      setState(() {
        uniqueExaminations = examinationSet.toList();
        _pages.add(ServicesPage());
        _pages.add(RateGuest());
        _isLoading = false;
        _showLimitationDialog(availableServices, unavailableServices);
      });
    } catch (e) {
      print("Error loading examinations: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLimitationDialog(
      List<String> availableServices, List<String> unavailableServices) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Vendégként korlátozott a hozzáférésed a következőkhöz:',
            style: TextStyle(fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Elérhető szolgáltatások:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...availableServices
                    .map((service) => Text('- $service'))
                    .toList(),
                SizedBox(height: 10),
                Text('Nem elérhető szolgáltatások:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...unavailableServices
                    .map((service) => Text('- $service'))
                    .toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget ServicesPage() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: titleColor,
        titleTextStyle: titleText,
        title: Text("Szolgáltatásaink"),
        centerTitle: true,
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
          itemCount: uniqueExaminations.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(uniqueExaminations[index]),
                leading: Icon(Icons.check_circle_outline),
              ),
            );
          },
        ),
      ),
    );
  }

  final List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFDAE2F8), Color(0xFF9D50BB)],
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : (_selectedIndex < _pages.length
              ? _pages[_selectedIndex]
              : Center(child: Text("Nincs megjeleníthető oldal"))),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Szolgáltatások',
              ),
              GButton(
                icon: Icons.star_rate,
                text: 'Értékelések',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _navigateBottomBar,
          ),
        ),
      ),
    );
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
