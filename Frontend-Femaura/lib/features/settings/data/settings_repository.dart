import 'package:femaura/core/api/endpoint.dart';
import 'package:femaura/core/api/repository.dart';
import 'package:femaura/features/settings/data/models/profile_model.dart';

class SettingsRepository extends Repository {
  SettingsRepository(super.ref);

  Future<ProfileModel> getProfile() async {
    final response = await api.get(Endpoint.profile);
    return ProfileModel.fromMap(response as Map<String, dynamic>);
  }
}

final settingsRepositoryProvider = RepositoryProvider(SettingsRepository.new);
