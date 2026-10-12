import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/database/app_database.dart';
import '../../data/database/dao/hero_dao.dart';
import '../../data/network/client/api_client.dart';
import '../../data/repository/hero_repository.dart';

class ConfigureProviders {
  final List<SingleChildWidget> providers;

  ConfigureProviders({required this.providers});

  static Future<ConfigureProviders> createDependencyTree() async {
    // API REST remota no Render (acessível via Wi-Fi/4G e sem necessidade de adb reverse ou json-server local)
    final apiClient = ApiClient(baseUrl: "https://super-hero-api-lvx2.onrender.com");
    final appDatabase = AppDatabase();
    final heroDao = HeroDao(appDatabase: appDatabase);

    final heroRepository = HeroRepository(
      apiClient: apiClient,
      heroDao: heroDao,
    );

    // Garante que o jogador comece com 5 agentes no esquadrão/inventário
    await heroRepository.ensureInitialSquad();

    return ConfigureProviders(providers: [
      Provider<ApiClient>.value(value: apiClient),
      Provider<AppDatabase>.value(value: appDatabase),
      Provider<HeroDao>.value(value: heroDao),
      Provider<HeroRepository>.value(value: heroRepository),
    ]);
  }
}
