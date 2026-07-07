import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../labels.dart';

class TypesScreen extends StatefulWidget {
  const TypesScreen({super.key});
  @override
  State<TypesScreen> createState() => _TypesScreenState();
}

class _TypesScreenState extends State<TypesScreen> {
  final _api = ApiService();
  late Future<Map<String, List<SarcomaType>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getTypes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<SarcomaType>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text(snap.error.toString(),
                style: const TextStyle(color: SanadColors.coral)),
          );
        }
        final data = snap.data ?? {};
        final cats = data.keys.toList();
        if (cats.isEmpty) {
          return const Center(child: Text('لا توجد أنواع'));
        }
        return DefaultTabController(
          length: cats.length,
          child: Column(
            children: [
              Material(
                color: Colors.white,
                child: TabBar(
                  isScrollable: true,
                  labelColor: SanadColors.teal900,
                  unselectedLabelColor: SanadColors.muted,
                  indicatorColor: SanadColors.amber,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                  tabs: cats
                      .map((c) => Tab(text: Labels.category[c] ?? c))
                      .toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: cats.map((c) {
                    final items = data[c] ?? [];
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, i) => _typeCard(items[i]),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _typeCard(SarcomaType t) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: SanadColors.teal100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(t.tag,
                  style: const TextStyle(
                      color: SanadColors.teal500,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
            const SizedBox(height: 12),
            Text(t.name,
                style: const TextStyle(
                    color: SanadColors.teal900,
                    fontWeight: FontWeight.w800,
                    fontSize: 17)),
            const SizedBox(height: 6),
            Text(t.description,
                style: const TextStyle(
                    color: SanadColors.muted, fontSize: 14, height: 1.6)),
          ],
        ),
      ),
    );
  }
}
