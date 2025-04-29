class ProfileModel {
  ProfileModel({this.id, this.username, this.email});

  final int? id;
  final String? username;
  final String? email;

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as int?,
      username: map['username'] as String?,
      email: map['email'] as String?,
    );
  }
}
