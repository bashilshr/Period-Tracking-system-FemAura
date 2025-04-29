import 'package:femaura/core/api/api_client.dart';
import 'package:femaura/core/api/endpoint.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _defaultBaseUrl = 'http://127.0.0.1:8000/api';

final _clientProvider = ProviderFamily<APIClient, String>(
  (_, baseUrl) => APIClient(baseUrl: baseUrl),
);

String getUrlWithEndpoint(EndpointMixin endpoint) {
  return '$_defaultBaseUrl/${endpoint.path}';
}

abstract class Repository {
  Repository(this.ref);

  final Ref ref;

  APIClient get api {
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: _defaultBaseUrl,
    );
    return ref.read(_clientProvider(baseUrl));
  }

  APIClient get externalApi => ref.read(_clientProvider(''));
}

typedef RepositoryProvider<R extends Repository> = Provider<R>;
