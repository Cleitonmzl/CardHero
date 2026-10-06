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
    // 127.0.0.1:3000 funciona no celular físico via 'adb reverse tcp:3000 tcp:3000' e no Linux Desktop.
    // (Se um dia usar emulador do Android Studio, trocar para 10.0.2.2:3000).
    final apiClient = ApiClient(baseUrl: "http://127.0.0.1:3000");
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
