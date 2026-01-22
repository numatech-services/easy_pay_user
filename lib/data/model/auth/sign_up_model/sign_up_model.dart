class SignUpModel {
  final String firstName;
  final String lastName;
  final String mobile;
  final String email;
  final bool? agree;
  final String username;
  final String pin;
  final String countryCode;
  final String country;
  final String mobileCode;
  String? companyName;

  SignUpModel({
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.email,
    required this.agree,
    required this.username,
    required this.pin,
    required this.countryCode,
    required this.country,
    required this.mobileCode,
    this.companyName,
  });
}
