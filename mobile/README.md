# سند — تطبيق الموبايل (Flutter)

نسخة موبايل لمنصّة سند، تتصل بنفس الباك-إند (Go API) وتعرض نفس الداتا الحقيقية.

## البنية
```
mobile/
├── pubspec.yaml            التبعيات (http, url_launcher)
└── lib/
    ├── main.dart           نقطة التشغيل + RTL + الثيم
    ├── theme.dart          ألوان وهوية سند
    ├── labels.dart         التسميات العربية للفلاتر
    ├── models/
    │   └── models.dart     Paper · SarcomaType · Story  (تطابق JSON الباك-إند)
    ├── services/
    │   └── api_service.dart طبقة الاتصال بالـ API (قراءة + كتابة)
    └── screens/
        ├── home_screen.dart    التنقّل السفلي (Bottom Navigation)
        ├── library_screen.dart مكتبة الأبحاث: بحث + فلاتر + فتح الرابط
        ├── types_screen.dart   الأنواع بتبويبات (عظام/أطفال/أنسجة رخوة)
        └── stories_screen.dart القصص + نموذج إرسال قصة
```

## المتطلبات
- Flutter SDK \u200F3.0+ (تم الاختبار على 3.44).
- الباك-إند شغّال: `cd ../backend && go run .`  (على المنفذ 8080).

## التشغيل
```powershell
cd mobile
flutter pub get
flutter run                # اختر جهاز/محاكي
```

### عنوان الـ API (مهم)
يُحدَّد تلقائيًا في `lib/services/api_service.dart`:
- **محاكي Android** → `http://10.0.2.2:8080` (يصل لـ localhost الجهاز)
- **الويب / iOS** → `http://localhost:8080`
- **جهاز حقيقي** → مرّر IP جهازك على الشبكة:
  ```powershell
  flutter run --dart-define=API_URL=http://192.168.1.5:8080
  ```

## المميزات (كلها بداتا حيّة من الـ API)
- 📚 **مكتبة الأبحاث**: بحث نصّي + فلترة (منطقة/موضوع/نوع) + فتح رابط البحث.
- 🧬 **الأنواع**: تبويبات حسب الفئة من `/api/types`.
- 💬 **القصص**: عرض القصص المعتمدة + إرسال قصة جديدة (`POST /api/stories`).

## البناء للإصدار
```powershell
flutter build apk          # أندرويد
flutter build web          # ويب
```
