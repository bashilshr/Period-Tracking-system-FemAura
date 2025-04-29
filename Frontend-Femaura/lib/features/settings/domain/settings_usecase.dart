import 'package:femaura/core/api/usecase.dart';
import 'package:femaura/features/settings/domain/entity/profile_entity.dart';
import 'package:femaura/features/settings/data/settings_repository.dart';

class SettingsUsecase extends UseCase {
  SettingsUsecase(super.ref);

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  Future<ProfileEntity> getProfile() async {
    final response = await _repo.getProfile();
    return ProfileEntity(
      username: response.username ?? '',
      email: response.email ?? '',
    );
  }
}

final settingsUsecaseProvider = UseCaseProvider(SettingsUsecase.new);
