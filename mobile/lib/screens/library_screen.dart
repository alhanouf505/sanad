import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../labels.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  String _q = '', _region = '', _topic = '', _type = '';
  final String _sort = 'year';
  late Future<List<Paper>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Paper>> _load() => _api.getPapers(
        q: _q, region: _region, topic: _topic, type: _type, sort: _sort,
      );

  void _refresh() => setState(() => _future = _load());

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _q = v;
      _refresh();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SanadColors.teal900,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ابحث بعنوان البحث أو كلمة مفتاحية…',
                  hintStyle: const TextStyle(color: Color(0xFF7BA9A5)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF7BA9A5)),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            _filters(),
            Expanded(
              child: FutureBuilder<List<Paper>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: SanadColors.amber),
                    );
                  }
                  if (snap.hasError) {
                    return _error(snap.error.toString());
                  }
                  final papers = snap.data ?? [];
                  if (papers.isEmpty) {
                    return const Center(
                      child: Text('لا توجد أبحاث مطابقة',
                          style: TextStyle(color: Color(0xFFA9CFCB))),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: papers.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 4),
                          child: Text('${papers.length} نتيجة',
                              style: const TextStyle(
                                  color: Color(0xFFA9CFCB),
                                  fontWeight: FontWeight.w700)),
                        );
                      }
                      return _paperCard(papers[i - 1]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters() {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          ...Labels.region.entries.map((e) =>
              _chip(e.value, _region == e.key, () {
                _region = _region == e.key ? '' : e.key;
                _refresh();
              })),
          ...Labels.topic.entries.map((e) =>
              _chip(e.value, _topic == e.key, () {
                _topic = _topic == e.key ? '' : e.key;
                _refresh();
              })),
          ...Labels.type.entries.map((e) =>
              _chip(e.value, _type == e.key, () {
                _type = _type == e.key ? '' : e.key;
                _refresh();
              })),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          decoration: BoxDecoration(
            color: active ? SanadColors.amber : Colors.white10,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: active ? SanadColors.amber : Colors.white24),
          ),
          child: Text(label,
              style: TextStyle(
                color: active ? const Color(0xFF3A2A10) : const Color(0xFFC9E3E0),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              )),
        ),
      ),
    );
  }

  Widget _paperCard(Paper p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _pill(Labels.region[p.region] ?? p.region, SanadColors.teal500),
              if (p.topic.isNotEmpty)
                _pill(Labels.topic[p.topic] ?? p.topic, SanadColors.amber),
              if (p.year > 0) _pill('${p.year}', Colors.white24),
            ],
          ),
          const SizedBox(height: 10),
          Text(p.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.5)),
          if (p.authors.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(p.authors,
                style: const TextStyle(color: Color(0xFF9DC4C0), fontSize: 13)),
          ],
          if (p.abs.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(p.abs,
                style: const TextStyle(color: Color(0xFFA9CFCB), fontSize: 14, height: 1.6)),
          ],
          if (p.url.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => launchUrl(Uri.parse(p.url),
                  mode: LaunchMode.externalApplication),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('قراءة البحث',
                      style: TextStyle(
                          color: SanadColors.amber, fontWeight: FontWeight.w700)),
                  SizedBox(width: 4),
                  Icon(Icons.north_east, color: SanadColors.amber, size: 16),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text,
            style: TextStyle(
                color: color == Colors.white24 ? const Color(0xFFA9CFCB) : color,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      );

  Widget _error(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: SanadColors.coral)),
        ),
      );
}
