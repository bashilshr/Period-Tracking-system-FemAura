// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:femaura/core/utils/entity.dart';

class ProfileEntity extends Entity {
  const ProfileEntity({this.id = '', this.username = '', this.email = ''});
  final String id;
  final String username;
  final String email;

  @override
  ProfileEntity copyWith({String? id, String? username, String? email}) {
    return ProfileEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }

  @override
  List<Object> get props => [id, username, email];
}
