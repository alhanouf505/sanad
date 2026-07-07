import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// طبقة الاتصال بالـ API (نفس الباك-إند Go).
///
/// ملاحظة عن الـ URL:
/// - محاكي Android يصل لـ localhost الجهاز عبر 10.0.2.2
/// - محاكي iOS / الويب يستخدم localhost مباشرة
/// - جهاز حقيقي: ضع IP جهازك على الشبكة (مثال: http://192.168.1.5:8080)
class ApiService {
  static String get baseUrl {
    const override = String.fromEnvironment('API_URL');
    if (override.isNotEmpty) return override;
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  Uri _u(String path, [Map<String, String>? q]) =>
      Uri.parse('$baseUrl/api$path').replace(queryParameters: q);

  // ---- قراءة ----

  Future<List<Paper>> getPapers({
    String q = '',
    String region = '',
    String topic = '',
    String type = '',
    String sort = 'year',
  }) async {
    final params = <String, String>{};
    if (q.isNotEmpty) params['q'] = q;
    if (region.isNotEmpty) params['region'] = region;
    if (topic.isNotEmpty) params['topic'] = topic;
    if (type.isNotEmpty) params['type'] = type;
    if (sort.isNotEmpty) params['sort'] = sort;

    final res = await http.get(_u('/papers', params));
    if (res.statusCode != 200) throw Exception('فشل تحميل الأبحاث');
    final List data = jsonDecode(utf8.decode(res.bodyBytes));
    return data.map((e) => Paper.fromJson(e)).toList();
  }

  /// يرجّع الأنواع مجمّعة حسب الفئة: {soft: [...], bone: [...], child: [...]}
  Future<Map<String, List<SarcomaType>>> getTypes() async {
    final res = await http.get(_u('/types'));
    if (res.statusCode != 200) throw Exception('فشل تحميل الأنواع');
    final Map data = jsonDecode(utf8.decode(res.bodyBytes));
    return data.map((key, value) => MapEntry(
          key as String,
          (value as List).map((e) => SarcomaType.fromJson(e)).toList(),
        ));
  }

  Future<List<Story>> getStories() async {
    final res = await http.get(_u('/stories'));
    if (res.statusCode != 200) throw Exception('فشل تحميل القصص');
    final List data = jsonDecode(utf8.decode(res.bodyBytes));
    return data.map((e) => Story.fromJson(e)).toList();
  }

  // ---- كتابة ----

  Future<String> submitStory({
    required String body,
    required String who,
    required String initial,
  }) async {
    final res = await http.post(
      _u('/stories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Body': body, 'Who': who, 'Initial': initial}),
    );
    return _messageOrThrow(res);
  }

  Future<String> subscribe(String email) async {
    final res = await http.post(
      _u('/subscribe'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': email}),
    );
    return _messageOrThrow(res);
  }

  Future<String> suggestPaper({
    required String title,
    String url = '',
    String note = '',
    String email = '',
  }) async {
    final res = await http.post(
      _u('/papers/suggest'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Title': title, 'URL': url, 'Note': note, 'Email': email}),
    );
    return _messageOrThrow(res);
  }

  String _messageOrThrow(http.Response res) {
    final Map data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 400) {
      throw Exception(data['error'] ?? 'حدث خطأ');
    }
    return data['message'] ?? 'تم';
  }
}
