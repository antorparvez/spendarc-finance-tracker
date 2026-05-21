import '../../core/network/base_api_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/micro_interaction_service.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/storage/secure_storage_service.dart';

/// App-wide services created at bootstrap and exposed via [RepositoryProvider].
class AppDependencies {
  AppDependencies({
    required this.localStorage,
    required this.secureStorage,
    required this.connectivity,
    required this.apiClient,
    required this.apiService,
    required this.haptic,
    required this.microInteraction,
  });

  final LocalStorageService localStorage;
  final SecureStorageService secureStorage;
  final ConnectivityService connectivity;
  final DioClient apiClient;
  final BaseApiService apiService;
  final HapticService haptic;
  final MicroInteractionService microInteraction;

  factory AppDependencies.create({
    required LocalStorageService localStorage,
    required SecureStorageService secureStorage,
  }) {
    final connectivity = ConnectivityService();
    final apiClient = DioClient(
      tokenProvider: () => secureStorage.getAccessToken(),
      onSessionExpired: secureStorage.clearSession,
      connectivityChecker: connectivity.isConnected,
    );
    final apiService = BaseApiService(
      apiClient,
      onUnauthorized: secureStorage.clearSession,
    );
    return AppDependencies(
      localStorage: localStorage,
      secureStorage: secureStorage,
      connectivity: connectivity,
      apiClient: apiClient,
      apiService: apiService,
      haptic: HapticService(),
      microInteraction: const MicroInteractionService(),
    );
  }
}
