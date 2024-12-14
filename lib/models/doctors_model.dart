class Doctor {
  String id;
  String name;
  double rating;
  String examination;

  Doctor(
      {required this.id,
      required this.name,
      required this.rating,
      this.examination = ''});
}
