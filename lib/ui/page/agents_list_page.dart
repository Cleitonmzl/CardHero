import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero_model.dart';
import '../widgets/hero_card.dart';
import 'agent_details_page.dart';

class AgentsListPage extends StatefulWidget {
  const AgentsListPage({super.key});

  @override
  State<AgentsListPage> createState() => _AgentsListPageState();
}

class _AgentsListPageState extends State<AgentsListPage> {
  late final HeroRepository _heroRepository;

  // Controlador de paginação infinita carregando 20 heróis por página
  late final PagingController<int, HeroModel> _pagingController = PagingController<int, HeroModel>(
    getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => _heroRepository.getHeroes(page: pageKey, limit: 20),
  );

  @override
  void initState() {
    super.initState();
    _heroRepository = Provider.of<HeroRepository>(context, listen: false);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          "Catálogo de Agentes",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Recarregar",
            onPressed: () => _pagingController.refresh(),
          ),
        ],
      ),
      body: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => PagedListView<int, HeroModel>(
          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<HeroModel>(
            itemBuilder: (context, hero, index) => HeroCard(
              hero: hero,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AgentDetailsPage(hero: hero),
                  ),
                );
              },
            ),
            firstPageProgressIndicatorBuilder: (_) => const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
            newPageProgressIndicatorBuilder: (_) => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),
            ),
            newPageErrorIndicatorBuilder: (context) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: TextButton.icon(
                  onPressed: () => _pagingController.fetchNextPage(),
                  icon: const Icon(Icons.wifi_off_rounded, color: Colors.amberAccent, size: 18),
                  label: const Text(
                    "Sem conexão para carregar mais heróis (Toque para tentar novamente)",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ),
            noItemsFoundIndicatorBuilder: (_) => const Center(
              child: Text(
                "Nenhum agente encontrado.",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
