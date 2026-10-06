import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/configure_providers.dart';
import 'ui/page/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final data = await ConfigureProviders.createDependencyTree();

  runApp(CardHeroApp(data: data));
}

class CardHeroApp extends StatelessWidget {
  final ConfigureProviders data;

  const CardHeroApp({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: data.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CardHero',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F172A),
        ),
        home: const HomePage(),
      ),
    );
  }
}
