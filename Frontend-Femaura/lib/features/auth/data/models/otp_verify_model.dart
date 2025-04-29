class OtpVerifyModel {
  const OtpVerifyModel({this.email, this.otp});

  final String? email;
  final String? otp;

  Map<String, dynamic> toMap() {
    return {'email': email, 'otp': otp};
  }
}
