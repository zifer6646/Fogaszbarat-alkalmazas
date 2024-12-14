class UserData {
  final String firstName;
  final String lastName;
  final String email;
  final int age;

  UserData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'first name': firstName,
      'last name': lastName,
      'email': email,
      'age': age,
    };
  }
}
