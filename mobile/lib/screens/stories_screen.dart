import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final _api = ApiService();
  late Future<List<Story>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getStories();
  }

  void _reload() => setState(() => _future = _api.getStories());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SanadColors.sand,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SanadColors.teal700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('شاركنا قصتك'),
        onPressed: _openForm,
      ),
      body: FutureBuilder<List<Story>>(
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
          final stories = snap.data ?? [];
          if (stories.isEmpty) {
            return const Center(child: Text('لا توجد قصص منشورة بعد'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stories.length,
            itemBuilder: (context, i) => _storyCard(stories[i]),
          );
        },
      ),
    );
  }

  Widget _storyCard(Story s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: SanadColors.amber,
                  child: Text(s.initial,
                      style: const TextStyle(
                          color: Color(0xFF3A2A10),
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(s.who,
                      style: const TextStyle(
                          color: SanadColors.muted,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text('“${s.body}”',
                style: const TextStyle(
                    color: SanadColors.ink, fontSize: 15, height: 1.75)),
          ],
        ),
      ),
    );
  }

  void _openForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _StoryForm(api: _api, onDone: _reload),
    );
  }
}

class _StoryForm extends StatefulWidget {
  final ApiService api;
  final VoidCallback onDone;
  const _StoryForm({required this.api, required this.onDone});
  @override
  State<_StoryForm> createState() => _StoryFormState();
}

class _StoryFormState extends State<_StoryForm> {
  final _body = TextEditingController();
  final _who = TextEditingController();
  final _initial = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _body.dispose();
    _who.dispose();
    _initial.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_body.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      final msg = await widget.api.submitStory(
        body: _body.text.trim(),
        who: _who.text.trim(),
        initial: _initial.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
      widget.onDone();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: SanadColors.coral),
      );
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('شاركنا قصتك',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: SanadColors.teal900)),
          const SizedBox(height: 4),
          const Text('ستُراجَع قبل النشر.',
              style: TextStyle(color: SanadColors.muted)),
          const SizedBox(height: 16),
          TextField(
            controller: _body,
            maxLines: 4,
            decoration: _dec('قصتك'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _who, decoration: _dec('الاسم / التعريف')),
          const SizedBox(height: 12),
          TextField(
            controller: _initial,
            maxLength: 2,
            decoration: _dec('الحرف الأول (للأفاتار)'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SanadColors.teal700,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _busy ? null : _submit,
              child: Text(_busy ? 'جارٍ الإرسال…' : 'إرسال القصة'),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: SanadColors.sand,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: SanadColors.line),
        ),
      );
}
