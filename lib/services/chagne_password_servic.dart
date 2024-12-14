import 'package:dental_app/style/default_layouts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordWidget extends StatefulWidget {
  @override
  _ChangePasswordWidgetState createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscured1 = true;
  bool _isObscured2 = true;

  Future<void> _reauthenticateAndChangePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showToast("Minden mezőt ki kell tölteni.");
      return;
    }

    if (newPassword != confirmPassword) {
      _showToast("A jelszavak nem egyeznek.");
      return;
    }

    String? currentPassword = await _promptForCurrentPassword();

    if (currentPassword == null || currentPassword.isEmpty) {
      _showToast("Az aktuális jelszót meg kell adni.");
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);

      _showToast("A jelszó sikeresen megváltozott.");
      await FirebaseAuth.instance.signOut();
      Navigator.of(context, rootNavigator: true);
    } catch (e) {
      print("Hiba történt: $e");
      _showToast("Hiba történt: $e");
    }
  }

  Future<String?> _promptForCurrentPassword() async {
    String? currentPassword;

    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _passwordController =
            TextEditingController();
        return AlertDialog(
          title: Text("Add meg az aktuális jelszavad"),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: "Jelenlegi jelszó"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Mégse"),
            ),
            TextButton(
              onPressed: () {
                currentPassword = _passwordController.text;
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );

    return currentPassword;
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _newPasswordController,
              obscureText: _isObscured1,
              decoration: InputDecoration(
                labelText: "Új jelszó",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscured1 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isObscured1 = !_isObscured1;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _isObscured2,
              decoration: InputDecoration(
                labelText: "Új jelszó megerősítése",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      _isObscured2 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isObscured2 = !_isObscured2;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _reauthenticateAndChangePassword,
                    child: Text("Jelszó mentése"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                      foregroundColor: Colors.white,
                      backgroundColor: titleColor,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
