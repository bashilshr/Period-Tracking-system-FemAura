import 'package:femaura/core/utils/entity.dart';
import 'package:femaura/features/settings/domain/entity/profile_entity.dart';

class SettingsEntity extends Entity {
  final ProfileEntity profile;
  const SettingsEntity({this.profile = const ProfileEntity()});
  @override
  SettingsEntity copyWith({ProfileEntity? profile}) {
    return SettingsEntity(profile: profile ?? this.profile);
  }

  @override
  List<Object> get props => [profile];
}
